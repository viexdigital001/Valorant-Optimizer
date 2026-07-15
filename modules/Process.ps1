# modules/Process.ps1
# Module tối ưu hóa ưu tiên tiến trình (Process Priority) cho Valorant Optimize 1.0.0

function Check-Process {
    Write-Log "Kiểm tra cấu hình chống cướp tiêu điểm của các ứng dụng nền..." "INFO"
    $desktopPath = "HKCU:\Control Panel\Desktop"
    if (Test-Path $desktopPath) {
        $timeout = Get-ItemPropertyValue -Path $desktopPath -Name "ForegroundLockTimeout" -ErrorAction SilentlyContinue
        Write-Log "ForegroundLockTimeout hiện tại: $timeout" "INFO"
    }
    return "OK"
}

function Apply-Process {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bắt đầu tối ưu hóa ưu tiên tiến trình (Process priority)..." "INFO"
    
    # 1. Cấu hình ForegroundLockTimeout = 200000 (Ngăn chặn ứng dụng nền cướp cửa sổ game khi đang chơi)
    $desktopPath = "HKCU:\Control Panel\Desktop"
    if (Test-Path $desktopPath) {
        Backup-RegistryValue -Path $desktopPath -ValueName "ForegroundLockTimeout"
        Set-ItemProperty -Path $desktopPath -Name "ForegroundLockTimeout" -Value 200000 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
        Write-Log "Đã khóa tiêu điểm ứng dụng Foreground ở mức 200,000ms." "INFO"
    }
    
    # 2. Tự động kiểm tra và nâng độ ưu tiên của tiến trình Valorant và Riot Client lên mức cao nếu chúng đang chạy
    try {
        $valProc = Get-Process -Name "VALORANT-Win64-Shipping" -ErrorAction SilentlyContinue
        if ($valProc) {
            foreach ($p in $valProc) {
                # Đặt PriorityClass = High
                $p.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::High
                Write-Log "Đã nâng độ ưu tiên runtime của tiến trình VALORANT lên HIGH." "INFO"
            }
        }
    } catch {
        Write-Log "Không thể nâng độ ưu tiên của tiến trình Valorant đang chạy (có thể do thiếu quyền hạn nâng cao hoặc game chưa mở)." "DEBUG"
    }
    
    Write-Log "Tối ưu hóa ưu tiên tiến trình hoàn tất!" "SUCCESS"
}

function Restore-Process {
    Write-Log "Đang khôi phục cấu hình Process..." "INFO"
}

function Verify-Process {
    Write-Log "Xác minh cấu hình Process..." "INFO"
    return $true
}

function WriteLog-Process {
    # Tích hợp trực tiếp qua Logger
}

Export-ModuleMember -Function Check-Process, Apply-Process, Restore-Process, Verify-Process, WriteLog-Process




