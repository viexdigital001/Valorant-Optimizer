# core/System.ps1
# Động cơ phát hiện thông tin hệ thống cho Valorant Optimize 1.0.0

function Get-SystemInfo {
    Write-Log "Bắt đầu thu thập thông tin phần cứng..." "INFO"
    
    $info = [ordered]@{
        CPUModel         = "Unknown CPU"
        CPUCores         = 0
        GPUModel         = "Unknown GPU"
        GPUDriver        = "Unknown Driver"
        RAMSizeGB        = 0
        OSName           = "Unknown Windows"
        OSBuild          = "Unknown Build"
        IsLaptop         = $false
        SecureBoot       = $false
        TPM              = $false
        GameMode         = $false
        MemoryIntegrity  = $false
        VBS              = $false
        PowerPlanGUID    = "Unknown"
        PowerPlanName    = "Unknown"
        ValorantInstalled= $false
        VanguardInstalled= $false
        DeviceProfile    = "Balanced PC"
    }

    # 1. Thu thập CPU
    try {
        $cpu = Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue
        if ($cpu) {
            $info.CPUModel = $cpu.Name.Trim()
            $info.CPUCores = $cpu.NumberOfCores
        }
    } catch {
        Write-Log "Lỗi lấy thông tin CPU: $_" "WARNING"
    }

    # 2. Thu thập GPU
    try {
        $gpu = Get-CimInstance -ClassName Win32_VideoController -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($gpu) {
            $info.GPUModel = $gpu.Name
            $info.GPUDriver = $gpu.DriverVersion
        }
    } catch {
        Write-Log "Lỗi lấy thông tin GPU: $_" "WARNING"
    }

    # 3. Thu thập RAM
    try {
        $cs = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction SilentlyContinue
        if ($cs) {
            $info.RAMSizeGB = [Math]::Round($cs.TotalPhysicalMemory / 1GB)
        }
    } catch {
        Write-Log "Lỗi lấy thông tin RAM: $_" "WARNING"
    }

    # 4. Thu thập OS
    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
        if ($os) {
            $info.OSName = $os.Caption
            $info.OSBuild = $os.Version
        }
    } catch {
        Write-Log "Lỗi lấy thông tin OS: $_" "WARNING"
    }

    # 5. Phát hiện Laptop hay Desktop
    try {
        $chassis = Get-CimInstance -ClassName Win32_SystemEnclosure -ErrorAction SilentlyContinue
        if ($chassis) {
            # ChassisTypes 8, 9, 10, 11, 12, 14, 18, 21 là Laptop/Notebook/Portable
            $laptopTypes = @(8, 9, 10, 11, 12, 14, 18, 21)
            foreach ($type in $chassis.ChassisTypes) {
                if ($laptopTypes -contains $type) {
                    $info.IsLaptop = $true
                    break
                }
            }
        }
        # Kiểm tra thêm sự tồn tại của pin
        if (-not $info.IsLaptop) {
            $battery = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue
            if ($battery) {
                $info.IsLaptop = $true
            }
        }
    } catch {
        Write-Log "Lỗi phát hiện loại thiết bị: $_" "WARNING"
    }

    # 6. Kiểm tra Secure Boot
    try {
        $sbPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State"
        if (Test-Path $sbPath) {
            $sbVal = Get-ItemPropertyValue -Path $sbPath -Name "UEFISecureBootEnabled" -ErrorAction SilentlyContinue
            if ($sbVal -eq 1) {
                $info.SecureBoot = $true
            }
        }
    } catch {
        Write-Log "Lỗi kiểm tra Secure Boot: $_" "WARNING"
    }

    # 7. Kiểm tra TPM
    try {
        $tpm = Get-CimInstance -Namespace "Root\CIMV2\Security\MicrosoftTpm" -ClassName Win32_Tpm -ErrorAction SilentlyContinue
        if ($tpm -and $tpm.IsEnabled_InitialValue -eq $true) {
            $info.TPM = $true
        }
    } catch {
        # Đôi khi lệnh Get-CimInstance trên namespace tpm lỗi nếu không có quyền admin hoặc TPM bị tắt hẳn trong BIOS
        Write-Log "Không tìm thấy thiết bị TPM đang chạy hoặc không có quyền truy cập." "WARNING"
    }

    # 8. Kiểm tra Game Mode
    try {
        $gmPath = "HKCU:\Software\Microsoft\GameBar"
        if (Test-Path $gmPath) {
            $gmVal = Get-ItemPropertyValue -Path $gmPath -Name "AllowAutoGameMode" -ErrorAction SilentlyContinue
            if ($gmVal -eq 1) {
                $info.GameMode = $true
            }
        } else {
            # Mặc định của Windows thường bật Game Mode
            $info.GameMode = $true
        }
    } catch {
        Write-Log "Lỗi kiểm tra Game Mode: $_" "WARNING"
    }

    # 9. Kiểm tra Memory Integrity (HVCI)
    try {
        $hvciPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
        if (Test-Path $hvciPath) {
            $hvciVal = Get-ItemPropertyValue -Path $hvciPath -Name "Enabled" -ErrorAction SilentlyContinue
            if ($hvciVal -eq 1) {
                $info.MemoryIntegrity = $true
            }
        }
    } catch {
        Write-Log "Lỗi kiểm tra Memory Integrity: $_" "WARNING"
    }

    # 10. Kiểm tra VBS
    try {
        $vbsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
        if (Test-Path $vbsPath) {
            $vbsVal = Get-ItemPropertyValue -Path $vbsPath -Name "EnableVirtualizationBasedSecurity" -ErrorAction SilentlyContinue
            if ($vbsVal -eq 1) {
                $info.VBS = $true
            }
        }
    } catch {
        Write-Log "Lỗi kiểm tra VBS: $_" "WARNING"
    }

    # 11. Kiểm tra Power Plan hiện tại
    try {
        $activePlan = powercfg /getactivescheme
        if ($activePlan -match "GUID: ([a-f0-9\-]+)\s+\((.+)\)") {
            $info.PowerPlanGUID = $Matches[1]
            $info.PowerPlanName = $Matches[2]
        }
    } catch {
        Write-Log "Lỗi lấy Power Plan: $_" "WARNING"
    }

    # 12. Kiểm tra cài đặt Valorant & Vanguard
    try {
        # Kiểm tra qua đường dẫn mặc định
        $valPathDefault = "C:\Riot Games\VALORANT"
        if (Test-Path $valPathDefault) {
            $info.ValorantInstalled = $true
        } else {
            # Thử tìm trong Uninstall registry
            $regPaths = @(
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
                "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
            )
            foreach ($rp in $regPaths) {
                if (Test-Path $rp) {
                    $keys = Get-ChildItem -Path $rp -ErrorAction SilentlyContinue
                    foreach ($key in $keys) {
                        $disp = Get-ItemPropertyValue -Path $key.PSPath -Name "DisplayName" -ErrorAction SilentlyContinue
                        if ($disp -and $disp -like "*VALORANT*") {
                            $info.ValorantInstalled = $true
                            break
                        }
                    }
                }
            }
        }

        # Kiểm tra Riot Vanguard service vgc
        $vanguardService = Get-Service -Name "vgc" -ErrorAction SilentlyContinue
        if ($vanguardService) {
            $info.VanguardInstalled = $true
        }
    } catch {
        Write-Log "Lỗi phát hiện Valorant/Vanguard: $_" "WARNING"
    }

    # 13. Phân loại cấu hình thiết bị (Device Profile)
    # Low-End: Ram < 8GB hoặc Cores <= 4 hoặc GPU Onboard (Intel HD/AMD Radeon Graphics chung chung)
    # High-End: Ram >= 16GB và Cores >= 6 và GPU rời cao (RTX/GTX/Radeon RX/Ryzen 5+)
    if ($info.RAMSizeGB -le 8 -or $info.CPUCores -le 4) {
        $info.DeviceProfile = "Low-End PC"
    } elseif ($info.RAMSizeGB -ge 16 -and $info.CPUCores -ge 6 -and ($info.GPUModel -match "RTX" -or $info.GPUModel -match "GTX" -or $info.GPUModel -match "Radeon RX" -or $info.GPUModel -match "Intel Arc")) {
        $info.DeviceProfile = "High-End PC"
    } else {
        $info.DeviceProfile = "Mid-End PC"
    }

    Write-Log "Hoàn thành thu thập cấu hình hệ thống: $($info.DeviceProfile)" "SUCCESS"
    return [PSCustomObject]$info
}

# Export hàm




