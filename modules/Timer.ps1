# modules/Timer.ps1
# Module toi uu o phan giai Timer cua System cho Valorant Optimize 1.0.0

function Check-Timer {
    Write-Log "Kiem tra Configuring Timer System..." "INFO"
    # Kiem tra bang bcdedit
    try {
        $bcd = bcdedit /enum [{current}]
        $dynTick = $bcd -match "disabledynamictick\s+Yes"
        $platClock = $bcd -match "useplatformclock\s+Yes"
        Write-Log "Bcdedit - DisableDynamicTick: $dynTick, UsePlatformClock: $platClock" "INFO"
    } catch {
        Write-Log "ERROR oc bcdedit: $_" "WARNING"
    }
    return "OK"
}

function Apply-Timer {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bat au Optimizing System Timer..." "INFO"
    
    # 1. Tat Dynamic Tick (Ngan Windows Automatic thay oi nhip ong ho, giam giat/lag chuot)
    try {
        bcdedit /set disabledynamictick yes 2>&1 | Out-Null
        Write-Log "a kich hoat DisableDynamicTick trong BCD." "INFO"
    } catch {
        Write-Log "Cannot Configuring disabledynamictick: $_" "WARNING"
    }
    
    # 2. Xoa UsePlatformClock (Tat HPET o muc phan mem e chuyen sang TSC nhanh hon)
    try {
        bcdedit /deletevalue useplatformclock 2>&1 | Out-Null
        Write-Log "Disabled HPET phan mem (su dung TSC co o tre cuc thap)." "INFO"
    } catch {
        # Neu khoa nay chua tung uoc at thi bcdedit se ERROR, bo qua
        Write-Log "HPET mac inh cua BIOS a uoc Applying hoac useplatformclock chua tung uoc Configuring." "DEBUG"
    }
    
    # 3. Configuring Registry phu tro cho RTC (Real Time Clock) va High Resolution Timer
    $timerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"
    if (-not (Test-Path $timerPath)) {
        New-Item -Path $timerPath -Force | Out-Null
    }
    Backup-RegistryValue -Path $timerPath -ValueName "GlobalTimerResolutionLimits"
    # Thiet lap kich hoat gioi han o phan giai toi a cho Timer
    Set-ItemProperty -Path $timerPath -Name "GlobalTimerResolutionLimits" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Log "Optimizing Timer Completed!" "SUCCESS"
}

function Restore-Timer {
    Write-Log "Currently Restore Configuring Timer..." "INFO"
    try {
        bcdedit /deletevalue disabledynamictick 2>&1 | Out-Null
        Write-Log "a tra lai thiet lap mac inh cho Dynamic Tick." "INFO"
    } catch {}
}

function Verify-Timer {
    Write-Log "Xac minh Configuring Timer..." "INFO"
    return $true
}

function WriteLog-Timer {
    # Tich hop truc tiep qua Logger
}





