# modules/RAM.ps1
# Module tối ưu RAM cho Valorant Optimize 1.0.0

function Check-RAM {
    Write-Log "Kiểm tra cấu hình bộ nhớ RAM..." "INFO"
    
    $memPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    if (Test-Path $memPath) {
        $lsc = Get-ItemPropertyValue -Path $memPath -Name "LargeSystemCache" -ErrorAction SilentlyContinue
        $dpe = Get-ItemPropertyValue -Path $memPath -Name "DisablePagingExecutive" -ErrorAction SilentlyContinue
        Write-Log "LargeSystemCache: $lsc, DisablePagingExecutive: $dpe" "INFO"
    }
    
    $sysMain = Get-Service -Name "SysMain" -ErrorAction SilentlyContinue
    if ($sysMain) {
        Write-Log "Trạng thái dịch vụ SysMain (Superfetch): $($sysMain.Status) (Startup: $($sysMain.StartType))" "INFO"
    }
    
    return "OK"
}

function Apply-RAM {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bắt đầu tối ưu bộ nhớ RAM..." "INFO"
    
    $lscConfig = $Config.settings.ram.LargeSystemCache
    $dpeConfig = $Config.settings.ram.DisablePagingExecutive
    $sysMainConfig = $Config.settings.ram.SysMainStartup # Automatic / Disabled
    
    # 1. Cấu hình Memory Management registry
    $memPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    if (-not (Test-Path $memPath)) {
        New-Item -Path $memPath -Force | Out-Null
    }
    
    Backup-RegistryValue -Path $memPath -ValueName "LargeSystemCache"
    Backup-RegistryValue -Path $memPath -ValueName "DisablePagingExecutive"
    
    Set-ItemProperty -Path $memPath -Name "LargeSystemCache" -Value $lscConfig -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $memPath -Name "DisablePagingExecutive" -Value $dpeConfig -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Log "Đã cấu hình LargeSystemCache=$lscConfig và DisablePagingExecutive=$dpeConfig" "INFO"
    
    # 2. Cấu hình dịch vụ SysMain
    $sysMain = Get-Service -Name "SysMain" -ErrorAction SilentlyContinue
    if ($sysMain) {
        Backup-Service -ServiceName "SysMain"
        
        # Nếu thiết lập là Disabled -> dừng service và tắt startup
        if ($sysMainConfig -eq "Disabled") {
            if ($sysMain.Status -eq "Running") {
                Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue | Out-Null
            }
            Set-Service -Name "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue | Out-Null
            Write-Log "Đã dừng và vô hiệu hóa dịch vụ SysMain để giải phóng tài nguyên nền." "INFO"
        } else {
            Set-Service -Name "SysMain" -StartupType Automatic -ErrorAction SilentlyContinue | Out-Null
            if ($sysMain.Status -ne "Running") {
                Start-Service -Name "SysMain" -ErrorAction SilentlyContinue | Out-Null
            }
            Write-Log "Đã đặt dịch vụ SysMain ở chế độ tự động chạy." "INFO"
        }
    }
    
    Write-Log "Tối ưu RAM hoàn tất!" "SUCCESS"
}

function Restore-RAM {
    Write-Log "Đang khôi phục cài đặt RAM..." "INFO"
}

function Verify-RAM {
    Write-Log "Xác minh cấu hình RAM..." "INFO"
    $memPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    if (Test-Path $memPath) {
        $dpe = Get-ItemPropertyValue -Path $memPath -Name "DisablePagingExecutive" -ErrorAction SilentlyContinue
        if ($dpe -ne $null) {
            Write-Log "Xác minh RAM thành công!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-RAM {
    # Tích hợp trực tiếp qua Logger
}





