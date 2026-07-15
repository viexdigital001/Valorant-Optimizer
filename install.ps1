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
            # Nếu chạy online qua iex, dùng lệnh trong $MyInvocation.Line hoặc link mặc định
            $line = $MyInvocation.Line
            if (-not $line) { $line = "irm https://raw.githubusercontent.com/username/repo/main/install.ps1 | iex" }
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$line`"" -Verb RunAs
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

# 3. Xác minh cấu trúc thư mục
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not $scriptDir) { $scriptDir = Get-Location }

$requiredFolders = @("core", "modules", "ui", "configs", "configs\lang")
$structureOk = $true

foreach ($folder in $requiredFolders) {
    $path = Join-Path $scriptDir $folder
    if (-not (Test-Path $path)) {
        Write-Host "📁 Đang tạo thư mục thiếu: $folder" -ForegroundColor Gray
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

# 4. Xác minh tệp tin cốt lõi
$mainPath = Join-Path $scriptDir "main.ps1"
if (-not (Test-Path $mainPath)) {
    Write-Error "⚠️ LỖI: Không tìm thấy tệp tin main.ps1! Vui lòng tải lại toàn bộ dự án."
    Write-Host "Ấn phím bất kỳ để thoát..."
    [Console]::ReadKey($true) | Out-Null
    Exit
}

Write-Host "✔ Môi trường hợp lệ. Đang khởi chạy Valorant Optimize..." -ForegroundColor Green
Start-Sleep -Seconds 1

# 5. Khởi chạy Main
$cmd = "Set-Location -Path '$scriptDir'; & '$mainPath'"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $cmd


