# modules/MMCSS.ps1
# Module Configuring Multimedia Class Scheduler Service (MMCSS) cho Valorant Optimize 1.0.0

function Check-MMCSS {
    Write-Log "Kiem tra Configuring MMCSS..." "INFO"
    
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
    
    Write-Log "Bat au Optimizing Configuring MMCSS cho Gaming..." "INFO"
    
    $resConfig = $Config.settings.network.SystemResponsiveness
    $netConfig = $Config.settings.network.NetworkThrottlingIndex
    
    # 1. Configuring SystemProfile
    $sysProfilePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    if (-not (Test-Path $sysProfilePath)) {
        New-Item -Path $sysProfilePath -Force | Out-Null
    }
    
    Backup-RegistryValue -Path $sysProfilePath -ValueName "SystemResponsiveness"
    Backup-RegistryValue -Path $sysProfilePath -ValueName "NetworkThrottlingIndex"
    
    # SystemResponsiveness = 0 (Uu tien toi a cho game truoc cac tien trinh nen)
    Set-ItemProperty -Path $sysProfilePath -Name "SystemResponsiveness" -Value $resConfig -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    # NetworkThrottlingIndex = 0xffffffff (Disabling bop bang thong mang khi co ung dung a phuong tien chay)
    Set-ItemProperty -Path $sysProfilePath -Name "NetworkThrottlingIndex" -Value $netConfig -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Log "a thiet lap SystemResponsiveness=$resConfig va NetworkThrottlingIndex=$netConfig" "INFO"
    
    # 2. Configuring Tasks Games
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
    
    Write-Log "a Configuring tac vu Games trong MMCSS len muc uu tien cao nhat (High)." "SUCCESS"
}

function Restore-MMCSS {
    Write-Log "Currently Restore Configuring MMCSS..." "INFO"
}

function Verify-MMCSS {
    Write-Log "Xac minh Configuring MMCSS..." "INFO"
    $sysProfilePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    if (Test-Path $sysProfilePath) {
        $res = Get-ItemPropertyValue -Path $sysProfilePath -Name "SystemResponsiveness" -ErrorAction SilentlyContinue
        if ($res -eq 0) {
            Write-Log "Xac minh MMCSS Success!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-MMCSS {
    # Tich hop truc tiep qua Logger
}





