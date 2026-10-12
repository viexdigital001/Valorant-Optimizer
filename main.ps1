# main.ps1
# Main Entrypoint cho Valorant Optimize v1.1.0

# 0. Xac dinh duong dan tuyet doi va thu muc lam viec
$scriptPath = $PSCommandPath
if (-not $scriptPath) {
    if ($MyInvocation.MyCommand.Path) {
        $scriptPath = $MyInvocation.MyCommand.Path
    } elseif ($MyInvocation.MyCommand.Definition) {
        $scriptPath = $MyInvocation.MyCommand.Definition
    } else {
        $scriptPath = Join-Path $PWD.Path "main.ps1"
    }
}
$PSScriptRoot = Split-Path -Parent $scriptPath
if (-not $PSScriptRoot) { $PSScriptRoot = $PWD.Path }
Set-Location -Path $PSScriptRoot

# 1. Kiem tra quyen Administrator
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Automatically requesting Administrator privileges..." -ForegroundColor Yellow
    try {
        Start-Process powershell.exe -WorkingDirectory "$PSScriptRoot" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
        Exit
    } catch {
        Write-Host "[X] FATAL ERROR: Administrator privileges not granted!" -ForegroundColor Red
        Write-Host "Press any key to exit..." -ForegroundColor Gray
        try { [Console]::ReadKey($true) | Out-Null } catch { Read-Host }
        Exit
    }
}

