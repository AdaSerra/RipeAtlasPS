# RIPE Atlas PowerShell Module

![Powershell](https://img.shields.io/badge/PowerShell-Module-blue) ![Status](https://img.shields.io/badge/Status-Personal--Use-orange) ![License](https://img.shields.io/badge/License-MIT-lightgrey)


A lightweight, personal-use PowerShell module for interacting with the RIPE Atlas API. This is designed to be a "no-fluff" tool for quick data retrieval.


## Exposed Functions


| Name                      | Alias    | Description                                                          |
| :-------------------------|:---------|:---------------------------------------------------------------------|
| Get-RipeProbes            | prb      | Retrieves a list of probes associated with a specific ASN            |
| Get-ProbeActivity         | prbact   | Lists recent activity logs for a specific Probe ID                   |
| Get-ProbeResult           | prbres   | Queries results for a specific Measurement ID (msmId) on a probe     |
| Get-ProbeLastestResult    | prblast  | Queries results for lastest msmId on a Probe                         |
| Test-ProbeDiagnostic      | prbtest  | Performs a quick IPv4/IPv6 health check on a RIPE Atlas probe        |

## Installation 

Place the module folder (RipeAtlas) inside one of your PowerShell module paths, for example and Import it:

```
$env:USERPROFILE\Documents\PowerShell\Modules\
Import-Module RipeAtlas
```
