# modules/Visual.ps1
# Module Optimizing hieu ung hinh anh (Visual Effects) cho Valorant Optimize 1.0.0

function Check-Visual {
    Write-Log "Kiem tra Configuring hieu ung hinh anh..." "INFO"
    $vfxPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (Test-Path $vfxPath) {
        $setting = Get-ItemPropertyValue -Path $vfxPath -Name "VisualFXSetting" -ErrorAction SilentlyContinue
        Write-Log "VisualFXSetting: $setting (2 la Currently toi uu cho hieu nang tot nhat)" "INFO"
    }
    return "OK"
}

function Apply-Visual {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bat au Optimizing hieu ung hinh anh Windows..." "INFO"
    
    # 1. at hieu ung hinh anh o muc toi gian (Best Performance)
    $vfxPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (-not (Test-Path $vfxPath)) {
        New-Item -Path $vfxPath -Force | Out-Null
    }
    Backup-RegistryValue -Path $vfxPath -ValueName "VisualFXSetting"
    # VisualFXSetting = 2 (Adjust for best performance)
    Set-ItemProperty -Path $vfxPath -Name "VisualFXSetting" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    # 2. Tat hieu ung hoat anh phong to thu nho cua so (MinAnimate)
    $wmPath = "HKCU:\Control Panel\Desktop\WindowMetrics"
    if (Test-Path $wmPath) {
        Backup-RegistryValue -Path $wmPath -ValueName "MinAnimate"
        # MinAnimate = "0" (Tat animation phong to/thu nho)
        Set-ItemProperty -Path $wmPath -Name "MinAnimate" -Value "0" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    # 3. Tat hieu ung hoat anh thanh tac vu (TaskbarAnimations)
    $advPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    if (Test-Path $advPath) {
        Backup-RegistryValue -Path $advPath -ValueName "TaskbarAnimations"
        Set-ItemProperty -Path $advPath -Name "TaskbarAnimations" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    Write-Log "Optimizing hieu ung hinh anh (Visual) Completed!" "SUCCESS"
}

function Restore-Visual {
    Write-Log "Currently Restore cai at Visual..." "INFO"
}

function Verify-Visual {
    Write-Log "Xac minh Configuring Visual..." "INFO"
    $vfxPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (Test-Path $vfxPath) {
        $setting = Get-ItemPropertyValue -Path $vfxPath -Name "VisualFXSetting" -ErrorAction SilentlyContinue
        if ($setting -eq 2) {
            Write-Log "Xac minh Visual Success!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-Visual {
    # Tich hop truc tiep qua Logger
}