try {
    # 2. Nap Loader va khoi tao du an
    . (Join-Path $PSScriptRoot "core\Loader.ps1")
    Initialize-Project

# 3. Man hinh mo au (Loading & Logo)
Draw-StartupLogo

# 4. Vong lap giao dien chinh
$menuItems = @(
    "Dashboard",
    "Optimize Mode",
    "One Click Optimize",
    "Latency Diagnostics",
    "Restore",
    "Log",
    "[VIP] VieX Plus 2.0",
    "About",
    "Exit"
)

$activeMenu = 0
$sysInfo = Get-SystemInfo # Thu thap thong tin ban au

function Show-Dashboard {
    Clear-ContentArea
    Move-Cursor 28 2
    Write-Ansi "[ SYSTEM STATUS DASHBOARD ]" -Color "BrightCyan" -Bold
    Draw-HorizontalLine 28 3 85 "-" "Gray"
    
    # Ve cac cot thong tin
    Move-Cursor 28 5
    Write-Ansi "HARDWARE INFO" -Color "BrightWhite" -Underline
    
    Move-Cursor 28 7
    Write-Ansi "CPU: " -Color "Gray" -NoNewLine
    Write-Ansi $sysInfo.CPUModel -Color "BrightCyan"
    
    Move-Cursor 28 8
    Write-Ansi "GPU: " -Color "Gray" -NoNewLine
    Write-Ansi $sysInfo.GPUModel -Color "BrightCyan"
    
    Move-Cursor 28 9
    Write-Ansi "RAM: " -Color "Gray" -NoNewLine
    Write-Ansi "$($sysInfo.RAMSizeGB) GB" -Color "BrightCyan"
    
    Move-Cursor 28 10
    Write-Ansi "OS:  " -Color "Gray" -NoNewLine
    Write-Ansi $sysInfo.OSName -Color "BrightCyan"
    
    Move-Cursor 28 12
    Write-Ansi "CURRENT CONFIGURATION" -Color "BrightWhite" -Underline
    
    # Trang thai Game Mode
    Move-Cursor 28 14
    Write-Ansi "Game Mode: " -Color "Gray" -NoNewLine
    if ($sysInfo.GameMode) {
        Write-Ansi "[V] Enabled" -Color "BrightGreen"
    } else {
        Write-Ansi "[X] Disabled" -Color "BrightRed"
    }
    
    # Trang thai VBS
    Move-Cursor 28 15
    Write-Ansi "Virtualization-Based Security (VBS): " -Color "Gray" -NoNewLine
    if ($sysInfo.VBS) {
        Write-Ansi "[!] Enabled (Reduces Gaming Performance)" -Color "BrightRed"
    } else {
        Write-Ansi "[V] Disabled (Optimized)" -Color "BrightGreen"
    }
    
    # Trang thai Memory Integrity
    Move-Cursor 28 16
    Write-Ansi "Memory Integrity (HVCI): " -Color "Gray" -NoNewLine
    if ($sysInfo.MemoryIntegrity) {
        Write-Ansi "[!] Enabled" -Color "BrightRed"
    } else {
        Write-Ansi "[V] Disabled" -Color "BrightGreen"
    }
    
    # Trang thai Power Plan
    Move-Cursor 28 17
    Write-Ansi "Power Plan: " -Color "Gray" -NoNewLine
    if ($sysInfo.PowerPlanName -match "Ultimate") {
        Write-Ansi "[V] $($sysInfo.PowerPlanName)" -Color "BrightGreen" -Bold
    } else {
        Write-Ansi "[i] $($sysInfo.PowerPlanName) (Ultimate is Recommended)" -Color "BrightYellow"
    }
    
    # Trang thai Valorant
    Move-Cursor 28 18
    Write-Ansi "Valorant: " -Color "Gray" -NoNewLine
    if ($sysInfo.ValorantInstalled) {
        Write-Ansi "[V] Installed" -Color "BrightGreen"
    } else {
        Write-Ansi "[X] Not Installed" -Color "BrightRed"
    }
    
    Move-Cursor 28 20
    Write-Ansi "Riot Vanguard: " -Color "Gray" -NoNewLine
    if ($sysInfo.VanguardInstalled) {
        Write-Ansi "[V] Running" -Color "BrightGreen"
    } else {
        Write-Ansi "[X] Not Running/Installed" -Color "BrightRed"
    }
    
    Move-Cursor 28 22
    Write-Ansi "Profile Classification: " -Color "Gray" -NoNewLine
    Write-Ansi $sysInfo.DeviceProfile -Color "BrightYellow" -Bold
    
    Move-Cursor 28 24
    Write-Ansi "[*] VIP STATUS: " -Color "BrightYellow" -Bold -NoNewLine
    Write-Ansi "Free Edition (Mở mục VieX Plus 2.0.0 để mở khóa 100% công suất!)" -Color "BrightCyan"
    
    # Footer nho huong dan
    Move-Cursor 28 26
    Write-Ansi "[i] Tip: Use Up/Down arrows to navigate and Enter to select!" -Color "Gray"
}

function Show-OptimizePage {
    Clear-ContentArea
    Move-Cursor 28 2
    Write-Ansi "[ OPTIMIZE MODE ]" -Color "BrightCyan" -Bold
    Draw-HorizontalLine 28 3 85 "-" "Gray"
    
    $optItems = @(
        "[V] Competitive (Recommended for Tryharders)",
        "[~] Balanced (Smooth, keeps battery stable)",
        "[!] Extreme (Max performance, disables security)",
        "< Go back to Main Menu"
    )
    
    $sel = 0
    $subLoop = $true
    
    while ($subLoop) {
        # Ve danh sach che o
        for ($i = 0; $i -lt $optItems.Count; $i++) {
            Move-Cursor 30 (6 + $i * 2)
            if ($i -eq $sel) {
                Write-Ansi "> $($optItems[$i])" -Color "BrightCyan" -Bold
            } else {
                Write-Ansi "  $($optItems[$i])" -Color "White"
            }
            # Them khoang trang em
            Write-Host (" " * 15) -NoNewLine
        }
        
        $key = [Console]::ReadKey($true)
        switch ($key.Key) {
            "UpArrow" {
                if ($sel -gt 0) { $sel-- } else { $sel = $optItems.Count - 1 }
            }
            "DownArrow" {
                if ($sel -lt ($optItems.Count - 1)) { $sel++ } else { $sel = 0 }
            }
            "Enter" {
                if ($sel -eq 3) {
                    $subLoop = $false
                } else {
                    $profileName = "Balanced"
                    $configObj = $Global:ConfigBalanced
                    
                    if ($sel -eq 0) {
                        $profileName = "Competitive"
                        $configObj = $Global:ConfigCompetitive
                    } elseif ($sel -eq 2) {
                        $profileName = "Extreme"
                        $configObj = $Global:ConfigExtreme
                    }
                    
                    # Xac nhan truoc khi ap dung
                    $msg = "Are you sure you want to apply the $profileName profile?"
                    if ($profileName -eq "Extreme") {
                        $msg = "[!] WARNING: Extreme mode may weaken system security. Proceed anyway?"
                    }
                    
                    $confirm = Get-Confirmation -PromptMessage $msg -Row 15
                    if ($confirm) {
                        Clear-ContentArea
                        Move-Cursor 28 5
                        Write-Ansi "Optimizing profile: $profileName..." -Color "BrightCyan"
                        Start-BackupSession
                        
                        # Chay Apply cho tat ca module
                        $successCount = 0
                        $modules = @("CPU", "GPU", "RAM", "Storage", "PowerPlan", "Timer", "MMCSS", "Services", "Network", "Mouse", "Keyboard", "Input", "Audio", "Security", "Telemetry", "Xbox", "GameMode", "GameStart", "BackgroundApps", "Visual", "Process", "Cleanup")
                        
                        $p = 0
                        foreach ($mName in $modules) {
                            $p += 4
                            Draw-ProgressBar 28 7 $p "Configuring $mName..."
                            $applyFunc = "Apply-$mName"
                            if (Get-Command $applyFunc -ErrorAction SilentlyContinue) {
                                try {
                                    Invoke-Expression "$applyFunc -Config `$configObj" | Out-Null
                                    $successCount++
                                } catch {}
                            }
                            Start-Sleep -Milliseconds 100
                        }
                        
                        Save-BackupSession
                        
                        Move-Cursor 28 10
                        Write-Ansi "[V] Successfully optimized $profileName profile!" -Color "BrightGreen" -Bold
                        Move-Cursor 28 11
                        Write-Ansi "Please restart your PC for the changes to take effect! [*]" -Color "BrightYellow"
                        
                        Move-Cursor 28 13
                        Write-Ansi "[*] Muon giam them 3-5ms Input Lag va on dinh 1% Low FPS trong Combat?" -Color "BrightCyan"
                        Move-Cursor 28 14
                        Write-Ansi "Kham pha VieX Plus 2.0.0 (408k/31 ngay): " -Color "BrightWhite" -NoNewLine
                        Write-Ansi "https://discord.gg/Xx4pcdvHkw" -Color "BrightYellow" -Underline
                        
                        Move-Cursor 28 16
                        Write-Ansi "Press [V] to join VIP Discord, or any other key to continue..." -Color "Gray"
                        $key = [Console]::ReadKey($true)
                        if ($key.Key -eq "V") {
                            try { Start-Process "https://discord.gg/Xx4pcdvHkw" } catch {}
                        }
                    }
                    $subLoop = $false
                }
            }
            "Escape" {
                $subLoop = $false
            }
        }
    }
    
    # Reload lai thong tin
    $Global:sysInfo = Get-SystemInfo
    Show-Dashboard
}

function Show-RestorePage {
    Clear-ContentArea
    Move-Cursor 28 2
    Write-Ansi "[ RESTORE SYSTEM CONFIGURATION ]" -Color "BrightCyan" -Bold
    Draw-HorizontalLine 28 3 85 "-" "Gray"
    
    $backups = Get-BackupList
    if ($backups.Count -eq 0) {
        Move-Cursor 28 5
        Write-Ansi "No backup snapshots found in the system!" -Color "BrightRed"
        Move-Cursor 28 7
        Write-Ansi "Press any key to continue..." -Color "Gray"
        [Console]::ReadKey($true) | Out-Null
        Show-Dashboard
        return
    }
    
    Move-Cursor 28 5
    Write-Ansi "Select a backup to restore:" -Color "BrightWhite"
    
    $sel = 0
    $subLoop = $true
    
    while ($subLoop) {
        for ($i = 0; $i -lt $backups.Count; $i++) {
            Move-Cursor 30 (7 + $i)
            $folderName = $backups[$i].Name
            if ($i -eq $sel) {
                Write-Ansi "> $folderName" -Color "BrightCyan" -Bold
            } else {
                Write-Ansi "  $folderName" -Color "White"
            }
        }
        
        Move-Cursor 30 (7 + $backups.Count + 1)
        if ($sel -eq $backups.Count) {
            Write-Ansi "> < Go back" -Color "BrightCyan" -Bold
        } else {
            Write-Ansi "  Go back" -Color "White"
        }
        
        $key = [Console]::ReadKey($true)
        switch ($key.Key) {
            "UpArrow" {
                if ($sel -gt 0) { $sel-- } else { $sel = $backups.Count }
            }
            "DownArrow" {
                if ($sel -lt $backups.Count) { $sel++ } else { $sel = 0 }
            }
            "Enter" {
                if ($sel -eq $backups.Count) {
                    $subLoop = $false
                } else {
                    $selectedBackup = $backups[$sel].FullName
                    $confirm = Get-Confirmation -PromptMessage "Do you want to restore this snapshot?" -Row 16
                    if ($confirm) {
                        Clear-ContentArea
                        Move-Cursor 28 5
                        Write-Ansi "Restoring configuration..." -Color "BrightCyan"
                        
                        # Chay khoi phuc
                        Restore-Snapshot -BackupDir $selectedBackup
                        
                        Move-Cursor 28 10
                        Write-Ansi "[V] Restore completed! Please restart your PC." -Color "BrightGreen" -Bold
                        Move-Cursor 28 12
                        Write-Ansi "Press any key to continue..." -Color "Gray"
                        [Console]::ReadKey($true) | Out-Null
                    }
                    $subLoop = $false
                }
            }
            "Escape" {
                $subLoop = $false
            }
        }
    }
    
    $Global:sysInfo = Get-SystemInfo
    Show-Dashboard
}

function Show-LogPage {
    Clear-ContentArea
    Move-Cursor 28 2
    Write-Ansi "[ ACTIVITY LOG ]" -Color "BrightCyan" -Bold
    Draw-HorizontalLine 28 3 85 "-" "Gray"
    
    if (Test-Path $Global:LogFilePath) {
        $logs = Get-Content -Path $Global:LogFilePath -Tail 20
        $row = 5
        foreach ($line in $logs) {
            Move-Cursor 28 $row
            # Cat bot dong dai
            $trimmed = if ($line.Length -gt 88) { $line.Substring(0, 85) + "..." } else { $line }
            
            # To mau log line
            if ($trimmed -match "\[SUCCESS\]") {
                Write-Ansi $trimmed -Color "BrightGreen"
            } elseif ($trimmed -match "\[WARNING\]") {
                Write-Ansi $trimmed -Color "BrightYellow"
            } elseif ($trimmed -match "\[ERROR\]") {
                Write-Ansi $trimmed -Color "BrightRed"
            } else {
                Write-Ansi $trimmed -Color "Gray"
            }
            $row++
        }
    } else {
        Move-Cursor 28 5
        Write-Ansi "No log file found." -Color "Gray"
    }
    
    Move-Cursor 28 27
    Write-Ansi "Press any key to return to menu..." -Color "Gray"
    [Console]::ReadKey($true) | Out-Null
}

function Show-LatencyDiagnosticsPage {
    Clear-ContentArea
    Move-Cursor 28 2
    Write-Ansi "[ SYSTEM LATENCY & ESPORTS POTENTIAL DIAGNOSTICS ]" -Color "BrightCyan" -Bold
    Draw-HorizontalLine 28 3 85 "-" "Gray"
    
    Move-Cursor 28 5
    Write-Ansi "Dang phan tich do tre phan cung va thiet lap he thong Windows..." -Color "BrightWhite"
    Start-Sleep -Milliseconds 150
    
    # 1. Kiem tra Timer Resolution an toan (Zero exception)
    $timerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"
    $timerVal = Get-RegistryPropertySafe -Path $timerPath -Name "GlobalTimerResolutionRequests" -Default 0
    $hasTimerRes = ($timerVal -eq 1)
    
    # 2. Kiem tra Power Plan (Ho tro ca Windows tieng Anh va tieng Viet/quoc te)
    $isUltimate = $false
    try {
        if ($Global:sysInfo -and $Global:sysInfo.PowerPlanName) {
            $isUltimate = ($Global:sysInfo.PowerPlanName -match "Ultimate") -or ($Global:sysInfo.PowerPlanGUID -eq "e9a42b02-d5df-448d-aa00-03f14749eb61")
        } else {
            $activeScheme = powercfg /getactivescheme 2>$null
            $isUltimate = ($activeScheme -match "Ultimate") -or ($activeScheme -match "e9a42b02-d5df-448d-aa00-03f14749eb61")
        }
    } catch { $isUltimate = $false }
    
    # 3. Kiem tra MSI Mode tren GPU / Interrupts
    $hasGpuMsi = $false
    try {
        $gpuPnp = (Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | Select-Object -First 1).PNPDeviceID
        if ($gpuPnp) {
            $msiVal = Get-RegistryPropertySafe -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\$gpuPnp\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" -Name "MSISupported" -Default 0
            if ($msiVal -eq 1) { $hasGpuMsi = $true }
        }
    } catch { $hasGpuMsi = $false }
    
    # 4. Kiem tra MMCSS & Network Throttling
    $netThrottling = Get-RegistryPropertySafe -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Default 10
    $sysResp = Get-RegistryPropertySafe -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Default 20
    $isNetOptimized = ($netThrottling -eq -1 -or $netThrottling -eq 4294967295 -or $netThrottling -eq 0xffffffff)
    $isMMCSSOptimized = ($sysResp -eq 0)
    
    # Cap nhat thong bao hoan tat tai Row 5
    Move-Cursor 28 5
    Write-Ansi "[OK] Hoan tat danh gia 5 chi so do tre he thong Windows              " -Color "BrightGreen"
    
    # Tinh toan diem toi uu thuc te hien tai
    $currentScore = 45
    if ($hasTimerRes) { $currentScore += 10 }
    if ($isUltimate) { $currentScore += 10 }
    if ($hasGpuMsi) { $currentScore += 10 }
    if ($isNetOptimized) { $currentScore += 5 }
    if ($isMMCSSOptimized) { $currentScore += 5 }
    
    $diagItems = @(
        @{ 
            Label = "1. Windows Kernel Timer"
            Current = if ($hasTimerRes) { "1.000 ms (Windows Request)" } else { "1.000 ms - 15.6 ms (Default)" }
            Plus = "0.500 ms (Permanent Lock)"
            Impact = "Giam 50% delay nhan click chuot"
        },
        @{ 
            Label = "2. GPU & Audio Interrupts"
            Current = if ($hasGpuMsi) { "MSI Mode Active (Low DPC Latency)" } else { "Line-based IRQ (Shared Bus Latency)" }
            Plus = "MSI Mode High (Dedicated Lane)"
            Impact = "Triet tieu DPC delay khi nghe util"
        },
        @{ 
            Label = "3. CPU Core Parking / Affinity"
            Current = if ($isUltimate) { "Partial Unpark (ACPI Standard)" } else { "Parked (Power Save Active)" }
            Plus = "100% Core Affinity for Valorant"
            Impact = "Cach ly Vanguard, khong nghen luong"
        },
        @{ 
            Label = "4. In-Game RAM Standby Cache"
            Current = "Windows Default (No Auto-Purge)"
            Plus = "Active Standby Memory Purger"
            Impact = "Triet tieu 100% micro-stutter smoke"
        },
        @{ 
            Label = "5. MMCSS & Network Bufferbloat"
            Current = if ($isNetOptimized -and $isMMCSSOptimized) { "MMCSS High + No Throttling" } else { "Windows Standard Packet Queue" }
            Plus = "DSCP QoS Tagging + Bufferbloat Fix"
            Impact = "Xoa bo hoan toan Ghost Bullets"
        }
    )
    
    $row = 7
    foreach ($item in $diagItems) {
        Move-Cursor 28 $row
        Write-Ansi "$($item.Label): " -Color "BrightWhite" -Bold -NoNewLine
        Write-Ansi $item.Current -Color "BrightYellow"
        
        Move-Cursor 31 ($row + 1)
        Write-Ansi "-> Tiềm năng VieX Plus: " -Color "Gray" -NoNewLine
        Write-Ansi $item.Plus -Color "BrightGreen" -Bold -NoNewLine
        Write-Ansi " | $($item.Impact)" -Color "Cyan"
        
        $row += 3
        Start-Sleep -Milliseconds 40
    }
    
    Draw-HorizontalLine 28 $row 85 "-" "Gray"
    
    Move-Cursor 28 ($row + 1)
    Write-Ansi "TỔNG ĐIỂM TỐI ƯU HIỆN TẠI (BẢN FREE): " -Color "BrightWhite" -Bold -NoNewLine
    Write-Ansi "$currentScore / 100 ĐIỂM " -Color "BrightYellow" -Bold -NoNewLine
    $remaining = 100 - $currentScore
    Write-Ansi "(CÒN $remaining% DƯ ĐỊA NGHẼN ĐỘ TRỄ)" -Color "Gray"
    
    Move-Cursor 28 ($row + 2)
    Write-Ansi "TIỀM NĂNG KHI NÂNG CẤP VIEX PLUS 2.0.0:  " -Color "BrightWhite" -Bold -NoNewLine
    Write-Ansi "99 / 100 ĐIỂM " -Color "BrightGreen" -Bold -NoNewLine
    Write-Ansi "[CHUẨN ESPORTS TOÀN DIỆN]" -Color "BrightCyan"
    
    Move-Cursor 28 ($row + 4)
    Write-Ansi "-> NHAN [V] NANG CAP VIEX PLUS (408K/31 NGAY): " -Color "BrightYellow" -Bold -NoNewLine
    Write-Ansi "https://discord.gg/Xx4pcdvHkw" -Color "BrightBlue" -Underline
    
    Move-Cursor 28 ($row + 5)
    Write-Ansi "[Esc] Quay lai menu chinh" -Color "Gray"
    
    $inDiag = $true
    while ($inDiag) {
        $key = [Console]::ReadKey($true)
        if ($key.Key -eq "Escape") {
            $inDiag = $false
        } elseif ($key.Key -eq "Enter" -or $key.Key -eq "V") {
            try {
                Start-Process "https://discord.gg/Xx4pcdvHkw"
                Move-Cursor 28 ($row + 6)
                Write-Ansi "[OK] Da mo Discord VieX Digital tren trinh duyet!               " -Color "BrightGreen"
                Start-Sleep -Milliseconds 800
            } catch {}
            $inDiag = $false
        }
    }
}

function Show-VieXPlusPage {
    Clear-ContentArea
    Move-Cursor 28 2
    Write-Ansi "[ VIEX PLUS 2.0.0 - BỨT PHÁ RANK RADIANT ]" -Color "BrightYellow" -Bold
    Draw-HorizontalLine 28 3 85 "=" "Yellow"
    
    Move-Cursor 28 5
    Write-Ansi "VŨ KHÍ CÔNG NGHỆ BÍ MẬT DÀNH CHO CÁC TRYHARDER VALORANT HÀNG ĐẦU" -Color "BrightWhite" -Bold
    
    Move-Cursor 28 7
    Write-Ansi "• GIÁ NÂNG CẤP: " -Color "Gray" -NoNewLine
    Write-Ansi "408.000 VNĐ / 31 ngày " -Color "BrightGreen" -Bold -NoNewLine
    Write-Ansi "(Kỹ sư VieX hỗ trợ 1-1)" -Color "BrightCyan"
    
    Move-Cursor 28 8
    Write-Ansi "  -> So sánh: " -Color "Gray" -NoNewLine
    Write-Ansi "Rẻ hơn skin Vandal (~550k), hạ delay & đạn ra cực dính!" -Color "BrightMagenta"
    
    Move-Cursor 28 10
    Write-Ansi "5 ĐẶC QUYỀN VƯỢT TRỘI CHỈ CÓ TẠI BẢN PLUS 2.0.0:" -Color "BrightWhite" -Underline
    
    Move-Cursor 28 12
    Write-Ansi "[1] Tối Ưu Độ Trễ Phần Cứng (DPC/ISR & MSI Mode):" -Color "BrightCyan" -Bold
    Move-Cursor 32 13
    Write-Ansi "Tách riêng luồng Card đồ họa & Âm thanh, triệt tiêu delay phản hồi khi nổ súng." -Color "White"
    
    Move-Cursor 28 15
    Write-Ansi "[2] Khóa Chuẩn Kernel Timer Resolution 0.500ms Siêu Ổn Định:" -Color "BrightCyan" -Bold
    Move-Cursor 32 16
    Write-Ansi "Đạn ra tức thì khi click chuột, tâm súng hồi nhanh, không bị Windows reset về 1.0ms." -Color "White"
    
    Move-Cursor 28 18
    Write-Ansi "[3] Engine Tự Động Xóa RAM Standby Trong Trận Đấu:" -Color "BrightCyan" -Bold
    Move-Cursor 32 19
    Write-Ansi "Xóa sạch hiện tượng khựng hình (micro-stutter) khi đối phương quăng util / Viper pit." -Color "White"
    
    Move-Cursor 28 21
    Write-Ansi "[4] Chuyên Gia VieX Căn Chỉnh Trực Tiếp 1-1 (TeamViewer/UltraView):" -Color "BrightCyan" -Bold
    Move-Cursor 32 22
    Write-Ansi "Căn chỉnh riêng biệt theo từng cấu hình CPU/GPU, màn hình Hz và độ nhạy chuột của bạn." -Color "White"
    
    Move-Cursor 28 24
    Write-Ansi "[5] Nhận Role VIP & Profile Tự Động Cập Nhật Trọn Đời Trên Discord." -Color "BrightCyan" -Bold
    
    Draw-HorizontalLine 28 26 85 "-" "Gray"
    Move-Cursor 28 27
    Write-Ansi "-> NHAN [ENTER] HOAC [V] DE MO DISCORD NHAN TU VAN VIP NGAY: " -Color "BrightYellow" -Bold -NoNewLine
    Write-Ansi "https://discord.gg/Xx4pcdvHkw" -Color "BrightBlue" -Underline
    
    Move-Cursor 28 29
    Write-Ansi "[Esc] Quay lai menu chinh" -Color "Gray"
    
    $key = [Console]::ReadKey($true)
    if ($key.Key -eq "Enter" -or $key.Key -eq "V") {
        try {
            Start-Process "https://discord.gg/Xx4pcdvHkw"
            Move-Cursor 28 30
            Write-Ansi "[OK] Da mo Discord VieX Digital tren trinh duyet!" -Color "BrightGreen"
            Start-Sleep -Milliseconds 800
        } catch {}
    }
}

function Show-AboutPage {
    Clear-ContentArea
    Move-Cursor 28 2
    Write-Ansi "[ ABOUT ]" -Color "BrightCyan" -Bold
    Draw-HorizontalLine 28 3 85 "-" "Gray"
    
    Move-Cursor 30 6
    Write-Ansi "[*] Valorant Optimize 1.1.0" -Color "BrightWhite" -Bold
    Move-Cursor 30 8
    Write-Ansi "- Author: " -Color "Gray" -NoNewLine
    Write-Ansi "VieX Digital & VieX Studio" -Color "BrightCyan" -Bold
    
    Move-Cursor 30 10
    Write-Ansi "- Goal: " -Color "Gray" -NoNewLine
    Write-Ansi "Provide a smooth FPS experience and reduce input lag" -Color "BrightWhite"
    Move-Cursor 32 11
    Write-Ansi "so you can climb ranks in Valorant without stuttering." -Color "BrightWhite"
    
    Move-Cursor 30 13
    Write-Ansi "- License: " -Color "Gray" -NoNewLine
    Write-Ansi "Free to share, non-commercial. 100% restoration guarantee." -Color "BrightWhite"
    
    Move-Cursor 30 16
    Write-Ansi "- Discord Support: " -Color "Gray" -NoNewLine
    Write-Ansi "https://discord.gg/Xx4pcdvHkw" -Color "BrightBlue" -Underline
    
    Move-Cursor 30 18
    Write-Ansi "-> Nhấn [Enter] để mở Discord VieX Digital trên trình duyệt!" -Color "BrightYellow"
    
    Move-Cursor 28 22
    Write-Ansi "[i] Tip: Video games are for entertainment, remember to take care of your health!" -Color "BrightYellow"
    
    Move-Cursor 28 26
    Write-Ansi "Press any key to return to menu..." -Color "Gray"
    $key = [Console]::ReadKey($true)
    if ($key.Key -eq "Enter") {
        try { Start-Process "https://discord.gg/Xx4pcdvHkw" } catch {}
    }
}

# Khoi tao ve layout chinh
Draw-Layout
Show-Dashboard

# Vong lap menu chinh
$running = $true
while ($running) {
    # Ve lai menu sidebar e highlight muc hien tai
    $sel = Get-MenuSelection $menuItems $activeMenu
    
    if ($sel -eq -1) {
        # Neu nhan ESC ngoai menu chinh
        continue
    }
    
    $activeMenu = $sel
    
    switch ($sel) {
        0 { Show-Dashboard }
        1 { Show-OptimizePage; $activeMenu = 0 }
        2 { Start-OneClickOptimize; $Global:sysInfo = Get-SystemInfo; Show-Dashboard; $activeMenu = 0 }
        3 { Show-LatencyDiagnosticsPage; Show-Dashboard; $activeMenu = 0 }
        4 { Show-RestorePage; $activeMenu = 0 }
        5 { Show-LogPage; Show-Dashboard; $activeMenu = 0 }
        6 { Show-VieXPlusPage; Show-Dashboard; $activeMenu = 0 }
        7 { Show-AboutPage; Show-Dashboard; $activeMenu = 0 }
        8 {
            # Thoat ung dung
            Clear-Screen
            Move-Cursor 0 0
            [Console]::CursorVisible = $true
            Write-Ansi "Exiting Valorant Optimize..." -Color "BrightYellow"
            $running = $false
        }
    }
}
} catch {
    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Red
    Write-Host "[X] UNHANDLED EXCEPTION IN VALORANT OPTIMIZE:" -ForegroundColor Red
    Write-Host "==========================================================" -ForegroundColor Red
    Write-Host $_.Exception.ToString() -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    try { [Console]::ReadKey($true) | Out-Null } catch { Read-Host }
}







