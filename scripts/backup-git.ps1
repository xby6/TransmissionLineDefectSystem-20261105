param(
    [string]$BackupRoot = 'D:\Work_space\project\TransmissionLineDefectSystem-backups'
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location -LiteralPath $projectRoot
try {
    $dirty = & git status --porcelain
    if ($LASTEXITCODE -ne 0) { throw 'Cannot read Git status.' }
    if ($dirty) { throw 'Commit or separately preserve pending changes before backing up this Git version.' }
    $commit = (& git rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0) { throw 'Cannot read current Git commit.' }
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $outputDirectory = Join-Path $BackupRoot "git-$stamp-$($commit.Substring(0, 7))"
    if (Test-Path -LiteralPath $outputDirectory) { throw "Backup already exists: $outputDirectory" }
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
    $bundle = Join-Path $outputDirectory 'project.git.bundle'
    & git bundle create $bundle --all
    if ($LASTEXITCODE -ne 0) { throw 'Git bundle creation failed.' }
    & git bundle verify $bundle
    if ($LASTEXITCODE -ne 0) { throw 'Git bundle verification failed.' }
    $metadata = [PSCustomObject]@{
        created_at = (Get-Date).ToString('o')
        project = $projectRoot
        commit = $commit
        subject = (& git log -1 --format=%s)
        bundle = $bundle
        sha256 = (Get-FileHash -LiteralPath $bundle -Algorithm SHA256).Hash
        scope = 'Complete Git history and tracked files, including model weights. Runtime data and local config are backed up separately.'
    }
    $metadata | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $outputDirectory 'backup.json') -Encoding UTF8
    Write-Host "Git backup saved: $outputDirectory"
}
finally { Pop-Location }
