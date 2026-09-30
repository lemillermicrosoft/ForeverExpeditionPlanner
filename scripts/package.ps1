$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $root 'dist'
$destination = Join-Path $dist 'ForeverExpeditionPlanner'
$version = ((Select-String -Path (Join-Path $root 'ForeverExpeditionPlanner.toc') -Pattern '^## Version: (.+)$').Matches[0].Groups[1].Value)
$archive = Join-Path $dist "ForeverExpeditionPlanner-$version.zip"
node (Join-Path $PSScriptRoot 'validate.mjs'); if ($LASTEXITCODE -ne 0) { throw 'Static validation failed.' }
node (Join-Path $PSScriptRoot 'test.mjs'); if ($LASTEXITCODE -ne 0) { throw 'Deterministic tests failed.' }
if (Test-Path $dist) { Remove-Item -Recurse -Force $dist }
New-Item -ItemType Directory -Force $destination | Out-Null
$files = @(
    'ForeverExpeditionPlanner.toc', 'Core.lua', 'Data.lua', 'DataSources.lua', 'Database.lua',
    'Conflicts.lua', 'Planner.lua', 'ImportExport.lua', 'Party.lua', 'Checklists.lua', 'Integrations.lua',
    'README.md', 'CHANGELOG.md', 'PLAN.md', 'PREFLIGHT.md', 'DATA_PROVENANCE.md', 'LICENSE'
)
foreach ($file in $files) { Copy-Item (Join-Path $root $file) (Join-Path $destination $file) }
Copy-Item -Recurse (Join-Path $root 'UI') (Join-Path $destination 'UI')
Copy-Item -Recurse (Join-Path $root 'Media') (Join-Path $destination 'Media')
Compress-Archive -Path $destination -DestinationPath $archive -CompressionLevel Optimal
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead($archive)
try {
    if (-not ($zip.Entries | Where-Object { $_.FullName -replace '\\','/' -eq 'ForeverExpeditionPlanner/ForeverExpeditionPlanner.toc' })) { throw 'Archive root is invalid.' }
    if ($zip.Entries | Where-Object { ($_.FullName -replace '\\','/') -match '(^|/)(scripts|dist|\.git)/' }) { throw 'Archive contains development files.' }
} finally { $zip.Dispose() }
Write-Host "Package folder ready: $destination"
Write-Host "Package archive ready: $archive"
