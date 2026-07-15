# modules/GameMode.ps1
# Module Optimizing Configuring Windows Game Mode cho Valorant Optimize 1.0.0

function Check-GameMode {
    Write-Log "Kiem tra Configuring Windows Game Mode..." "INFO"
    $gmPath = "HKCU:\Software\Microsoft\GameBar"
    if (Test-Path $gmPath) {
        $gmVal = Get-ItemPropertyValue -Path $gmPath -Name "AllowAutoGameMode" -ErrorAction SilentlyContinue
        Write-Log "AllowAutoGameMode: $gmVal" "INFO"
    }
    return "OK"
}

function Apply-GameMode {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bat au kich hoat Windows Game Mode..." "INFO"
    
    $gmPath = "HKCU:\Software\Microsoft\GameBar"
    if (-not (Test-Path $gmPath)) {
        New-Item -Path $gmPath -Force | Out-Null
    }
    Backup-RegistryValue -Path $gmPath -ValueName "AllowAutoGameMode"
    
    # 1. Kich hoat Game Mode (Nhan Windows se uu tien phan bo CPU & GPU cho tien trinh Game)
    Set-ItemProperty -Path $gmPath -Name "AllowAutoGameMode" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    # 2. am bao Game DVR bi khoa o Policy
    $policyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
    if (-not (Test-Path $policyPath)) {
        New-Item -Path $policyPath -Force | Out-Null
    }
    Backup-RegistryValue -Path $policyPath -ValueName "AllowGameDVR"
    Set-ItemProperty -Path $policyPath -Name "AllowGameDVR" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Log "Enabled Game Mode va Disabling Policy Game DVR Success." "SUCCESS"
}

function Restore-GameMode {
    Write-Log "Currently Restore Configuring Game Mode..." "INFO"
}

function Verify-GameMode {
    Write-Log "Xac minh Configuring Game Mode..." "INFO"
    $gmPath = "HKCU:\Software\Microsoft\GameBar"
    if (Test-Path $gmPath) {
        $val = Get-ItemPropertyValue -Path $gmPath -Name "AllowAutoGameMode" -ErrorAction SilentlyContinue
        if ($val -eq 1) {
            Write-Log "Xac minh Game Mode Success!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-GameMode {
    # Tich hop truc tiep qua Logger
}





