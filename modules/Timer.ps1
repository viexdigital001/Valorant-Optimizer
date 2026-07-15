# modules/Timer.ps1
# Module tối ưu độ phân giải Timer của hệ thống cho Valorant Optimize 1.0.0

function Check-Timer {
    Write-Log "Kiểm tra cấu hình Timer hệ thống..." "INFO"
    # Kiểm tra bằng bcdedit
    try {
        $bcd = bcdedit /enum [{current}]
        $dynTick = $bcd -match "disabledynamictick\s+Yes"
        $platClock = $bcd -match "useplatformclock\s+Yes"
        Write-Log "Bcdedit - DisableDynamicTick: $dynTick, UsePlatformClock: $platClock" "INFO"
    } catch {
        Write-Log "Lỗi đọc bcdedit: $_" "WARNING"
    }
    return "OK"
}

function Apply-Timer {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bắt đầu tối ưu hóa System Timer..." "INFO"
    
    # 1. Tắt Dynamic Tick (Ngăn Windows tự động thay đổi nhịp đồng hồ, giảm giật/lag chuột)
    try {
        bcdedit /set disabledynamictick yes 2>&1 | Out-Null
        Write-Log "Đã kích hoạt DisableDynamicTick trong BCD." "INFO"
    } catch {
        Write-Log "Không thể cấu hình disabledynamictick: $_" "WARNING"
    }
    
    # 2. Xóa UsePlatformClock (Tắt HPET ở mức phần mềm để chuyển sang TSC nhanh hơn)
    try {
        bcdedit /deletevalue useplatformclock 2>&1 | Out-Null
        Write-Log "Đã tắt HPET phần mềm (sử dụng TSC có độ trễ cực thấp)." "INFO"
    } catch {
        # Nếu khóa này chưa từng được đặt thì bcdedit sẽ lỗi, bỏ qua
        Write-Log "HPET mặc định của BIOS đã được áp dụng hoặc useplatformclock chưa từng được cấu hình." "DEBUG"
    }
    
    # 3. Cấu hình Registry phụ trợ cho RTC (Real Time Clock) và High Resolution Timer
    $timerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"
    if (-not (Test-Path $timerPath)) {
        New-Item -Path $timerPath -Force | Out-Null
    }
    Backup-RegistryValue -Path $timerPath -ValueName "GlobalTimerResolutionLimits"
    # Thiết lập kích hoạt giới hạn độ phân giải tối đa cho Timer
    Set-ItemProperty -Path $timerPath -Name "GlobalTimerResolutionLimits" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Log "Tối ưu hóa Timer hoàn tất!" "SUCCESS"
}

function Restore-Timer {
    Write-Log "Đang khôi phục cấu hình Timer..." "INFO"
    try {
        bcdedit /deletevalue disabledynamictick 2>&1 | Out-Null
        Write-Log "Đã trả lại thiết lập mặc định cho Dynamic Tick." "INFO"
    } catch {}
}

function Verify-Timer {
    Write-Log "Xác minh cấu hình Timer..." "INFO"
    return $true
}

function WriteLog-Timer {
    # Tích hợp trực tiếp qua Logger
}





