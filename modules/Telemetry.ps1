# modules/Telemetry.ps1
# Module vô hiệu hóa thu thập dữ liệu (Telemetry) cho Valorant Optimize 1.0.0

function Check-Telemetry {
    Write-Log "Kiểm tra cấu hình Telemetry..." "INFO"
    
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
    
    Write-Log "Bắt đầu vô hiệu hóa Windows Telemetry..." "INFO"
    
    $disableTelemetry = $Config.settings.telemetry.DisableTelemetry
    if (-not $disableTelemetry) {
        Write-Log "Bỏ qua cấu hình Telemetry." "WARNING"
        return
    }
    
    $telPath1 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $telPath2 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    
    if (-not (Test-Path $telPath1)) { New-Item -Path $telPath1 -Force | Out-Null }
    if (-not (Test-Path $telPath2)) { New-Item -Path $telPath2 -Force | Out-Null }
    
    Backup-RegistryValue -Path $telPath1 -ValueName "AllowTelemetry"
    Backup-RegistryValue -Path $telPath2 -ValueName "AllowTelemetry"
    
    # Đặt AllowTelemetry = 0 để tắt
    Set-ItemProperty -Path $telPath1 -Name "AllowTelemetry" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $telPath2 -Name "AllowTelemetry" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    # Tắt Customer Experience Improvement Program (CEIP)
    $sqmPath = "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows"
    if (-not (Test-Path $sqmPath)) { New-Item -Path $sqmPath -Force | Out-Null }
    Backup-RegistryValue -Path $sqmPath -ValueName "CEIPEnable"
    Set-ItemProperty -Path $sqmPath -Name "CEIPEnable" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    # Tắt ứng dụng khởi chạy theo dõi (App Launch Tracking)
    $actPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    if (Test-Path $actPath) {
        Backup-RegistryValue -Path $actPath -ValueName "Start_TrackProgs"
        Set-ItemProperty -Path $actPath -Name "Start_TrackProgs" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    Write-Log "Vô hiệu hóa Telemetry hoàn tất!" "SUCCESS"
}

function Restore-Telemetry {
    Write-Log "Đang khôi phục cài đặt Telemetry..." "INFO"
}

function Verify-Telemetry {
    Write-Log "Xác minh cấu hình Telemetry..." "INFO"
    $telPath1 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    if (Test-Path $telPath1) {
        $val = Get-ItemPropertyValue -Path $telPath1 -Name "AllowTelemetry" -ErrorAction SilentlyContinue
        if ($val -eq 0) {
            Write-Log "Xác minh Telemetry thành công!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-Telemetry {
    # Tích hợp trực tiếp qua Logger
}

Export-ModuleMember -Function Check-Telemetry, Apply-Telemetry, Restore-Telemetry, Verify-Telemetry, WriteLog-Telemetry


