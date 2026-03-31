function Test-ProbeDiagnostic {
    <#
    .SYNOPSIS
        Performs a quick diagnosis of IPv4 and IPv6 connectivity on a RIPE Atlas probe.
    
    .DESCRIPTION
        Retrieves the latest active measurements for both protocols and reports any DNS or network resolution errors, helping to identify whether the problem is IPv6-related.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [int]$probeId
    )

    Write-Host "--- RIPE Atlas Probe Diagnosis: $probeId ---" -ForegroundColor Cyan

    # 1. Fetch probe general info
    $probeInfo = Invoke-RipeApi "https://atlas.ripe.net/api/v2/probes/$probeId/"
    if (-not $probeInfo) { Write-Error "Probe not found."; return }

    Write-Host "State: $($probeInfo.status.name)" -ForegroundColor Yellow
    Write-Host "ASN V4: $($probeInfo.asn_v4) | ASN V6: $($probeInfo.asn_v6)"
    Write-Host "-------------------------------------------"

    # 2. Test connectivity
    $protocols = @(
        @{ Label = "IPv4"; AF = 4 },
        @{ Label = "IPv6"; AF = 6 }
    )

    foreach ($proto in $protocols) {
        Write-Host "Checking $($proto.Label)... " -NoNewline
        
        $url = "https://atlas.ripe.net/api/v2/probes/$probeId/measurements/?af=$($proto.AF)&page_size=1"
        $latest = Invoke-RipeApi $url

        if ($latest.count -gt 0) {
            $msmId = $latest.results[0].id
            
            # call function 1 time and save output
            $results = Get-ProbeResult -probeId $probeId -msmId $msmId -ErrorAction SilentlyContinue
            
            # check results
            if ($results -contains $false -or $results -eq $false) {
                Write-Host " [FAIL]" -ForegroundColor Red
            } else {
                Write-Host " [OK]" -ForegroundColor Green
            }
        }
        else {
            Write-Host " [NO ACTIVE MEASURES]" -ForegroundColor Gray
        }
    }
    
    Write-Host "Tip: If IPv6 consistently fails while IPv4 is OK, check the probe prefix on RIPE Atlas." -ForegroundColor Gray
}