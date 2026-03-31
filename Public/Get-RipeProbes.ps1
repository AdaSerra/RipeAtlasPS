function Get-RipeProbes {
    <#
    .SYNOPSIS
        Retrieves active RIPE Atlas probes for a given ASN.

    .DESCRIPTION
        Queries the RIPE Atlas API to get a list of probes filtered by Autonomous System Number (ASN).
        Returns only probes with a "Connected" status (status=1) and formats the output for quick reading.

    .PARAMETER asn
        The Autonomous System Number (e.g., 1234) to query.

    .EXAMPLE
        Get-RipeProbes -asn 3333
        Retrieves all connected probes in ASN 3333 (RIPE NCC).
    #>
    param(
        [Parameter(Mandatory=$true, HelpMessage="Insert AS Number")]
        [int]$asn
    )

    $url = "https://atlas.ripe.net/api/v2/probes/?asn_v4=$asn&status=1"
    
    Invoke-RipeApi -Url $url -Paginate | ForEach-Object {
        [PSCustomObject]@{
            ID        = $_.id
            Country   = $_.country_code
            City      = if ($_.city) { $_.city } else { "N/A" }
            Status    = "Connected"
            AddressV4 = $_.address_v4
            IsAnchor  = [bool]$_.is_anchor
        }
    }
}