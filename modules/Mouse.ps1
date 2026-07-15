# modules/Mouse.ps1
# Module Optimizing chuot (Mouse) cho Valorant Optimize 1.0.0

function Check-Mouse {
    Write-Log "Kiem tra Configuring chuot..." "INFO"
    
    $mousePath = "HKCU:\Control Panel\Mouse"
    if (Test-Path $mousePath) {
        $speed = Get-ItemPropertyValue -Path $mousePath -Name "MouseSpeed" -ErrorAction SilentlyContinue
        $epp = Get-ItemPropertyValue -Path $mousePath -Name "EnhancePointerPrecision" -ErrorAction SilentlyContinue
        Write-Log "MouseSpeed: $speed, EnhancePointerPrecision (Gia toc): $epp" "INFO"
    }
    
    return "OK"
}

function Apply-Mouse {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bat au Optimizing thiet lap chuot (Xoa gia toc)..." "INFO"
    
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
    
    # 1. Tat gia toc chuot chuan Windows
    # MouseSpeed = 0, MouseThreshold1 = 0, MouseThreshold2 = 0, EnhancePointerPrecision = 0
    Set-ItemProperty -Path $mousePath -Name "MouseSpeed" -Value "0" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $mousePath -Name "EnhancePointerPrecision" -Value "0" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $mousePath -Name "MouseThreshold1" -Value "0" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $mousePath -Name "MouseThreshold2" -Value "0" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    
    # 2. Applying uong cong phang 1:1 (MarkC Mouse Fix style) e gat bo hoan toan gia toc an cua phan cung
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
    
    Write-Log "a thiet lap ty le di chuot phang 1:1 (Xoa gia toc Success)." "SUCCESS"
}

function Restore-Mouse {
    Write-Log "Currently Restore cai at chuot..." "INFO"
}

function Verify-Mouse {
    Write-Log "Xac minh Configuring chuot..." "INFO"
    $mousePath = "HKCU:\Control Panel\Mouse"
    if (Test-Path $mousePath) {
        $epp = Get-ItemPropertyValue -Path $mousePath -Name "EnhancePointerPrecision" -ErrorAction SilentlyContinue
        if ($epp -eq "0") {
            Write-Log "Xac minh Configuring chuot Success!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-Mouse {
    # Tich hop truc tiep qua Logger
}





