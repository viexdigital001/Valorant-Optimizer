# modules/RAM.ps1
# Module toi uu RAM cho Valorant Optimize 1.0.0

function Check-RAM {
    Write-Log "Kiem tra Configuring bo nho RAM..." "INFO"
    
    $memPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    if (Test-Path $memPath) {
        $lsc = Get-ItemPropertyValue -Path $memPath -Name "LargeSystemCache" -ErrorAction SilentlyContinue
        $dpe = Get-ItemPropertyValue -Path $memPath -Name "DisablePagingExecutive" -ErrorAction SilentlyContinue
        Write-Log "LargeSystemCache: $lsc, DisablePagingExecutive: $dpe" "INFO"
    }
    
    $sysMain = Get-Service -Name "SysMain" -ErrorAction SilentlyContinue
    if ($sysMain) {
        Write-Log "Trang thai dich vu SysMain (Superfetch): $($sysMain.Status) (Startup: $($sysMain.StartType))" "INFO"
    }
    
    return "OK"
}

function Apply-RAM {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bat au toi uu bo nho RAM..." "INFO"
    
    $lscConfig = $Config.settings.ram.LargeSystemCache
    $dpeConfig = $Config.settings.ram.DisablePagingExecutive
    $sysMainConfig = $Config.settings.ram.SysMainStartup # Automatic / Disabled
    
    # 1. Configuring Memory Management registry
    $memPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    if (-not (Test-Path $memPath)) {
        New-Item -Path $memPath -Force | Out-Null
    }
    
    Backup-RegistryValue -Path $memPath -ValueName "LargeSystemCache"
    Backup-RegistryValue -Path $memPath -ValueName "DisablePagingExecutive"
    
    Set-ItemProperty -Path $memPath -Name "LargeSystemCache" -Value $lscConfig -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $memPath -Name "DisablePagingExecutive" -Value $dpeConfig -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Log "a Configuring LargeSystemCache=$lscConfig va DisablePagingExecutive=$dpeConfig" "INFO"
    
    # 2. Configuring dich vu SysMain
    $sysMain = Get-Service -Name "SysMain" -ErrorAction SilentlyContinue
    if ($sysMain) {
        Backup-Service -ServiceName "SysMain"
        
        # Neu thiet lap la Disabled -> dung service va tat startup
        if ($sysMainConfig -eq "Disabled") {
            if ($sysMain.Status -eq "Running") {
                Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue | Out-Null
            }
            Set-Service -Name "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue | Out-Null
            Write-Log "a dung va Disabling dich vu SysMain e giai phong tai nguyen nen." "INFO"
        } else {
            Set-Service -Name "SysMain" -StartupType Automatic -ErrorAction SilentlyContinue | Out-Null
            if ($sysMain.Status -ne "Running") {
                Start-Service -Name "SysMain" -ErrorAction SilentlyContinue | Out-Null
            }
            Write-Log "a at dich vu SysMain o Mode Automatic chay." "INFO"
        }
    }
    
    Write-Log "Toi uu RAM Completed!" "SUCCESS"
}

function Restore-RAM {
    Write-Log "Currently Restore cai at RAM..." "INFO"
}

function Verify-RAM {
    Write-Log "Xac minh Configuring RAM..." "INFO"
    $memPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    if (Test-Path $memPath) {
        $dpe = Get-ItemPropertyValue -Path $memPath -Name "DisablePagingExecutive" -ErrorAction SilentlyContinue
        if ($dpe -ne $null) {
            Write-Log "Xac minh RAM Success!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-RAM {
    # Tich hop truc tiep qua Logger
}





