# modules/Xbox.ps1
# Module vô hiệu hóa dịch vụ Xbox chạy nền và Game DVR cho Valorant Optimize 1.0.0

function Check-Xbox {
    Write-Log "Kiểm tra cấu hình Xbox Game DVR..." "INFO"
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
    
    Write-Log "Bắt đầu tắt Game DVR và các dịch vụ Xbox không sử dụng..." "INFO"
    
    # 1. Tắt Game DVR trong GameConfigStore
    $gcsPath = "HKCU:\System\GameConfigStore"
    if (Test-Path $gcsPath) {
        Backup-RegistryValue -Path $gcsPath -ValueName "GameDVR_Enabled"
        Backup-RegistryValue -Path $gcsPath -ValueName "GameDVR_FSEBehaviorMode"
        
        Set-ItemProperty -Path $gcsPath -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
        # FSEBehaviorMode = 2 (Vô hiệu hóa tối ưu hóa toàn màn hình cũ)
        Set-ItemProperty -Path $gcsPath -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    # 2. Tắt Capture âm thanh/hình ảnh của Xbox App Capture
    $dvrPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"
    if (-not (Test-Path $dvrPath)) {
        New-Item -Path $dvrPath -Force | Out-Null
    }
    Backup-RegistryValue -Path $dvrPath -ValueName "AppCaptureEnabled"
    Backup-RegistryValue -Path $dvrPath -ValueName "AudioCaptureEnabled"
    
    Set-ItemProperty -Path $dvrPath -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $dvrPath -Name "AudioCaptureEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    # 3. Tắt các dịch vụ Xbox nếu người dùng Tryhard (Để tránh nó liên tục thăm dò trong lúc chơi game)
    $xboxServices = @("XblAuthManager", "XblGameSave", "XboxNetApiSvc", "XboxGipSvc")
    foreach ($srvName in $xboxServices) {
        $srv = Get-Service -Name $srvName -ErrorAction SilentlyContinue
        if ($srv) {
            Backup-Service -ServiceName $srvName
            if ($srv.Status -eq "Running") {
                Stop-Service -Name $srvName -Force -ErrorAction SilentlyContinue | Out-Null
            }
            Set-Service -Name $srvName -StartupType Disabled -ErrorAction SilentlyContinue | Out-Null
            Write-Log "Đã vô hiệu hóa dịch vụ Xbox: $srvName" "INFO"
        }
    }
    
    Write-Log "Vô hiệu hóa Game DVR và Xbox Services hoàn tất!" "SUCCESS"
}

function Restore-Xbox {
    Write-Log "Đang khôi phục cấu hình Xbox..." "INFO"
}

function Verify-Xbox {
    Write-Log "Xác minh cấu hình Xbox..." "INFO"
    $gcsPath = "HKCU:\System\GameConfigStore"
    if (Test-Path $gcsPath) {
        $enabled = Get-ItemPropertyValue -Path $gcsPath -Name "GameDVR_Enabled" -ErrorAction SilentlyContinue
        if ($enabled -eq 0) {
            Write-Log "Xác minh Xbox thành công!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-Xbox {
    # Tích hợp trực tiếp qua Logger
}





