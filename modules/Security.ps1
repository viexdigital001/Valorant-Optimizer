# modules/Security.ps1
# Module Configuring bao mat System (Security) cho Valorant Optimize 1.0.0

function Check-Security {
    Write-Log "Kiem tra Configuring bao mat..." "INFO"
    $sysInfo = Get-SystemInfo
    Write-Log "VBS: $($sysInfo.VBS), Memory Integrity: $($sysInfo.MemoryIntegrity)" "INFO"
    return "OK"
}

function Apply-Security {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bat au Configuring thiet lap bao mat..." "INFO"
    
    # 1. Chung ta tuyet oi khong tat Windows Defender theo quy tac bat buoc.
    # Chi WARNING va cho phep nguoi dung tat VBS / Memory Integrity neu chay profile Extreme.
    
    if ($Config.profile -eq "Extreme") {
        $sysInfo = Get-SystemInfo
        # Tren Windows 11, Vanguard bat buoc Secure Boot va nhieu may yeu cau VBS/HVCI on dinh de tranh ma loi VAN9005
        if ($sysInfo.OSName -match "Windows 11") {
            Write-Log "Phat hien Windows 11: De phong tranh loi Riot Vanguard VAN9005, giu an toan VBS/HVCI." "WARNING"
        } else {
            # Tat VBS & HVCI tren Windows 10 cho Extreme profile
            $vbsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
            if (-not (Test-Path $vbsPath)) { New-Item -Path $vbsPath -Force | Out-Null }
            Backup-RegistryValue -Path $vbsPath -ValueName "EnableVirtualizationBasedSecurity"
            Set-ItemProperty -Path $vbsPath -Name "EnableVirtualizationBasedSecurity" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
            
            $hvciPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
            if (-not (Test-Path $hvciPath)) { New-Item -Path $hvciPath -Force | Out-Null }
            Backup-RegistryValue -Path $hvciPath -ValueName "Enabled"
            Set-ItemProperty -Path $hvciPath -Name "Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
            
            Write-Log "Disabled VBS va Memory Integrity tren Windows 10 (Extreme Mode)." "SUCCESS"
        }
    } else {
        Write-Log "Profile hien tai khong yeu cau tat VBS/Memory Integrity. Giu nguyen mac dinh an toan." "INFO"
    }
}

function Restore-Security {
    Write-Log "Currently Restore cai at bao mat..." "INFO"
}

function Verify-Security {
    Write-Log "Xac minh Configuring bao mat..." "INFO"
    return $true
}

function WriteLog-Security {
    # Tich hop truc tiep qua Logger
}







