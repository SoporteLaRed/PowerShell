$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host -Object 'Iniciado limpieza de registros de instalacion ...'
$Parameters = @{
    Uri             = 'https://raw.githubusercontent.com/SoporteLaRed/PowerShell/refs/heads/main/SupportAssistCleanup.ps1'
    UseBasicParsing = $true
  }
Invoke-WebRequest @Parameters | Invoke-Expression
