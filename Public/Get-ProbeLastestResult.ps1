function Get-ProbeLastestResult {
    param([int]$probeId)
   
    Get-ProbeResult -probeId $probeId
}