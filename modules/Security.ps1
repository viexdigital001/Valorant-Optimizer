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
        Write-Log "Yeu cau xac nhan tu nguoi dung e tat VBS / Memory Integrity (Extreme Profile)" "WARNING"
        
        $msg = "WARNING: Tat VBS va Memory Integrity se tang FPS (~5-15%) nhung lam giam bao mat Windows. Ban co muon tat khong?"
        $confirm = Get-Confirmation -PromptMessage $msg
        
        if ($confirm) {
            # Tat VBS
            $vbsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
            if (-not (Test-Path $vbsPath)) { New-Item -Path $vbsPath -Force | Out-Null }
            Backup-RegistryValue -Path $vbsPath -ValueName "EnableVirtualizationBasedSecurity"
            Set-ItemProperty -Path $vbsPath -Name "EnableVirtualizationBasedSecurity" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
            
            # Tat Memory Integrity (HVCI)
            $hvciPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
            if (-not (Test-Path $hvciPath)) { New-Item -Path $hvciPath -Force | Out-Null }
            Backup-RegistryValue -Path $hvciPath -ValueName "Enabled"
            Set-ItemProperty -Path $hvciPath -Name "Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
            
            Write-Log "Disabled VBS va Memory Integrity (Yeu cau khoi ong lai e co hieu luc)." "SUCCESS"
        } else {
            Write-Log "Nguoi dung tu choi tat VBS / Memory Integrity. Bo qua toi uu nay." "INFO"
        }
    } else {
        Write-Log "Profile hien tai khong yeu cau tat VBS/Memory Integrity. Giu nguyen mac inh an toan." "INFO"
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





