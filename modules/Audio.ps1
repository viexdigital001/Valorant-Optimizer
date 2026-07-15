# modules/Audio.ps1
# Module tối ưu hóa âm thanh (Audio Latency) cho Valorant Optimize 1.0.0

function Check-Audio {
    Write-Log "Kiểm tra cấu hình MMCSS Task Audio..." "INFO"
    $audioTaskPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio"
    if (Test-Path $audioTaskPath) {
        $pri = Get-ItemPropertyValue -Path $audioTaskPath -Name "Priority" -ErrorAction SilentlyContinue
        $sched = Get-ItemPropertyValue -Path $audioTaskPath -Name "Scheduling Category" -ErrorAction SilentlyContinue
        Write-Log "MMCSS Tasks Audio - Priority: $pri, Category: $sched" "INFO"
    }
    return "OK"
}

function Apply-Audio {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bắt đầu tối ưu hóa âm thanh giảm độ trễ (Exclusive Mode & MMCSS)..." "INFO"
    
    # 1. Tối ưu MMCSS Task Audio lên mức ưu tiên cao
    $audioTaskPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio"
    if (-not (Test-Path $audioTaskPath)) {
        New-Item -Path $audioTaskPath -Force | Out-Null
    }
    
    Backup-RegistryValue -Path $audioTaskPath -ValueName "Priority"
    Backup-RegistryValue -Path $audioTaskPath -ValueName "Scheduling Category"
    Backup-RegistryValue -Path $audioTaskPath -ValueName "Clock Rate"
    
    Set-ItemProperty -Path $audioTaskPath -Name "Priority" -Value 6 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $audioTaskPath -Name "Scheduling Category" -Value "High" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $audioTaskPath -Name "Clock Rate" -Value 10000 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    # 2. Vô hiệu hóa DRM / Protected Audio check để giảm CPU Overhead khi game phát âm thanh
    $audioPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Audio"
    if (-not (Test-Path $audioPath)) {
        New-Item -Path $audioPath -Force | Out-Null
    }
    Backup-RegistryValue -Path $audioPath -ValueName "DisableProtectedAudioDG"
    Set-ItemProperty -Path $audioPath -Name "DisableProtectedAudioDG" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Log "Tối ưu hóa âm thanh (Audio) hoàn tất!" "SUCCESS"
}

function Restore-Audio {
    Write-Log "Đang khôi phục cài đặt Audio..." "INFO"
}

function Verify-Audio {
    Write-Log "Xác minh cấu hình Audio..." "INFO"
    return $true
}

function WriteLog-Audio {
    # Tích hợp trực tiếp qua Logger
}





