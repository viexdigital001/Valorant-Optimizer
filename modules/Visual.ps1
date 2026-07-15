# modules/Visual.ps1
# Module tối ưu hóa hiệu ứng hình ảnh (Visual Effects) cho Valorant Optimize 1.0.0

function Check-Visual {
    Write-Log "Kiểm tra cấu hình hiệu ứng hình ảnh..." "INFO"
    $vfxPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (Test-Path $vfxPath) {
        $setting = Get-ItemPropertyValue -Path $vfxPath -Name "VisualFXSetting" -ErrorAction SilentlyContinue
        Write-Log "VisualFXSetting: $setting (2 là đang tối ưu cho hiệu năng tốt nhất)" "INFO"
    }
    return "OK"
}

function Apply-Visual {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bắt đầu tối ưu hóa hiệu ứng hình ảnh Windows..." "INFO"
    
    # 1. Đặt hiệu ứng hình ảnh ở mức tối giản (Best Performance)
    $vfxPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (-not (Test-Path $vfxPath)) {
        New-Item -Path $vfxPath -Force | Out-Null
    }
    Backup-RegistryValue -Path $vfxPath -ValueName "VisualFXSetting"
    # VisualFXSetting = 2 (Adjust for best performance)
    Set-ItemProperty -Path $vfxPath -Name "VisualFXSetting" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    # 2. Tắt hiệu ứng hoạt ảnh phóng to thu nhỏ cửa sổ (MinAnimate)
    $wmPath = "HKCU:\Control Panel\Desktop\WindowMetrics"
    if (Test-Path $wmPath) {
        Backup-RegistryValue -Path $wmPath -ValueName "MinAnimate"
        # MinAnimate = "0" (Tắt animation phóng to/thu nhỏ)
        Set-ItemProperty -Path $wmPath -Name "MinAnimate" -Value "0" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    # 3. Tắt hiệu ứng hoạt ảnh thanh tác vụ (TaskbarAnimations)
    $advPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    if (Test-Path $advPath) {
        Backup-RegistryValue -Path $advPath -ValueName "TaskbarAnimations"
        Set-ItemProperty -Path $advPath -Name "TaskbarAnimations" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    Write-Log "Tối ưu hóa hiệu ứng hình ảnh (Visual) hoàn tất!" "SUCCESS"
}

function Restore-Visual {
    Write-Log "Đang khôi phục cài đặt Visual..." "INFO"
}

function Verify-Visual {
    Write-Log "Xác minh cấu hình Visual..." "INFO"
    $vfxPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (Test-Path $vfxPath) {
        $setting = Get-ItemPropertyValue -Path $vfxPath -Name "VisualFXSetting" -ErrorAction SilentlyContinue
        if ($setting -eq 2) {
            Write-Log "Xác minh Visual thành công!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-Visual {
    # Tích hợp trực tiếp qua Logger
}

Export-ModuleMember -Function Check-Visual, Apply-Visual, Restore-Visual, Verify-Visual, WriteLog-Visual




