function Invoke-RipeApi {
    param(
        [string]$Url,
        [switch]$Paginate
    )

    $results = @()
    $next = $Url

    while ($next) {
        try {
            $response = Invoke-RestMethod -Uri $next -ErrorAction Stop
        } catch {
            throw "API RIPE Error: $($_.Exception.Message)"
        }

        if ($Paginate) {
            $results += $response.results
            $next = $response.next
        } else {
            return $response
        }
    }

    return $results
}
