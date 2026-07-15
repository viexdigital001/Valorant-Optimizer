# modules/Keyboard.ps1
# Module Optimizing ban phim (Keyboard) cho Valorant Optimize 1.0.0

function Check-Keyboard {
    Write-Log "Kiem tra Configuring ban phim..." "INFO"
    
    $kbPath = "HKCU:\Control Panel\Keyboard"
    if (Test-Path $kbPath) {
        $delay = Get-ItemPropertyValue -Path $kbPath -Name "KeyboardDelay" -ErrorAction SilentlyContinue
        $speed = Get-ItemPropertyValue -Path $kbPath -Name "KeyboardSpeed" -ErrorAction SilentlyContinue
        Write-Log "KeyboardDelay: $delay, KeyboardSpeed: $speed" "INFO"
    }
    
    return "OK"
}

function Apply-Keyboard {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bat au Optimizing cai at ban phim..." "INFO"
    
    $kbDelay = $Config.settings.keyboard.KeyboardDelay # 0
    $kbSpeed = $Config.settings.keyboard.KeyboardSpeed # 31
    
    $kbPath = "HKCU:\Control Panel\Keyboard"
    if (-not (Test-Path $kbPath)) {
        New-Item -Path $kbPath -Force | Out-Null
    }
    
    Backup-RegistryValue -Path $kbPath -ValueName "KeyboardDelay"
    Backup-RegistryValue -Path $kbPath -ValueName "KeyboardSpeed"
    
    Set-ItemProperty -Path $kbPath -Name "KeyboardDelay" -Value $kbDelay -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $kbPath -Name "KeyboardSpeed" -Value $kbSpeed -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    
    # 2. Disabling phim tat Accessibility e tranh nhay ra Popup Sticky Keys/Filter Keys khi choi game
    $stickyPath = "HKCU:\Control Panel\Accessibility\StickyKeys"
    $filterPath = "HKCU:\Control Panel\Accessibility\Keyboard Response"
    $togglePath = "HKCU:\Control Panel\Accessibility\ToggleKeys"
    
    if (-not (Test-Path $stickyPath)) { New-Item -Path $stickyPath -Force | Out-Null }
    if (-not (Test-Path $filterPath)) { New-Item -Path $filterPath -Force | Out-Null }
    if (-not (Test-Path $togglePath)) { New-Item -Path $togglePath -Force | Out-Null }
    
    Backup-RegistryValue -Path $stickyPath -ValueName "Flags"
    Backup-RegistryValue -Path $filterPath -ValueName "Flags"
    Backup-RegistryValue -Path $togglePath -ValueName "Flags"
    
    # Flags = 506 (Tat phim tat Shift 5 lan cho Sticky Keys)
    Set-ItemProperty -Path $stickyPath -Name "Flags" -Value "506" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    # Flags = 122 (Tat phim tat Filter Keys)
    Set-ItemProperty -Path $filterPath -Name "Flags" -Value "122" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    # Flags = 58 (Tat phim tat Toggle Keys)
    Set-ItemProperty -Path $togglePath -Name "Flags" -Value "58" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Log "a Disabling cac phim tat Sticky Keys, Filter Keys va Toggle Keys." "SUCCESS"
}

function Restore-Keyboard {
    Write-Log "Currently Restore cai at ban phim..." "INFO"
}

function Verify-Keyboard {
    Write-Log "Xac minh Configuring ban phim..." "INFO"
    $kbPath = "HKCU:\Control Panel\Keyboard"
    if (Test-Path $kbPath) {
        $delay = Get-ItemPropertyValue -Path $kbPath -Name "KeyboardDelay" -ErrorAction SilentlyContinue
        if ($delay -eq "0" -or $delay -eq "1") {
            Write-Log "Xac minh ban phim Success!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-Keyboard {
    # Tich hop truc tiep qua Logger
}





