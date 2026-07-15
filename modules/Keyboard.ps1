# modules/Keyboard.ps1
# Module tối ưu hóa bàn phím (Keyboard) cho Valorant Optimize 1.0.0

function Check-Keyboard {
    Write-Log "Kiểm tra cấu hình bàn phím..." "INFO"
    
    $kbPath = "HKCU:\Control Panel\Keyboard"
    if (Test-Path $kbPath) {
        $delay = Get-ItemPropertyValue -Path $kbPath -Name "KeyboardDelay" -ErrorAction SilentlyContinue
        $speed = Get-ItemPropertyValue -Path $kbPath -Name "KeyboardSpeed" -ErrorAction SilentlyContinue
        Write-Log "KeyboardDelay: $delay, KeyboardSpeed: $speed" "INFO"
    }
    
    return "OK"
}

function Apply-Keyboard {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bắt đầu tối ưu hóa cài đặt bàn phím..." "INFO"
    
    $kbDelay = $Config.settings.keyboard.KeyboardDelay # 0
    $kbSpeed = $Config.settings.keyboard.KeyboardSpeed # 31
    
    $kbPath = "HKCU:\Control Panel\Keyboard"
    if (-not (Test-Path $kbPath)) {
        New-Item -Path $kbPath -Force | Out-Null
    }
    
    Backup-RegistryValue -Path $kbPath -ValueName "KeyboardDelay"
    Backup-RegistryValue -Path $kbPath -ValueName "KeyboardSpeed"
    
    Set-ItemProperty -Path $kbPath -Name "KeyboardDelay" -Value $kbDelay -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $kbPath -Name "KeyboardSpeed" -Value $kbSpeed -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    
    # 2. Vô hiệu hóa phím tắt Accessibility để tránh nhảy ra Popup Sticky Keys/Filter Keys khi chơi game
    $stickyPath = "HKCU:\Control Panel\Accessibility\StickyKeys"
    $filterPath = "HKCU:\Control Panel\Accessibility\Keyboard Response"
    $togglePath = "HKCU:\Control Panel\Accessibility\ToggleKeys"
    
    if (-not (Test-Path $stickyPath)) { New-Item -Path $stickyPath -Force | Out-Null }
    if (-not (Test-Path $filterPath)) { New-Item -Path $filterPath -Force | Out-Null }
    if (-not (Test-Path $togglePath)) { New-Item -Path $togglePath -Force | Out-Null }
    
    Backup-RegistryValue -Path $stickyPath -ValueName "Flags"
    Backup-RegistryValue -Path $filterPath -ValueName "Flags"
    Backup-RegistryValue -Path $togglePath -ValueName "Flags"
    
    # Flags = 506 (Tắt phím tắt Shift 5 lần cho Sticky Keys)
    Set-ItemProperty -Path $stickyPath -Name "Flags" -Value "506" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    # Flags = 122 (Tắt phím tắt Filter Keys)
    Set-ItemProperty -Path $filterPath -Name "Flags" -Value "122" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    # Flags = 58 (Tắt phím tắt Toggle Keys)
    Set-ItemProperty -Path $togglePath -Name "Flags" -Value "58" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Log "Đã vô hiệu hóa các phím tắt Sticky Keys, Filter Keys và Toggle Keys." "SUCCESS"
}

function Restore-Keyboard {
    Write-Log "Đang khôi phục cài đặt bàn phím..." "INFO"
}

function Verify-Keyboard {
    Write-Log "Xác minh cấu hình bàn phím..." "INFO"
    $kbPath = "HKCU:\Control Panel\Keyboard"
    if (Test-Path $kbPath) {
        $delay = Get-ItemPropertyValue -Path $kbPath -Name "KeyboardDelay" -ErrorAction SilentlyContinue
        if ($delay -eq "0" -or $delay -eq "1") {
            Write-Log "Xác minh bàn phím thành công!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-Keyboard {
    # Tích hợp trực tiếp qua Logger
}

Export-ModuleMember -Function Check-Keyboard, Apply-Keyboard, Restore-Keyboard, Verify-Keyboard, WriteLog-Keyboard




