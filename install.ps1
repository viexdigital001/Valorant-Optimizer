# install.ps1
# Script cài đặt và khởi chạy cho Valorant Optimize 1.0.0

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   VALORANT OPTIMIZE 1.0.0 INSTALLER     " -ForegroundColor Cyan -BackgroundColor Black
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Đang kiểm tra môi trường hệ thống..." -ForegroundColor Yellow

# 1. Kiểm tra quyền Administrator
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "⚠️ Đang tự động yêu cầu quyền Administrator để tối ưu hệ thống..." -ForegroundColor Yellow
    try {
        if ($PSCommandPath) {
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        } else {
            # Nếu chạy online qua iex, gọi trực tiếp link repo của user không dùng nháy kép
            $onlineUrl = "https://raw.githubusercontent.com/viexdigital001/Valorant-Optimizer/main/install.ps1"
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm $onlineUrl | iex`"" -Verb RunAs
        }
        Exit
    } catch {
        Write-Host "⚠️ LỖI: Ae chưa đồng ý cấp quyền Administrator! Không thể tối ưu được rồi." -ForegroundColor Red
        Write-Host "Ấn phím bất kỳ để thoát..." -ForegroundColor Gray
        Read-Host | Out-Null
        Exit
    }
}

# 2. Kiểm tra phiên bản PowerShell
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Error "⚠️ LỖI: Dự án yêu cầu tối thiểu PowerShell 5.1! Phiên bản hiện tại của bạn là: $($PSVersionTable.PSVersion.Major)"
    Write-Host "Ấn phím bất kỳ để thoát..."
    [Console]::ReadKey($true) | Out-Null
    Exit
}

# 3. Xác định thư mục làm việc và Đồng bộ hóa mã nguồn từ GitHub
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

# Tạo thư mục làm việc nếu chưa có
if (-not (Test-Path $scriptDir)) {
    New-Item -ItemType Directory -Path $scriptDir -Force | Out-Null
}

# Nếu không chạy offline (hoặc thiếu file), tiến hành tải từ GitHub
$mainPath = Join-Path $scriptDir "main.ps1"
if (-not (Test-Path $mainPath) -or ($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) {
    Write-Host "📡 Đang đồng bộ hóa mã nguồn mới nhất từ GitHub..." -ForegroundColor Yellow
    
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
    
    # Ép sử dụng giao thức bảo mật TLS 1.2
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
        Write-Host "[$idx/$($filesToDownload.Count)] Tải xuống: $relPath" -ForegroundColor Gray
        
        try {
            Invoke-RestMethod -Uri $remoteUrl -OutFile $localPath -ErrorAction Stop
        } catch {
            Write-Host "⚠️ LỖI khi tải file $relPath : $_" -ForegroundColor Red
            Write-Host "Ấn phím bất kỳ để thoát..." -ForegroundColor Gray
            Read-Host | Out-Null
            Exit
        }
    }
    Write-Host "✔ Đồng bộ hóa hoàn tất!" -ForegroundColor Green
}

Write-Host "✔ Môi trường hợp lệ. Đang khởi chạy Valorant Optimize..." -ForegroundColor Green
Start-Sleep -Seconds 1

# 4. Khởi chạy Main
$cmd = "Set-Location -Path '$scriptDir'; & '$mainPath'"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $cmd




