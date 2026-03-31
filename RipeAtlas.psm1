# RipeAtlas.psm1
# Main Module

# Import Private
$privatePath = Join-Path $PSScriptRoot "Private"
if (Test-Path $privatePath) {
    Get-ChildItem -Path $privatePath -Filter *.ps1 | ForEach-Object {
        . $_.FullName
    }
}

# Import Public
$publicPath = Join-Path $PSScriptRoot "Public"
if (Test-Path $publicPath) {
    Get-ChildItem -Path $publicPath -Filter *.ps1 | ForEach-Object {
        . $_.FullName
    }
}

# 3. Define Aliases
Set-Alias -Name prb      -Value Get-RipeProbes
Set-Alias -Name prbact   -Value Get-ProbeActivity
Set-Alias -Name prblast  -Value Get-ProbeLastestResult
Set-Alias -Name prbres   -Value Get-ProbeResult
Set-Alias -Name prbtest  -Value Test-ProbeDiagnostic

# Export public
$publicFunctions = Get-ChildItem -Path $publicPath -Filter *.ps1 | ForEach-Object { $_.BaseName }

Export-ModuleMember -Function $publicFunctions -Alias prb, prbact, prblast, prbres, prbtest
