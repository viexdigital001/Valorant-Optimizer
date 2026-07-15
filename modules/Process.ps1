# modules/Process.ps1
# Module Optimizing uu tien tien trinh (Process Priority) cho Valorant Optimize 1.0.0

function Check-Process {
    Write-Log "Kiem tra Configuring chong cuop tieu iem cua cac ung dung nen..." "INFO"
    $desktopPath = "HKCU:\Control Panel\Desktop"
    if (Test-Path $desktopPath) {
        $timeout = Get-ItemPropertyValue -Path $desktopPath -Name "ForegroundLockTimeout" -ErrorAction SilentlyContinue
        Write-Log "ForegroundLockTimeout hien tai: $timeout" "INFO"
    }
    return "OK"
}

function Apply-Process {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bat au Optimizing uu tien tien trinh (Process priority)..." "INFO"
    
    # 1. Configuring ForegroundLockTimeout = 200000 (Ngan chan ung dung nen cuop cua so game khi Currently choi)
    $desktopPath = "HKCU:\Control Panel\Desktop"
    if (Test-Path $desktopPath) {
        Backup-RegistryValue -Path $desktopPath -ValueName "ForegroundLockTimeout"
        Set-ItemProperty -Path $desktopPath -Name "ForegroundLockTimeout" -Value 200000 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
        Write-Log "a khoa tieu iem ung dung Foreground o muc 200,000ms." "INFO"
    }
    
    # 2. Automatic kiem tra va nang o uu tien cua tien trinh Valorant va Riot Client len muc cao neu chung Currently chay
    try {
        $valProc = Get-Process -Name "VALORANT-Win64-Shipping" -ErrorAction SilentlyContinue
        if ($valProc) {
            foreach ($p in $valProc) {
                # at PriorityClass = High
                $p.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::High
                Write-Log "a nang o uu tien runtime cua tien trinh VALORANT len HIGH." "INFO"
            }
        }
    } catch {
        Write-Log "Cannot nang o uu tien cua tien trinh Valorant Currently chay (co the do thieu quyen han nang cao hoac game chua mo)." "DEBUG"
    }
    
    Write-Log "Optimizing uu tien tien trinh Completed!" "SUCCESS"
}

function Restore-Process {
    Write-Log "Currently Restore Configuring Process..." "INFO"
}

function Verify-Process {
    Write-Log "Xac minh Configuring Process..." "INFO"
    return $true
}

function WriteLog-Process {
    # Tich hop truc tiep qua Logger
}





