# core/Logger.ps1
# System ghi log cho Valorant Optimize 1.0.0

$Global:LogFilePath = Join-Path $PSScriptRoot "..\logs\ValorantOptimize.log"

function Initialize-Logger {
    $logDir = Split-Path $Global:LogFilePath -Parent
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    # Tao file log moi neu chua ton tai
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

    # Neu Currently o Mode Debug hoac la ERROR/WARNING quan trong, co the in ra console tuy y.
    # Tuy nhien viec ve giao dien se do UI ieu phoi e khong lam hong layout.
}

# Export ham e su dung o ngoai




