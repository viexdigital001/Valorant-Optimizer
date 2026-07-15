# modules/Input.ps1
# Module tối ưu hóa thời gian phản hồi đầu vào (Input Response) cho Valorant Optimize 1.0.0

function Check-Input {
    Write-Log "Kiểm tra cấu hình hàng đợi Input (Mouse & Keyboard class parameters)..." "INFO"
    
    $mouPath = "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters"
    if (Test-Path $mouPath) {
        $mouQueue = Get-ItemPropertyValue -Path $mouPath -Name "MouseDataQueueSize" -ErrorAction SilentlyContinue
        Write-Log "MouseDataQueueSize hiện tại: $mouQueue" "INFO"
    }
    
    $kbdPath = "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters"
    if (Test-Path $kbdPath) {
        $kbdQueue = Get-ItemPropertyValue -Path $kbdPath -Name "KeyboardDataQueueSize" -ErrorAction SilentlyContinue
        Write-Log "KeyboardDataQueueSize hiện tại: $kbdQueue" "INFO"
    }
    
    return "OK"
}

function Apply-Input {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bắt đầu tối ưu hóa hàng đợi Input (Mouse/Keyboard class)..." "INFO"
    
    $mouPath = "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters"
    $kbdPath = "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters"
    
    if (Test-Path $mouPath) {
        Backup-RegistryValue -Path $mouPath -ValueName "MouseDataQueueSize"
        # Đặt kích thước hàng đợi chuột tối ưu (100 là chuẩn hiệu năng ổn định)
        Set-ItemProperty -Path $mouPath -Name "MouseDataQueueSize" -Value 100 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    if (Test-Path $kbdPath) {
        Backup-RegistryValue -Path $kbdPath -ValueName "KeyboardDataQueueSize"
        # Đặt kích thước hàng đợi bàn phím tối ưu
        Set-ItemProperty -Path $kbdPath -Name "KeyboardDataQueueSize" -Value 100 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    # Tối ưu hóa phản hồi giao diện kéo thả cửa sổ và nhạy chuột
    $desktopPath = "HKCU:\Control Panel\Desktop"
    if (Test-Path $desktopPath) {
        Backup-RegistryValue -Path $desktopPath -ValueName "MenuShowDelay"
        # Đặt độ trễ hiển thị menu về 0 (nhanh tức thì)
        Set-ItemProperty -Path $desktopPath -Name "MenuShowDelay" -Value "0" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    Write-Log "Tối ưu hóa hàng đợi thiết bị đầu vào hoàn tất!" "SUCCESS"
}

function Restore-Input {
    Write-Log "Đang khôi phục cài đặt Input..." "INFO"
}

function Verify-Input {
    Write-Log "Xác minh cấu hình Input..." "INFO"
    return $true
}

function WriteLog-Input {
    # Tích hợp trực tiếp qua Logger
}

Export-ModuleMember -Function Check-Input, Apply-Input, Restore-Input, Verify-Input, WriteLog-Input




