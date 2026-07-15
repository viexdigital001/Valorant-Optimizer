# modules/CPU.ps1
# Module tối ưu CPU cho Valorant Optimize 1.0.0

function Check-CPU {
    Write-Log "Kiểm tra cấu hình CPU hiện tại..." "INFO"
    $status = "OK"
    
    # Kiểm tra Win32PrioritySeparation
    $priPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    if (Test-Path $priPath) {
        $val = Get-ItemPropertyValue -Path $priPath -Name "Win32PrioritySeparation" -ErrorAction SilentlyContinue
        Write-Log "Win32PrioritySeparation hiện tại: $val" "INFO"
    }
    
    # Kiểm tra cấu hình ưu tiên tiến trình cho Valorant
    $valPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\VALORANT-Win64-Shipping.exe\PerfOptions"
    if (Test-Path $valPath) {
        $cpuPri = Get-ItemPropertyValue -Path $valPath -Name "CpuPriorityClass" -ErrorAction SilentlyContinue
        $ioPri = Get-ItemPropertyValue -Path $valPath -Name "IoPriority" -ErrorAction SilentlyContinue
        Write-Log "Độ ưu tiên CPU Valorant hiện tại: $cpuPri, IO: $ioPri" "INFO"
    } else {
        Write-Log "Chưa cấu hình độ ưu tiên riêng cho Valorant." "INFO"
    }
    
    return $status
}

function Apply-CPU {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bắt đầu tối ưu CPU..." "INFO"
    
    # Lấy các thiết lập từ config profile
    $win32Pri = $Config.settings.cpu.Win32PrioritySeparation
    $priority = $Config.settings.cpu.Priority # High
    $ioPriority = $Config.settings.cpu.IoPriority # High
    
    # 1. Tối ưu Win32PrioritySeparation
    $priPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    if (-not (Test-Path $priPath)) {
        New-Item -Path $priPath -Force | Out-Null
    }
    Backup-RegistryValue -Path $priPath -ValueName "Win32PrioritySeparation"
    Set-ItemProperty -Path $priPath -Name "Win32PrioritySeparation" -Value $win32Pri -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    Write-Log "Đã cấu hình Win32PrioritySeparation thành $win32Pri" "INFO"
    
    # 2. Tối ưu độ ưu tiên của Valorant
    $valPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\VALORANT-Win64-Shipping.exe\PerfOptions"
    if (-not (Test-Path $valPath)) {
        New-Item -Path $valPath -Force | Out-Null
    }
    
    # CpuPriorityClass: 3 = High, 6 = AboveNormal
    $cpuPriVal = 3
    if ($priority -eq "AboveNormal") { $cpuPriVal = 6 }
    
    # IoPriority: 3 = High, 2 = Normal
    $ioPriVal = 3
    if ($ioPriority -eq "Normal") { $ioPriVal = 2 }
    
    Backup-RegistryValue -Path $valPath -ValueName "CpuPriorityClass"
    Backup-RegistryValue -Path $valPath -ValueName "IoPriority"
    
    Set-ItemProperty -Path $valPath -Name "CpuPriorityClass" -Value $cpuPriVal -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $valPath -Name "IoPriority" -Value $ioPriVal -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Log "Đã cấu hình CPU Priority Class = $cpuPriVal và IO Priority = $ioPriVal cho Valorant" "SUCCESS"
}

function Restore-CPU {
    Write-Log "Đang khôi phục cài đặt CPU..." "INFO"
    # Logic Restore toàn cục sẽ nạp và xử lý từ snapshot backup
}

function Verify-CPU {
    Write-Log "Xác minh cấu hình CPU..." "INFO"
    $priPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
    $valPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\VALORANT-Win64-Shipping.exe\PerfOptions"
    
    $check1 = $false
    $check2 = $false
    
    if (Test-Path $priPath) {
        $val = Get-ItemPropertyValue -Path $priPath -Name "Win32PrioritySeparation" -ErrorAction SilentlyContinue
        if ($val -ne $null) { $check1 = $true }
    }
    if (Test-Path $valPath) {
        $cpu = Get-ItemPropertyValue -Path $valPath -Name "CpuPriorityClass" -ErrorAction SilentlyContinue
        if ($cpu -eq 3 -or $cpu -eq 6) { $check2 = $true }
    }
    
    if ($check1 -and $check2) {
        Write-Log "Xác minh CPU thành công!" "SUCCESS"
        return $true
    }
    Write-Log "Xác minh CPU thất bại hoặc chưa hoàn thành." "WARNING"
    return $false
}

function WriteLog-CPU {
    # Tích hợp trực tiếp qua Logger
}

Export-ModuleMember -Function Check-CPU, Apply-CPU, Restore-CPU, Verify-CPU, WriteLog-CPU




