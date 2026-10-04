$ErrorActionPreference = 'Stop'
$statePath = Join-Path $PSScriptRoot 'tmp\runtime\processes.json'
if (-not (Test-Path -LiteralPath $statePath)) { Write-Host 'No services started by start-system.ps1.'; return }
[array]$managed = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
foreach ($entry in $managed) {
    $process = Get-Process -Id $entry.pid -ErrorAction SilentlyContinue
    if ($process -and $process.StartTime.ToUniversalTime().Ticks.ToString() -eq $entry.startTicks) {
        # PID plus creation time prevents stopping an unrelated reused PID.
        & taskkill.exe /PID $entry.pid /T /F | Out-Null
        Write-Host "Stopped $($entry.name)."
    }
}
'[]' | Set-Content -LiteralPath $statePath -Encoding UTF8
