$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $root 'dist'
$destination = Join-Path $dist 'ForeverExpeditionPlanner'
$archive = Join-Path $dist 'ForeverExpeditionPlanner-0.1.0-alpha.zip'

node (Join-Path $PSScriptRoot 'validate.mjs')
if ($LASTEXITCODE -ne 0) { throw 'Static validation failed.' }
if (Test-Path $dist) { Remove-Item -Recurse -Force $dist }
New-Item -ItemType Directory -Force $destination | Out-Null

$files = @(
    'ForeverExpeditionPlanner.toc', 'Core.lua', 'Data.lua', 'Database.lua',
    'Conflicts.lua', 'Planner.lua', 'Party.lua', 'Checklists.lua',
    'README.md', 'PLAN.md', 'PREFLIGHT.md', 'LICENSE'
)
foreach ($file in $files) { Copy-Item (Join-Path $root $file) (Join-Path $destination $file) }
Copy-Item -Recurse (Join-Path $root 'UI') (Join-Path $destination 'UI')
Copy-Item -Recurse (Join-Path $root 'Media') (Join-Path $destination 'Media')
Compress-Archive -Path $destination -DestinationPath $archive -CompressionLevel Optimal

Write-Host "Package folder ready: $destination"
Write-Host "Package archive ready: $archive"
