# modules/CPU.ps1
# Module toi uu CPU cho Valorant Optimize 1.0.0

function Check-CPU {
    Write-Log "Kiem tra Configuring CPU hien tai..." "INFO"
    $status = "OK"
    
    # Kiem tra Win32PrioritySeparation
    $priPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    if (Test-Path $priPath) {
        $val = Get-ItemPropertyValue -Path $priPath -Name "Win32PrioritySeparation" -ErrorAction SilentlyContinue
        Write-Log "Win32PrioritySeparation hien tai: $val" "INFO"
    }
    
    # Kiem tra Configuring uu tien tien trinh cho Valorant
    $valPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\VALORANT-Win64-Shipping.exe\PerfOptions"
    if (Test-Path $valPath) {
        $cpuPri = Get-ItemPropertyValue -Path $valPath -Name "CpuPriorityClass" -ErrorAction SilentlyContinue
        $ioPri = Get-ItemPropertyValue -Path $valPath -Name "IoPriority" -ErrorAction SilentlyContinue
        Write-Log "o uu tien CPU Valorant hien tai: $cpuPri, IO: $ioPri" "INFO"
    } else {
        Write-Log "Chua Configuring o uu tien rieng cho Valorant." "INFO"
    }
    
    return $status
}

function Apply-CPU {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bat au toi uu CPU..." "INFO"
    
    # Lay cac thiet lap tu config profile
    $win32Pri = $Config.settings.cpu.Win32PrioritySeparation
    $priority = $Config.settings.cpu.Priority # High
    $ioPriority = $Config.settings.cpu.IoPriority # High
    
    # 1. Toi uu Win32PrioritySeparation
    $priPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    if (-not (Test-Path $priPath)) {
        New-Item -Path $priPath -Force | Out-Null
    }
    Backup-RegistryValue -Path $priPath -ValueName "Win32PrioritySeparation"
    Set-ItemProperty -Path $priPath -Name "Win32PrioritySeparation" -Value $win32Pri -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    Write-Log "a Configuring Win32PrioritySeparation thanh $win32Pri" "INFO"
    
    # 2. Toi uu o uu tien cua Valorant
    $valPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\VALORANT-Win64-Shipping.exe\PerfOptions"
    if (-not (Test-Path $valPath)) {
        New-Item -Path $valPath -Force | Out-Null
    }
    
    # CpuPriorityClass: 3 = High, 6 = AboveNormal
    $cpuPriVal = 3
    if ($priority -eq "AboveNormal") { $cpuPriVal = 6 }
    
    # IoPriority: 3 = High, 2 = Normal
    $ioPriVal = 3
    if ($ioPriority -eq "Normal") { $ioPriVal = 2 }
    
    Backup-RegistryValue -Path $valPath -ValueName "CpuPriorityClass"
    Backup-RegistryValue -Path $valPath -ValueName "IoPriority"
    
    Set-ItemProperty -Path $valPath -Name "CpuPriorityClass" -Value $cpuPriVal -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $valPath -Name "IoPriority" -Value $ioPriVal -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Log "a Configuring CPU Priority Class = $cpuPriVal va IO Priority = $ioPriVal cho Valorant" "SUCCESS"
}

function Restore-CPU {
    Write-Log "Currently Restore cai at CPU..." "INFO"
    # Logic Restore toan cuc se nap va xu ly tu snapshot backup
}

function Verify-CPU {
    Write-Log "Xac minh Configuring CPU..." "INFO"
    $priPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    $valPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\VALORANT-Win64-Shipping.exe\PerfOptions"
    
    $check1 = $false
    $check2 = $false
    
    if (Test-Path $priPath) {
        $val = Get-ItemPropertyValue -Path $priPath -Name "Win32PrioritySeparation" -ErrorAction SilentlyContinue
        if ($val -ne $null) { $check1 = $true }
    }
    if (Test-Path $valPath) {
        $cpu = Get-ItemPropertyValue -Path $valPath -Name "CpuPriorityClass" -ErrorAction SilentlyContinue
        if ($cpu -eq 3 -or $cpu -eq 6) { $check2 = $true }
    }
    
    if ($check1 -and $check2) {
        Write-Log "Xac minh CPU Success!" "SUCCESS"
        return $true
    }
    Write-Log "Xac minh CPU that bai hoac chua hoan thanh." "WARNING"
    return $false
}

function WriteLog-CPU {
    # Tich hop truc tiep qua Logger
}





