$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$destination = Join-Path $root 'dist\ForeverExpeditionPlanner'

node (Join-Path $PSScriptRoot 'validate.mjs')
if (Test-Path $destination) { Remove-Item -Recurse -Force $destination }
New-Item -ItemType Directory -Force $destination | Out-Null

$files = @(
    'ForeverExpeditionPlanner.toc', 'Core.lua', 'Data.lua', 'Database.lua',
    'Conflicts.lua', 'Planner.lua', 'Party.lua', 'Checklists.lua',
    'README.md', 'PLAN.md', 'PREFLIGHT.md', 'LICENSE'
)
foreach ($file in $files) { Copy-Item (Join-Path $root $file) (Join-Path $destination $file) }
Copy-Item -Recurse (Join-Path $root 'UI') (Join-Path $destination 'UI')

Write-Host "Package ready: $destination"
