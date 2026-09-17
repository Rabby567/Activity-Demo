# ActivityTrack Agent - One-time Windows setup
# Installs dependencies, registers a visible-at-login scheduled task, and starts the agent.
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir
$taskName = "ActivityTrack Employee Agent"
$agentScript = Join-Path $scriptDir "employee_agent.py"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " ActivityTrack Agent - One-time Setup" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Find Python
$python = $null
foreach ($candidate in @("py", "python", "python3")) {
    try {
        $cmd = Get-Command $candidate -ErrorAction Stop
        $python = $cmd.Source
        break
    } catch {}
}
if (-not $python) {
    Write-Host "Python 3.8+ is required. Install Python and enable Add to PATH, then run setup again." -ForegroundColor Red
    Read-Host "Press Enter to close"
    exit 1
}

Write-Host "[1/4] Installing agent dependencies..." -ForegroundColor Cyan
& $python -m pip install -r (Join-Path $scriptDir "requirements.txt")
if ($LASTEXITCODE -ne 0) { throw "Dependency installation failed." }

$configPath = Join-Path $scriptDir "config.json"
if (-not (Test-Path $configPath)) { throw "config.json was not found." }

# Prefer pythonw.exe so no console window appears.
$pythonExe = $python
if ($pythonExe -match "python.exe$") {
    $pythonw = $pythonExe -replace "python.exe$", "pythonw.exe"
} else {
    $pythonw = $null
}
if (-not $pythonw -or -not (Test-Path $pythonw)) {
    $pythonw = $pythonExe
}

Write-Host "[2/4] Registering automatic startup..." -ForegroundColor Cyan

# Remove an older task with either name.
foreach ($oldName in @("EmployeeMonitorAgent", $taskName)) {
    try {
        Unregister-ScheduledTask -TaskName $oldName -Confirm:$false -ErrorAction SilentlyContinue
    } catch {}
}

$action = New-ScheduledTaskAction `
    -Execute $pythonw `
    -Argument "`"$agentScript`"" `
    -WorkingDirectory $scriptDir

# Starts after the employee signs into Windows. It remains visible in the system tray.
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME

$settings = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1)

$principal = New-ScheduledTaskPrincipal `
    -UserId $env:USERNAME `
    -LogonType Interactive `
    -RunLevel Limited

Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Description "ActivityTrack employee agent. Visible system-tray application; starts at Windows login." `
    -Force | Out-Null

Write-Host "[3/4] Starting the agent now..." -ForegroundColor Cyan
Start-ScheduledTask -TaskName $taskName

Write-Host "[4/4] Completed." -ForegroundColor Green
Write-Host ""
Write-Host "The agent will now start automatically whenever this Windows user logs in." -ForegroundColor Green
Write-Host "Look for the ActivityTrack icon in the system tray." -ForegroundColor Green
Write-Host "You do not need to run employee_agent.py again." -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to close"
