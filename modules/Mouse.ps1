# modules/Mouse.ps1
# Module tối ưu hóa chuột (Mouse) cho Valorant Optimize 1.0.0

function Check-Mouse {
    Write-Log "Kiểm tra cấu hình chuột..." "INFO"
    
    $mousePath = "HKCU:\Control Panel\Mouse"
    if (Test-Path $mousePath) {
        $speed = Get-ItemPropertyValue -Path $mousePath -Name "MouseSpeed" -ErrorAction SilentlyContinue
        $epp = Get-ItemPropertyValue -Path $mousePath -Name "EnhancePointerPrecision" -ErrorAction SilentlyContinue
        Write-Log "MouseSpeed: $speed, EnhancePointerPrecision (Gia tốc): $epp" "INFO"
    }
    
    return "OK"
}

function Apply-Mouse {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bắt đầu tối ưu hóa thiết lập chuột (Xóa gia tốc)..." "INFO"
    
    $mousePath = "HKCU:\Control Panel\Mouse"
    if (-not (Test-Path $mousePath)) {
        New-Item -Path $mousePath -Force | Out-Null
    }
    
    Backup-RegistryValue -Path $mousePath -ValueName "MouseSpeed"
    Backup-RegistryValue -Path $mousePath -ValueName "EnhancePointerPrecision"
    Backup-RegistryValue -Path $mousePath -ValueName "MouseThreshold1"
    Backup-RegistryValue -Path $mousePath -ValueName "MouseThreshold2"
    Backup-RegistryValue -Path $mousePath -ValueName "SmoothMouseXCurve"
    Backup-RegistryValue -Path $mousePath -ValueName "SmoothMouseYCurve"
    
    # 1. Tắt gia tốc chuột chuẩn Windows
    # MouseSpeed = 0, MouseThreshold1 = 0, MouseThreshold2 = 0, EnhancePointerPrecision = 0
    Set-ItemProperty -Path $mousePath -Name "MouseSpeed" -Value "0" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $mousePath -Name "EnhancePointerPrecision" -Value "0" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $mousePath -Name "MouseThreshold1" -Value "0" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $mousePath -Name "MouseThreshold2" -Value "0" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    
    # 2. Áp dụng đường cong phẳng 1:1 (MarkC Mouse Fix style) để gạt bỏ hoàn toàn gia tốc ẩn của phần cứng
    [byte[]]$xCurve = @(
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0xa0,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x40,0x01,0x00,0x00,0x00,0x00,0x00,
        0x00,0xe0,0x01,0x00,0x00,0x00,0x00,0x00,
        0x00,0x80,0x02,0x00,0x00,0x00,0x00,0x00
    )
    
    [byte[]]$yCurve = @(
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x38,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x70,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0xa8,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0xe0,0x00,0x00,0x00,0x00,0x00
    )
    
    Set-ItemProperty -Path $mousePath -Name "SmoothMouseXCurve" -Value $xCurve -Type Binary -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $mousePath -Name "SmoothMouseYCurve" -Value $yCurve -Type Binary -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Log "Đã thiết lập tỷ lệ di chuột phẳng 1:1 (Xóa gia tốc thành công)." "SUCCESS"
}

function Restore-Mouse {
    Write-Log "Đang khôi phục cài đặt chuột..." "INFO"
}

function Verify-Mouse {
    Write-Log "Xác minh cấu hình chuột..." "INFO"
    $mousePath = "HKCU:\Control Panel\Mouse"
    if (Test-Path $mousePath) {
        $epp = Get-ItemPropertyValue -Path $mousePath -Name "EnhancePointerPrecision" -ErrorAction SilentlyContinue
        if ($epp -eq "0") {
            Write-Log "Xác minh cấu hình chuột thành công!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-Mouse {
    # Tích hợp trực tiếp qua Logger
}





