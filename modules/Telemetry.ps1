# modules/Telemetry.ps1
# Module Disabling thu thap du lieu (Telemetry) cho Valorant Optimize 1.0.0

function Check-Telemetry {
    Write-Log "Kiem tra Configuring Telemetry..." "INFO"
    
    $telPath1 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    if (Test-Path $telPath1) {
        $val = Get-ItemPropertyValue -Path $telPath1 -Name "AllowTelemetry" -ErrorAction SilentlyContinue
        Write-Log "AllowTelemetry (Policies): $val" "INFO"
    }
    
    return "OK"
}

function Apply-Telemetry {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bat au Disabling Windows Telemetry..." "INFO"
    
    $disableTelemetry = $Config.settings.telemetry.DisableTelemetry
    if (-not $disableTelemetry) {
        Write-Log "Bo qua Configuring Telemetry." "WARNING"
        return
    }
    
    $telPath1 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $telPath2 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    
    if (-not (Test-Path $telPath1)) { New-Item -Path $telPath1 -Force | Out-Null }
    if (-not (Test-Path $telPath2)) { New-Item -Path $telPath2 -Force | Out-Null }
    
    Backup-RegistryValue -Path $telPath1 -ValueName "AllowTelemetry"
    Backup-RegistryValue -Path $telPath2 -ValueName "AllowTelemetry"
    
    # at AllowTelemetry = 0 e tat
    Set-ItemProperty -Path $telPath1 -Name "AllowTelemetry" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $telPath2 -Name "AllowTelemetry" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    # Tat Customer Experience Improvement Program (CEIP)
    $sqmPath = "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows"
    if (-not (Test-Path $sqmPath)) { New-Item -Path $sqmPath -Force | Out-Null }
    Backup-RegistryValue -Path $sqmPath -ValueName "CEIPEnable"
    Set-ItemProperty -Path $sqmPath -Name "CEIPEnable" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    # Tat ung dung khoi chay theo doi (App Launch Tracking)
    $actPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    if (Test-Path $actPath) {
        Backup-RegistryValue -Path $actPath -ValueName "Start_TrackProgs"
        Set-ItemProperty -Path $actPath -Name "Start_TrackProgs" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    Write-Log "Disabling Telemetry Completed!" "SUCCESS"
}

function Restore-Telemetry {
    Write-Log "Currently Restore cai at Telemetry..." "INFO"
}

function Verify-Telemetry {
    Write-Log "Xac minh Configuring Telemetry..." "INFO"
    $telPath1 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    if (Test-Path $telPath1) {
        $val = Get-ItemPropertyValue -Path $telPath1 -Name "AllowTelemetry" -ErrorAction SilentlyContinue
        if ($val -eq 0) {
            Write-Log "Xac minh Telemetry Success!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-Telemetry {
    # Tich hop truc tiep qua Logger
}





