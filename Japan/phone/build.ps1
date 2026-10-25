# Builds japan-trip.html (the phone page) from the day files and map layers.
# Run from anywhere: powershell -ExecutionPolicy Bypass -File Japan/phone/build.ps1
# confirmations.md is never read.

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$japan = Split-Path $here -Parent

function Read-Utf8($path) { [IO.File]::ReadAllText($path, [Text.Encoding]::UTF8) }

$days = @(Get-ChildItem (Join-Path $japan 'days') -Filter '2026-*.md' | Sort-Object Name | ForEach-Object {
    [ordered]@{ id = $_.BaseName; md = (Read-Utf8 $_.FullName) }
})

$places = @(Get-ChildItem (Join-Path $japan 'map-layers') -Filter '*.csv' | Sort-Object Name | ForEach-Object {
    $layer = $_.BaseName
    Import-Csv $_.FullName -Encoding UTF8 | ForEach-Object {
        [ordered]@{ Name = $_.Name; Location = $_.Location; City = $_.City; Type = $_.Type; Notes = $_.Notes; layer = $layer }
    }
})

$data = [ordered]@{
    built  = (Get-Date).ToString('MMM d, yyyy h:mm tt')
    days   = $days
    places = $places
}
# PowerShell 5.1 escapes < > & ' as < etc., so the JSON can't close the script tag early
$json = ConvertTo-Json $data -Depth 5 -Compress

$template = Read-Utf8 (Join-Path $here 'template.html')
$out = $template.Replace('__TRIP_DATA__', $json)
$outPath = Join-Path $here 'japan-trip.html'
[IO.File]::WriteAllText($outPath, $out, (New-Object Text.UTF8Encoding $false))
"Wrote $outPath ($($days.Count) days, $($places.Count) places, $([math]::Round($out.Length / 1KB)) KB)"
