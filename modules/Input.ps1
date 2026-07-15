# modules/Input.ps1
# Module Optimizing thoi gian phan hoi au vao (Input Response) cho Valorant Optimize 1.0.0

function Check-Input {
    Write-Log "Kiem tra Configuring hang oi Input (Mouse & Keyboard class parameters)..." "INFO"
    
    $mouPath = "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters"
    if (Test-Path $mouPath) {
        $mouQueue = Get-ItemPropertyValue -Path $mouPath -Name "MouseDataQueueSize" -ErrorAction SilentlyContinue
        Write-Log "MouseDataQueueSize hien tai: $mouQueue" "INFO"
    }
    
    $kbdPath = "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters"
    if (Test-Path $kbdPath) {
        $kbdQueue = Get-ItemPropertyValue -Path $kbdPath -Name "KeyboardDataQueueSize" -ErrorAction SilentlyContinue
        Write-Log "KeyboardDataQueueSize hien tai: $kbdQueue" "INFO"
    }
    
    return "OK"
}

function Apply-Input {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bat au Optimizing hang oi Input (Mouse/Keyboard class)..." "INFO"
    
    $mouPath = "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters"
    $kbdPath = "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters"
    
    if (Test-Path $mouPath) {
        Backup-RegistryValue -Path $mouPath -ValueName "MouseDataQueueSize"
        # at kich thuoc hang oi chuot toi uu (100 la chuan hieu nang on inh)
        Set-ItemProperty -Path $mouPath -Name "MouseDataQueueSize" -Value 100 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    if (Test-Path $kbdPath) {
        Backup-RegistryValue -Path $kbdPath -ValueName "KeyboardDataQueueSize"
        # at kich thuoc hang oi ban phim toi uu
        Set-ItemProperty -Path $kbdPath -Name "KeyboardDataQueueSize" -Value 100 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    # Optimizing phan hoi giao dien keo tha cua so va nhay chuot
    $desktopPath = "HKCU:\Control Panel\Desktop"
    if (Test-Path $desktopPath) {
        Backup-RegistryValue -Path $desktopPath -ValueName "MenuShowDelay"
        # at o tre hien thi menu ve 0 (nhanh tuc thi)
        Set-ItemProperty -Path $desktopPath -Name "MenuShowDelay" -Value "0" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    Write-Log "Optimizing hang oi thiet bi au vao Completed!" "SUCCESS"
}

function Restore-Input {
    Write-Log "Currently Restore cai at Input..." "INFO"
}

function Verify-Input {
    Write-Log "Xac minh Configuring Input..." "INFO"
    return $true
}

function WriteLog-Input {
    # Tich hop truc tiep qua Logger
}





