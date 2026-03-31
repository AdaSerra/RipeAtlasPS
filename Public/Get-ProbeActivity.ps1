
function Get-ProbeActivity {
    <#
    .SYNOPSIS
        Lists recent measurement activity for a specific RIPE Atlas probe.

    .DESCRIPTION
        Retrieves a list of measurements (ping, traceroute, dns, etc.) that a specific 
        probe is currently involved in or has recently completed.

    .PARAMETER probeId
        The unique ID of the RIPE Atlas probe.

    .EXAMPLE
        Get-ProbeActivity -probeId 10001
        Returns the ID, type, and status of measurements for probe 10001.
    #>
    param(
        [Parameter(Mandatory=$true, HelpMessage="Enter the Probe ID")]
        [int]$probeId
    )

    $url = "https://atlas.ripe.net/api/v2/probes/$probeId/measurements/"
    
    try {
        # Assumes Invoke-RipeApi handles the web request and returns the parsed JSON object
        $data = Invoke-RipeApi -Url $url
        
        if ($null -eq $data -or $null -eq $data.results) {
            Write-Warning "No activity found for probe $probeId."
            return
        }

        $data.results | Select-Object @{Name="msm_id"; Expression={$_.id}}, type, description, status
    }
    catch {
        Write-Error "Failed to retrieve activity for probe $probeId. Details: $_"
    }
}
