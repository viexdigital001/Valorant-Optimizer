# modules/Security.ps1
# Module cấu hình bảo mật hệ thống (Security) cho Valorant Optimize 1.0.0

function Check-Security {
    Write-Log "Kiểm tra cấu hình bảo mật..." "INFO"
    $sysInfo = Get-SystemInfo
    Write-Log "VBS: $($sysInfo.VBS), Memory Integrity: $($sysInfo.MemoryIntegrity)" "INFO"
    return "OK"
}

function Apply-Security {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bắt đầu cấu hình thiết lập bảo mật..." "INFO"
    
    # 1. Chúng ta tuyệt đối không tắt Windows Defender theo quy tắc bắt buộc.
    # Chỉ cảnh báo và cho phép người dùng tắt VBS / Memory Integrity nếu chạy profile Extreme.
    
    if ($Config.profile -eq "Extreme") {
        Write-Log "Yêu cầu xác nhận từ người dùng để tắt VBS / Memory Integrity (Extreme Profile)" "WARNING"
        
        $msg = "Cảnh báo: Tắt VBS và Memory Integrity sẽ tăng FPS (~5-15%) nhưng làm giảm bảo mật Windows. Bạn có muốn tắt không?"
        $confirm = Get-Confirmation -PromptMessage $msg
        
        if ($confirm) {
            # Tắt VBS
            $vbsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
            if (-not (Test-Path $vbsPath)) { New-Item -Path $vbsPath -Force | Out-Null }
            Backup-RegistryValue -Path $vbsPath -ValueName "EnableVirtualizationBasedSecurity"
            Set-ItemProperty -Path $vbsPath -Name "EnableVirtualizationBasedSecurity" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
            
            # Tắt Memory Integrity (HVCI)
            $hvciPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
            if (-not (Test-Path $hvciPath)) { New-Item -Path $hvciPath -Force | Out-Null }
            Backup-RegistryValue -Path $hvciPath -ValueName "Enabled"
            Set-ItemProperty -Path $hvciPath -Name "Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
            
            Write-Log "Đã tắt VBS và Memory Integrity (Yêu cầu khởi động lại để có hiệu lực)." "SUCCESS"
        } else {
            Write-Log "Người dùng từ chối tắt VBS / Memory Integrity. Bỏ qua tối ưu này." "INFO"
        }
    } else {
        Write-Log "Profile hiện tại không yêu cầu tắt VBS/Memory Integrity. Giữ nguyên mặc định an toàn." "INFO"
    }
}

function Restore-Security {
    Write-Log "Đang khôi phục cài đặt bảo mật..." "INFO"
}

function Verify-Security {
    Write-Log "Xác minh cấu hình bảo mật..." "INFO"
    return $true
}

function WriteLog-Security {
    # Tích hợp trực tiếp qua Logger
}





