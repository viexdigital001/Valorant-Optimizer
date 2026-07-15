# install.ps1
# Script cai at va khoi chay cho Valorant Optimize 1.0.0

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   VALORANT OPTIMIZE 1.0.0 INSTALLER     " -ForegroundColor Cyan -BackgroundColor Black
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Checking system environment..." -ForegroundColor Yellow

# 1. Kiem tra quyen Administrator
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Automatically requesting Administrator privileges for optimization..." -ForegroundColor Yellow
    try {
        if ($PSCommandPath) {
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        } else {
            # Neu chay online qua iex, goi truc tiep link repo cua user khong dung nhay kep
            $onlineUrl = "https://raw.githubusercontent.com/viexdigital001/Valorant-Optimizer/main/install.ps1"
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm $onlineUrl | iex`"" -Verb RunAs
        }
        Exit
    } catch {
        Write-Host "[X] ERROR: Administrator privileges not granted! Cannot proceed." -ForegroundColor Red
        Write-Host "Press any key to exit..." -ForegroundColor Gray
        Read-Host | Out-Null
        Exit
    }
}

# 2. Kiem tra phien ban PowerShell
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Error "[X] ERROR: Project requires at least PowerShell 5.1! Your current version is: $($PSVersionTable.PSVersion.Major)"
    Write-Host "Press any key to exit..."
    [Console]::ReadKey($true) | Out-Null
    Exit
}

# 3. Xac inh thu muc lam viec va ong bo hoa ma nguon tu GitHub
$scriptDir = $PSScriptRoot
$isValidLocalDir = $false

if (-not [string]::IsNullOrWhiteSpace($scriptDir) -and ($scriptDir -match '^[a-zA-Z]:\\')) {
    if (Test-Path (Join-Path $scriptDir "main.ps1" -ErrorAction SilentlyContinue)) {
        $isValidLocalDir = $true
    }
}

if (-not $isValidLocalDir) {
    $scriptDir = Join-Path $env:USERPROFILE "ValorantOptimize"
}

# Tao thu muc lam viec neu chua co
if (-not (Test-Path $scriptDir)) {
    New-Item -ItemType Directory -Path $scriptDir -Force | Out-Null
}

# Neu khong chay offline (hoac thieu file), tien hanh tai tu GitHub
$mainPath = Join-Path $scriptDir "main.ps1"
if (-not (Test-Path $mainPath) -or ($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) {
    Write-Host "[*] Syncing latest source code from GitHub..." -ForegroundColor Yellow
    
    $githubRepo = "viexdigital001/Valorant-Optimizer"
    $rawBaseUrl = "https://raw.githubusercontent.com/$githubRepo/main"
    
    $filesToDownload = @(
        "main.ps1",
        "core/Loader.ps1",
        "core/Logger.ps1",
        "core/System.ps1",
        "core/Backup.ps1",
        "core/Restore.ps1",
        "core/OptimizeEngine.ps1",
        "ui/Color.ps1",
        "ui/Draw.ps1",
        "ui/Progress.ps1",
        "ui/Menu.ps1",
        "configs/Competitive.json",
        "configs/Balanced.json",
        "configs/Extreme.json",
        "configs/lang/vi-VN.json",
        "modules/CPU.ps1",
        "modules/GPU.ps1",
        "modules/RAM.ps1",
        "modules/Storage.ps1",
        "modules/Services.ps1",
        "modules/Network.ps1",
        "modules/Mouse.ps1",
        "modules/Keyboard.ps1",
        "modules/PowerPlan.ps1",
        "modules/Security.ps1",
        "modules/Telemetry.ps1",
        "modules/Xbox.ps1",
        "modules/Timer.ps1",
        "modules/MMCSS.ps1",
        "modules/Input.ps1",
        "modules/Audio.ps1",
        "modules/GameMode.ps1",
        "modules/GameStart.ps1",
        "modules/BackgroundApps.ps1",
        "modules/Visual.ps1",
        "modules/Process.ps1",
        "modules/Cleanup.ps1"
    )
    
    # Ep su dung giao thuc bao mat TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    $idx = 0
    foreach ($relPath in $filesToDownload) {
        $idx++
        $localPath = Join-Path $scriptDir $relPath
        $parentDir = Split-Path $localPath -Parent
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }
        
        $remoteUrl = "$rawBaseUrl/$relPath"
        Write-Host "[$idx/$($filesToDownload.Count)] Downloading: $relPath" -ForegroundColor Gray
        
        try {
            Invoke-WebRequest -Uri $remoteUrl -OutFile $localPath -ErrorAction Stop
        } catch {
            Write-Host "[X] ERROR downloading file $relPath : $_" -ForegroundColor Red
            Write-Host "Press any key to exit..." -ForegroundColor Gray
            Read-Host | Out-Null
            Exit
        }
    }
    Write-Host "[V] Synchronization complete!" -ForegroundColor Green
}

Write-Host "[V] Environment is valid. Launching Valorant Optimize..." -ForegroundColor Green
Start-Sleep -Seconds 1

# 4. Khoi chay Main
$cmd = "Set-Location -Path '$scriptDir'; & '$mainPath'"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $cmd




