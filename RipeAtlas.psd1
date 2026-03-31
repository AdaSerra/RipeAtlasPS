@{
   # Nome del modulo
   ModuleVersion = '1.0.0'

   # Identificatore univoco (GUID) - Generato per te
   GUID = 'b8e39f21-911a-4cfa-8b8a-9f4a5c0d7e8f'

   # Autore
   Author = 'Adalberto Serra'

   # Società o Copyright
   CompanyName = 'Personal Use'
   Copyright = '(c) 2026 All rights reserved.'

   # Descrizione
   Description = 'A lightweight PowerShell module for querying RIPE Atlas probes and measurements.'

   # File principale del modulo (.psm1)
   RootModule = 'RipeAtlas.psm1'

   # Funzioni da esportare (devono corrispondere esattamente ai nomi nel .psm1)
   FunctionsToExport = @(
       'Get-RipeProbes',
       'Get-ProbeActivity',
       'Get-ProbeResult',
       'Get-ProbeLastestResult',
       'Test-ProbeDiagnostic'
   )

   # Cmdlet e variabili da esportare (lasciamo vuoto per performance)
   CmdletsToExport = @()
   VariablesToExport = @()
   AliasesToExport = @()

   # Compatibilità
   PowerShellVersion = '5.1'

   # PrivateData per metadati aggiuntivi (opzionale)
   PrivateData = @{
       PSData = @{
           Tags = @('RIPE', 'Atlas', 'Networking', 'Probes')
           ProjectUri = 'https://github.com/AdaSerra/RipeAtlasPS'
       }
   }
}