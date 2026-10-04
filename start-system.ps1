param(
    [switch]$NoBrowser,
    [string]$AlgorithmPython = 'D:\tool\Python310\python.exe',
    [string]$RedisServer = 'D:\tool\redis\redis3\redis-server.exe',
    [string]$Node = 'D:\tool\nodejs\node.exe'
)
$ErrorActionPreference = 'Stop'
$taskRoot = $PSScriptRoot
$logDir = Join-Path $taskRoot 'tmp\runtime'
New-Item -ItemType Directory -Path $logDir -Force | Out-Null
$statePath = Join-Path $logDir 'processes.json'
[array]$managed = @()
if (Test-Path -LiteralPath $statePath) {
    $managed = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
}
$env:PYTHONUTF8 = '1'

function Start-SystemService($Name, $Port, $Executable, $Arguments, $Directory) {
    $listener = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($listener) {
        Write-Host "$Name is already listening on port $Port."
        return
    }
    if (-not (Test-Path -LiteralPath $Executable)) { throw "Missing runtime: $Executable" }
    $process = Start-Process -FilePath $Executable -ArgumentList $Arguments -WorkingDirectory $Directory -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $logDir "$Name.log") -RedirectStandardError (Join-Path $logDir "$Name-error.log")
    $deadline = (Get-Date).AddSeconds(45)
    do {
        if ($process.HasExited) { throw "$Name exited. See $logDir\$Name-error.log" }
        $readyListener = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($readyListener) {
            # A Windows venv launcher starts a separate python.exe process.
            # Record the actual listener and numeric ticks, avoiding JSON date conversion.
            $owner = Get-Process -Id $readyListener.OwningProcess
            $script:managed += [PSCustomObject]@{ name = $Name; pid = $owner.Id; startTicks = $owner.StartTime.ToUniversalTime().Ticks.ToString(); executable = $Executable }
            ConvertTo-Json -InputObject @($script:managed) | Set-Content -LiteralPath $statePath -Encoding UTF8
            return
        }
        Start-Sleep -Milliseconds 300
    } while ((Get-Date) -lt $deadline)
    throw "$Name did not start on port $Port. See $logDir."
}

if (-not (Get-NetTCPConnection -LocalPort 5432 -State Listen -ErrorAction SilentlyContinue)) {
    throw 'PostgreSQL is not running on port 5432. Start your existing PostgreSQL service first.'
}
if (-not (Test-Path -LiteralPath (Join-Path $taskRoot 'frontend\node_modules\vite\bin\vite.js'))) {
    throw 'Frontend dependencies are missing. Run npm install inside frontend first.'
}
Start-SystemService 'redis' 6379 $RedisServer @('--bind', '127.0.0.1', '--port', '6379') (Split-Path -Parent $RedisServer)
Start-SystemService 'algorithm' 8000 $AlgorithmPython @('app/main.py') (Join-Path $taskRoot 'Intelligent Detection System for Transmission Line Defects-server')
Start-SystemService 'backend' 9099 (Join-Path $taskRoot 'backend\venv\Scripts\python.exe') @('app.py', '--env=dev') (Join-Path $taskRoot 'backend')
Start-SystemService 'frontend' 8088 $Node @('node_modules/vite/bin/vite.js', '--host', '127.0.0.1', '--strictPort') (Join-Path $taskRoot 'frontend')
foreach ($address in @('http://127.0.0.1:8000/list', 'http://127.0.0.1:9099/docs', 'http://127.0.0.1:8088')) {
    $ready = $false
    for ($attempt = 0; $attempt -lt 20; $attempt++) {
        try { $null = Invoke-WebRequest -Uri $address -UseBasicParsing -TimeoutSec 3; $ready = $true; break }
        catch { Start-Sleep -Milliseconds 500 }
    }
    if (-not $ready) { throw "Service health check failed: $address. See $logDir." }
}
Write-Host 'System is ready: http://127.0.0.1:8088   Login: admin / admin123'
if (-not $NoBrowser) { Start-Process 'http://127.0.0.1:8088' }
