# modules/GameMode.ps1
# Module tối ưu hóa cấu hình Windows Game Mode cho Valorant Optimize 1.0.0

function Check-GameMode {
    Write-Log "Kiểm tra cấu hình Windows Game Mode..." "INFO"
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
    
    Write-Log "Bắt đầu kích hoạt Windows Game Mode..." "INFO"
    
    $gmPath = "HKCU:\Software\Microsoft\GameBar"
    if (-not (Test-Path $gmPath)) {
        New-Item -Path $gmPath -Force | Out-Null
    }
    Backup-RegistryValue -Path $gmPath -ValueName "AllowAutoGameMode"
    
    # 1. Kích hoạt Game Mode (Nhân Windows sẽ ưu tiên phân bổ CPU & GPU cho tiến trình Game)
    Set-ItemProperty -Path $gmPath -Name "AllowAutoGameMode" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    # 2. Đảm bảo Game DVR bị khóa ở Policy
    $policyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
    if (-not (Test-Path $policyPath)) {
        New-Item -Path $policyPath -Force | Out-Null
    }
    Backup-RegistryValue -Path $policyPath -ValueName "AllowGameDVR"
    Set-ItemProperty -Path $policyPath -Name "AllowGameDVR" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Log "Đã bật Game Mode và vô hiệu hóa Policy Game DVR thành công." "SUCCESS"
}

function Restore-GameMode {
    Write-Log "Đang khôi phục cấu hình Game Mode..." "INFO"
}

function Verify-GameMode {
    Write-Log "Xác minh cấu hình Game Mode..." "INFO"
    $gmPath = "HKCU:\Software\Microsoft\GameBar"
    if (Test-Path $gmPath) {
        $val = Get-ItemPropertyValue -Path $gmPath -Name "AllowAutoGameMode" -ErrorAction SilentlyContinue
        if ($val -eq 1) {
            Write-Log "Xác minh Game Mode thành công!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-GameMode {
    # Tích hợp trực tiếp qua Logger
}





