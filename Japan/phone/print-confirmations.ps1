# Builds Japan/confirmations-print.html from confirmations.md and opens it for printing.
# The output holds confirmation numbers, so it is git-ignored and never published.
# Run: powershell -ExecutionPolicy Bypass -File Japan/phone/print-confirmations.ps1

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$japan = Split-Path $here -Parent

$md = [IO.File]::ReadAllText((Join-Path $japan 'confirmations.md'), [Text.Encoding]::UTF8)
# PowerShell 5.1 escapes < > & ' as < etc., so the JSON can't close the script tag early
$json = ConvertTo-Json $md -Compress

$template = [IO.File]::ReadAllText((Join-Path $here 'confirmations-template.html'), [Text.Encoding]::UTF8)
$outPath = Join-Path $japan 'confirmations-print.html'
[IO.File]::WriteAllText($outPath, $template.Replace('__CONFIRMATIONS_MD__', $json), (New-Object Text.UTF8Encoding $false))
"Wrote $outPath"
if ($args -notcontains '-NoOpen') { Start-Process $outPath }
