
function Get-RipeProbes {
    <#
    .SYNOPSIS
        Retrieves RIPE Atlas probes filtered by ASN, Country, or Geographic Location.

    .DESCRIPTION
        Queries the RIPE Atlas REST API (v2) to retrieve a list of probes. 
        Supports filtering by Autonomous System Number (ASN), ISO Country Code, 
        or a geographic radius (coordinates + distance).
        Returns a custom object containing key details such as ID, Status, IP addresses, and Uptime.

    .PARAMETER asn
        The Autonomous System Number (e.g., 1299) to query. Optional if -country or -radius is used.

    .PARAMETER country
        Two-letter ISO country code (e.g., "IT" for Italy, "US" for United States).

    .PARAMETER radius
        Circular geographic filter in "latitude,longitude:distance_km" format (e.g., "41.89,12.49:50").

    .PARAMETER status
        The connection status of the probe: 
        0 (Never Connected), 1 (Connected), 2 (Disconnected), 3 (Abandoned). 
        Defaults to 1.

    .EXAMPLE
        Get-RipeProbes -asn 1299
        Retrieves all currently connected probes within AS1299 (Telia).

    .EXAMPLE
        Get-RipeProbes -country "DE" -status 1
        Retrieves all connected probes located in Germany.

    .EXAMPLE
        Get-RipeProbes -radius "48.85,2.35:10"
        Retrieves probes within a 10km radius of Paris city center.
    #>
    param(
        [Parameter(Mandatory=$false)][int]$asn,
        [Parameter(Mandatory=$false)][string]$country,
        [Parameter(Mandatory=$false)][string]$radius, 
        [Parameter(Mandatory=$false)][ValidateRange(0,3)][int]$status = 1
    )
    $statusNames = @{
        0 = "Never Connected"
        1 = "Connected"
        2 = "Disconnected"
        3 = "Abandoned"
    }

    $url = "https://atlas.ripe.net/api/v2/probes/?status=$status"

    if ($PSBoundParameters.ContainsKey('asn')) { $url += "&asn_v4=$asn" }
    if ($PSBoundParameters.ContainsKey('country')) { $url += "&country_code=$country" }
    if ($PSBoundParameters.ContainsKey('radius')) { $url += "&radius=$radius" }
    
    Invoke-RipeApi -Url $url -Paginate | ForEach-Object {

        $dtLastConn = if ($_.last_connected) { 
            [datetimeoffset]::FromUnixTimeSeconds($_.last_connected).DateTime 
        }
        else { 
            $null 
        }

        [PSCustomObject]@{
            ID         = $_.id
            Type       = $_.type
            Country    = $_.country_code
            # City      = if ($_.city) { $_.city } else { "N/A" }
            Coords     = "$($_.geometry.coordinates[1]),$($_.geometry.coordinates[0])"
            Status    = if ($statusNames.ContainsKey($_.status.id)) { $statusNames[$_.status.id] } else { $_.status.name }
            PrefixV4    = $_.prefix_v4
            AddressV4  = $_.address_v4
            AddressV6  = if ($_.address_v6) { $_.address_v6 } else { "N/A" }
            IsAnchor   = [bool]$_.is_anchor
            LastConn   = $dtLastConn
            UptimeDays = [Math]::Round($_.total_uptime / 86400, 1)
            Tags       = ($_.tags.name -join ", ")
            
        }
    }
}