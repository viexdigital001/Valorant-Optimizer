# modules/Xbox.ps1
# Module Disabling dich vu Xbox chay nen va Game DVR cho Valorant Optimize 1.0.0

function Check-Xbox {
    Write-Log "Kiem tra Configuring Xbox Game DVR..." "INFO"
    $gcsPath = "HKCU:\System\GameConfigStore"
    if (Test-Path $gcsPath) {
        $enabled = Get-ItemPropertyValue -Path $gcsPath -Name "GameDVR_Enabled" -ErrorAction SilentlyContinue
        Write-Log "GameDVR_Enabled: $enabled" "INFO"
    }
    return "OK"
}

function Apply-Xbox {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bat au tat Game DVR va cac dich vu Xbox khong su dung..." "INFO"
    
    # 1. Tat Game DVR trong GameConfigStore
    $gcsPath = "HKCU:\System\GameConfigStore"
    if (Test-Path $gcsPath) {
        Backup-RegistryValue -Path $gcsPath -ValueName "GameDVR_Enabled"
        Backup-RegistryValue -Path $gcsPath -ValueName "GameDVR_FSEBehaviorMode"
        
        Set-ItemProperty -Path $gcsPath -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
        # FSEBehaviorMode = 2 (Disabling Optimizing toan man hinh cu)
        Set-ItemProperty -Path $gcsPath -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    # 2. Tat Capture am thanh/hinh anh cua Xbox App Capture
    $dvrPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"
    if (-not (Test-Path $dvrPath)) {
        New-Item -Path $dvrPath -Force | Out-Null
    }
    Backup-RegistryValue -Path $dvrPath -ValueName "AppCaptureEnabled"
    Backup-RegistryValue -Path $dvrPath -ValueName "AudioCaptureEnabled"
    
    Set-ItemProperty -Path $dvrPath -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $dvrPath -Name "AudioCaptureEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    # 3. Tat cac dich vu Xbox neu nguoi dung Tryhard (e tranh no lien tuc tham do trong luc choi game)
    $xboxServices = @("XblAuthManager", "XblGameSave", "XboxNetApiSvc", "XboxGipSvc")
    foreach ($srvName in $xboxServices) {
        $srv = Get-Service -Name $srvName -ErrorAction SilentlyContinue
        if ($srv) {
            Backup-Service -ServiceName $srvName
            if ($srv.Status -eq "Running") {
                Stop-Service -Name $srvName -Force -ErrorAction SilentlyContinue | Out-Null
            }
            Set-Service -Name $srvName -StartupType Disabled -ErrorAction SilentlyContinue | Out-Null
            Write-Log "a Disabling dich vu Xbox: $srvName" "INFO"
        }
    }
    
    Write-Log "Disabling Game DVR va Xbox Services Completed!" "SUCCESS"
}

function Restore-Xbox {
    Write-Log "Currently Restore Configuring Xbox..." "INFO"
}

function Verify-Xbox {
    Write-Log "Xac minh Configuring Xbox..." "INFO"
    $gcsPath = "HKCU:\System\GameConfigStore"
    if (Test-Path $gcsPath) {
        $enabled = Get-ItemPropertyValue -Path $gcsPath -Name "GameDVR_Enabled" -ErrorAction SilentlyContinue
        if ($enabled -eq 0) {
            Write-Log "Xac minh Xbox Success!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-Xbox {
    # Tich hop truc tiep qua Logger
}





