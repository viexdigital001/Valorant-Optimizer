# core/Logger.ps1
# Hệ thống ghi log cho Valorant Optimize 1.0.0

$Global:LogFilePath = Join-Path $PSScriptRoot "..\logs\ValorantOptimize.log"

function Initialize-Logger {
    $logDir = Split-Path $Global:LogFilePath -Parent
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    # Tạo file log mới nếu chưa tồn tại
    if (-not (Test-Path $Global:LogFilePath)) {
        New-Item -ItemType File -Path $Global:LogFilePath -Force | Out-Null
    }
}

function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR", "DEBUG")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] [$Level] $Message"

    # Ghi log ra file
    try {
        Add-Content -Path $Global:LogFilePath -Value $logLine -ErrorAction SilentlyContinue
    } catch {}

    # Nếu đang ở chế độ Debug hoặc là lỗi/cảnh báo quan trọng, có thể in ra console tùy ý.
    # Tuy nhiên việc vẽ giao diện sẽ do UI điều phối để không làm hỏng layout.
}

# Export hàm để sử dụng ở ngoài




