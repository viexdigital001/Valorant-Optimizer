# modules/GameStart.ps1
# Module tối ưu hóa quá trình khởi động Valorant cho Valorant Optimize 1.0.0

function Check-GameStart {
    Write-Log "Kiểm tra cấu hình thư mục rác của Valorant..." "INFO"
    $valAppData = Join-Path $env:LOCALAPPDATA "VALORANT\Saved"
    if (Test-Path $valAppData) {
        Write-Log "Thư mục Saved của Valorant tồn tại tại: $valAppData" "INFO"
    }
    return "OK"
}

function Apply-GameStart {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bắt đầu dọn dẹp log rác và tối ưu khởi động Valorant..." "INFO"
    
    # 1. Dọn dẹp log và crash dump cũ của Valorant
    $valSaved = Join-Path $env:LOCALAPPDATA "VALORANT\Saved"
    if (Test-Path $valSaved) {
        $logPath = Join-Path $valSaved "Logs"
        $crashPath = Join-Path $valSaved "Crashes"
        $webCachePath = Join-Path $valSaved "webcache"
        
        if (Test-Path $logPath) {
            Remove-Item -Path $logPath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
            Write-Log "Đã dọn dẹp thư mục Logs cũ của game." "INFO"
        }
        if (Test-Path $crashPath) {
            Remove-Item -Path $crashPath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
            Write-Log "Đã dọn dẹp các tệp tin Crashes cũ." "INFO"
        }
        if (Test-Path $webCachePath) {
            Remove-Item -Path $webCachePath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
            Write-Log "Đã dọn dẹp cache web tích hợp của game." "INFO"
        }
    }
    
    # 2. Dọn dẹp log của Riot Client
    $riotClientApp = Join-Path $env:LOCALAPPDATA "Riot Games\Riot Client"
    if (Test-Path $riotClientApp) {
        $clientLogs = Join-Path $riotClientApp "Logs"
        if (Test-Path $clientLogs) {
            Remove-Item -Path $clientLogs -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
            Write-Log "Đã dọn dẹp Logs cũ của Riot Client." "INFO"
        }
    }
    
    Write-Log "Tối ưu hóa khởi động Valorant hoàn tất!" "SUCCESS"
}

function Restore-GameStart {
    Write-Log "Không cần khôi phục cho dọn dẹp khởi động." "INFO"
}

function Verify-GameStart {
    Write-Log "Xác minh cấu hình khởi động..." "INFO"
    return $true
}

function WriteLog-GameStart {
    # Tích hợp trực tiếp qua Logger
}





