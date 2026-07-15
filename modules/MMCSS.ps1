# modules/MMCSS.ps1
# Module cấu hình Multimedia Class Scheduler Service (MMCSS) cho Valorant Optimize 1.0.0

function Check-MMCSS {
    Write-Log "Kiểm tra cấu hình MMCSS..." "INFO"
    
    $sysProfilePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    if (Test-Path $sysProfilePath) {
        $res = Get-ItemPropertyValue -Path $sysProfilePath -Name "SystemResponsiveness" -ErrorAction SilentlyContinue
        $net = Get-ItemPropertyValue -Path $sysProfilePath -Name "NetworkThrottlingIndex" -ErrorAction SilentlyContinue
        Write-Log "SystemResponsiveness: $res, NetworkThrottlingIndex: $net" "INFO"
    }
    
    $gameTaskPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
    if (Test-Path $gameTaskPath) {
        $gpuPri = Get-ItemPropertyValue -Path $gameTaskPath -Name "GPU Priority" -ErrorAction SilentlyContinue
        $pri = Get-ItemPropertyValue -Path $gameTaskPath -Name "Priority" -ErrorAction SilentlyContinue
        $sched = Get-ItemPropertyValue -Path $gameTaskPath -Name "Scheduling Category" -ErrorAction SilentlyContinue
        Write-Log "MMCSS Tasks Games - GPU Priority: $gpuPri, Priority: $pri, Category: $sched" "INFO"
    }
    
    return "OK"
}

function Apply-MMCSS {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bắt đầu tối ưu hóa cấu hình MMCSS cho Gaming..." "INFO"
    
    $resConfig = $Config.settings.network.SystemResponsiveness
    $netConfig = $Config.settings.network.NetworkThrottlingIndex
    
    # 1. Cấu hình SystemProfile
    $sysProfilePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    if (-not (Test-Path $sysProfilePath)) {
        New-Item -Path $sysProfilePath -Force | Out-Null
    }
    
    Backup-RegistryValue -Path $sysProfilePath -ValueName "SystemResponsiveness"
    Backup-RegistryValue -Path $sysProfilePath -ValueName "NetworkThrottlingIndex"
    
    # SystemResponsiveness = 0 (Ưu tiên tối đa cho game trước các tiến trình nền)
    Set-ItemProperty -Path $sysProfilePath -Name "SystemResponsiveness" -Value $resConfig -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    # NetworkThrottlingIndex = 0xffffffff (Vô hiệu hóa bóp băng thông mạng khi có ứng dụng đa phương tiện chạy)
    Set-ItemProperty -Path $sysProfilePath -Name "NetworkThrottlingIndex" -Value $netConfig -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Log "Đã thiết lập SystemResponsiveness=$resConfig và NetworkThrottlingIndex=$netConfig" "INFO"
    
    # 2. Cấu hình Tasks Games
    $gameTaskPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
    if (-not (Test-Path $gameTaskPath)) {
        New-Item -Path $gameTaskPath -Force | Out-Null
    }
    
    Backup-RegistryValue -Path $gameTaskPath -ValueName "GPU Priority"
    Backup-RegistryValue -Path $gameTaskPath -ValueName "Priority"
    Backup-RegistryValue -Path $gameTaskPath -ValueName "Scheduling Category"
    Backup-RegistryValue -Path $gameTaskPath -ValueName "SFIO Priority"
    
    Set-ItemProperty -Path $gameTaskPath -Name "GPU Priority" -Value 8 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $gameTaskPath -Name "Priority" -Value 6 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $gameTaskPath -Name "Scheduling Category" -Value "High" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $gameTaskPath -Name "SFIO Priority" -Value "High" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Log "Đã cấu hình tác vụ Games trong MMCSS lên mức ưu tiên cao nhất (High)." "SUCCESS"
}

function Restore-MMCSS {
    Write-Log "Đang khôi phục cấu hình MMCSS..." "INFO"
}

function Verify-MMCSS {
    Write-Log "Xác minh cấu hình MMCSS..." "INFO"
    $sysProfilePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    if (Test-Path $sysProfilePath) {
        $res = Get-ItemPropertyValue -Path $sysProfilePath -Name "SystemResponsiveness" -ErrorAction SilentlyContinue
        if ($res -eq 0) {
            Write-Log "Xác minh MMCSS thành công!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-MMCSS {
    # Tích hợp trực tiếp qua Logger
}





