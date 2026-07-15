# modules/BackgroundApps.ps1
# Module vô hiệu hóa ứng dụng UWP chạy ngầm (Background Apps) cho Valorant Optimize 1.0.0

function Check-BackgroundApps {
    Write-Log "Kiểm tra cấu hình ứng dụng chạy ngầm..." "INFO"
    $appPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    if (Test-Path $appPath) {
        $val = Get-ItemPropertyValue -Path $appPath -Name "GlobalUserDisabled" -ErrorAction SilentlyContinue
        Write-Log "GlobalUserDisabled (Ứng dụng ngầm): $val (1 là đã vô hiệu hóa)" "INFO"
    }
    return "OK"
}

function Apply-BackgroundApps {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bắt đầu vô hiệu hóa ứng dụng UWP chạy ngầm..." "INFO"
    
    $appPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    if (-not (Test-Path $appPath)) {
        New-Item -Path $appPath -Force | Out-Null
    }
    
    Backup-RegistryValue -Path $appPath -ValueName "GlobalUserDisabled"
    
    # GlobalUserDisabled = 1 (Tắt hoàn toàn các app Windows Store chạy ngầm vô bổ)
    Set-ItemProperty -Path $appPath -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    # Tắt chẩn đoán ứng dụng chạy ngầm của Windows Search
    $searchPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    if (Test-Path $searchPath) {
        Backup-RegistryValue -Path $searchPath -ValueName "BackgroundAppDiagnostic"
        Set-ItemProperty -Path $searchPath -Name "BackgroundAppDiagnostic" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    Write-Log "Đã vô hiệu hóa các ứng dụng chạy ngầm thành công." "SUCCESS"
}

function Restore-BackgroundApps {
    Write-Log "Đang khôi phục ứng dụng chạy ngầm..." "INFO"
}

function Verify-BackgroundApps {
    Write-Log "Xác minh cấu hình ứng dụng chạy ngầm..." "INFO"
    $appPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    if (Test-Path $appPath) {
        $val = Get-ItemPropertyValue -Path $appPath -Name "GlobalUserDisabled" -ErrorAction SilentlyContinue
        if ($val -eq 1) {
            Write-Log "Xác minh ứng dụng ngầm thành công!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-BackgroundApps {
    # Tích hợp trực tiếp qua Logger
}

Export-ModuleMember -Function Check-BackgroundApps, Apply-BackgroundApps, Restore-BackgroundApps, Verify-BackgroundApps, WriteLog-BackgroundApps


