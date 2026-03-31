function Get-ProbeResult {
    <#
    .SYNOPSIS
        Retrieves and parses the latest measurement results for a specific RIPE Atlas probe.

    .DESCRIPTION
        Fetches measurement data (Ping, Traceroute, DNS, HTTP, etc.) for a probe. 
        If no Measurement ID (msmId) is provided, it automatically discovers the most recent active measurement for that probe.
        The output is formatted specifically based on the measurement type.

    .PARAMETER probeId
        The unique ID of the RIPE Atlas probe.

    .PARAMETER msmId
        The unique ID of the measurement. If omitted, the function finds the latest one.

    .EXAMPLE
        Get-ProbeResult -probeId 10001
        Finds the latest measurement for probe 10001 and displays the results.

    .EXAMPLE
        Get-ProbeResult -probeId 10001 -msmId 2405001
        Retrieves the result of measurement 2405001 for the specified probe.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [int]$probeId,

        [Parameter(Mandatory = $false)]
        [int]$msmId
    )
    
    # 1. Automatic Discovery Logic
    if (-not $msmId) {
        Write-Host "No msmId provided, fetching latest measurement for probe $probeId..." -ForegroundColor Yellow
    
        $urlLatest = "https://atlas.ripe.net/api/v2/probes/$probeId/measurements/?status=1&page_size=1"
        try {
            # Assumes Invoke-RipeApi is available in the module scope
            $latest = Invoke-RipeApi -Url $urlLatest
            if ($null -eq $latest -or $latest.count -eq 0) {
                Write-Warning "No active measurements found for probe $probeId."
                return $false
            }
            $msmId = $latest.results[0].id
            Write-Host "Latest measurement identified: $msmId" -ForegroundColor Cyan
        }
        catch {
            Write-Error "Could not retrieve latest measurement for probe $probeId : $($_.Exception.Message)"
            return $false
        }
    }

    # 2. Fetch Result Data
    $url = "https://atlas.ripe.net/api/v2/measurements/$msmId/latest/?probe_ids=$probeId"
    try {
        # Using Invoke-RestMethod for the specific results call
        $data = Invoke-RestMethod -Uri $url -ErrorAction Stop
        
        if ($null -eq $data) {
            Write-Warning "No result data returned for msmId $msmId / probe $probeId."
            return $false
        }

        # 1. Check error
        # error can be in $data.error o $data.result.error
        $errorMessage = if ($data.error) { $data.error } elseif ($data.result.error) { $data.result.error } else { $null }

        if ($errorMessage) {
            Write-Host "`n[!] PROBE ERROR: $errorMessage" -ForegroundColor Red
            # Se c'è un errore, mostriamo comunque i metadati minimi e usciamo
            $data | Select-Object msm_id, prb_id, dst_name, proto, timestamp | Format-List
            return $false
        }

        # Clean Header Output
        $excludeList = @('result', 'resultset', 'msm_name', 'from', 'stored_timestamp', 'lts')
        $header = $data | Select-Object * -ExcludeProperty $excludeList
        $header | Format-List
    
        $type = $data.type
        $result = $data.result
    
        Write-Host "`nDetected Measurement Type: $type" -ForegroundColor Yellow
        Write-Host "----------------------------------"
        

        # Write-Host $result[0]
        # 3. Type-Specific Parsing
        switch ($type) {
    
            "traceroute" {
                Write-Host "`nTraceroute Path:" -ForegroundColor Cyan
                $result | ForEach-Object {
                    $hopCount = $_.hop
                    $_.result | ForEach-Object {
                        [PSCustomObject]@{
                            Hop  = $hopCount
                            IP   = if ($_.from) { $_.from } else { "*" }
                            RTT  = if ($_.rtt) { "{0} ms" -f [Math]::Round($_.rtt, 2) } else { "Timeout" }
                            Code = if ($_.error) { $_.error } elseif ($_.x) { $_.x } else { "" }
                        }
                    }
                } | Format-Table -AutoSize
            }
    
            "ping" {
                Write-Host "`nPing Statistics:" -ForegroundColor Cyan
                [PSCustomObject]@{
                    Sent     = if ($null -ne $data.sent) { $data.sent } else { $result.sent }
                    Received = if ($null -ne $data.rcvd) { $data.rcvd } else { $result.rcvd }
                    Loss     = if ($null -ne $data.loss) { "$($data.loss)%" } else { "$($result.loss)%" }
                    RTT_Min  = if ($null -ne $data.min) { "$($data.min) ms" }  else { "$($result.rtt_min) ms" }
                    RTT_Avg  = if ($null -ne $data.avg) { "$($data.avg) ms" }  else { "$($result.rtt_avg) ms" }
                    RTT_Max  = if ($null -ne $data.max) { "$($data.max) ms" }  else { "$($result.rtt_max) ms" }
                } | Format-List
            }
    
            "dns" {
                Write-Host "`nDNS Query Results:" -ForegroundColor Cyan
    
                # RIPE Atlas DNS can get 'result' (single) o 'resultset' (multi)
                $dnsEntries = if ($data.resultset) { $data.resultset } else { @($data.result) }
            
                $dnsEntries | ForEach-Object {
                    $r = $_.result
                    [PSCustomObject]@{
                        Server     = $_.dst_addr
                        Proto      = $_.proto
                        QueryTime  = if ($r.rt) { "$([Math]::Round($r.rt, 2)) ms" } else { "Timeout/Err" }
                        ANCOUNT    = if ($null -ne $r.ANCOUNT) { $r.ANCOUNT } else { 0 }
                        # record DNS (A, AAAA, CNAME ecc) 
                        Answers    = if ($r.answers) { 
                                        ($r.answers | ForEach-Object { "$($_.type): $($_.data)" }) -join " | " 
                                     } else { "No Answer" }
                    }
                } | Format-Table -AutoSize
            }
    
            "http" {
                [PSCustomObject]@{
                   
                    StatusCode = if ($data.res) { $data.res } elseif ($result.resp_code) { $result.resp_code } else { "No Response" }
                    Size       = if ($data.size) { "$($data.size) bytes" } elseif ($data.bytes) { "$($data.bytes) bytes" } else { "0" }
                    RTT        = if ($data.ttr) { "$([Math]::Round($data.ttr, 2)) ms" } else { "$([Math]::Round($data.rt, 2)) ms" }
                    Method     = if ($data.method) { $data.method } else { "GET" }
                } | Format-Table -AutoSize
            }
    
            "ntp" {
                Write-Host "`nNTP Synchronization Info:" -ForegroundColor Cyan
                [PSCustomObject]@{
                    Offset  = $result.offset
                    Delay   = $result.delay
                    Stratum = $result.stratum
                } | Format-List
            }
    
            "sslcert" {
                Write-Host "`nTLS/SSL Certificate Info:" -ForegroundColor Cyan
                [PSCustomObject]@{
                    Subject   = $result.cert.subject
                    Issuer    = $result.cert.issuer
                    ValidFrom = $result.cert.not_before
                    ValidTo   = $result.cert.not_after
                } | Format-List
            }
    
            "tcpconnect" {
                Write-Host "`nTCP Connection Test:" -ForegroundColor Cyan
                [PSCustomObject]@{
                    Address = $result.dst_addr
                    Port    = $result.dst_port
                    Success = $result.result.success
                    RTT     = "$($result.result.rtt) ms"
                } | Format-List
            }
    
            default {
                Write-Warning "Unknown or unhandled measurement type: $type"
                $result | Format-List
                return $false
            }
        }
        return $true
    }
    catch {
        Write-Error "Failed to retrieve results: $($_.Exception.Message)"
        return $false
    }
}