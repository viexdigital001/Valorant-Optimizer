# main.ps1
# Điểm bắt đầu chính (Main Entrypoint) của ứng dụng Valorant Optimize 1.0.0

# 1. Kiểm tra quyền Administrator
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "⚠️ Đang tự động yêu cầu quyền Administrator để chạy tối ưu..." -ForegroundColor Yellow
    try {
        if ($PSCommandPath) {
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        } else {
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\main.ps1`"" -Verb RunAs
        }
        Exit
    } catch {
        Write-Host "⚠️ LỖI CỰC MẠNH: Ae chưa cấp quyền Administrator cho phần mềm!" -ForegroundColor Red
        Write-Host "Ấn phím bất kỳ để thoát..." -ForegroundColor Gray
        Read-Host | Out-Null
        Exit
    }
}

# 2. Nạp Loader và khởi tạo dự án
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $PSScriptRoot "core\Loader.ps1")
Initialize-Project

# 3. Màn hình mở đầu (Loading & Logo)
Draw-StartupLogo

# 4. Vòng lặp giao diện chính
$menuItems = @(
    $Global:Lang.menu.dashboard,
    $Global:Lang.menu.optimize,
    $Global:Lang.menu.oneclick,
    $Global:Lang.menu.restore,
    "Nhật ký (Log)",
    $Global:Lang.menu.about,
    $Global:Lang.menu.exit
)

$activeMenu = 0
$sysInfo = Get-SystemInfo # Thu thập thông tin ban đầu

function Show-Dashboard {
    Clear-ContentArea
    Move-Cursor 28 2
    Write-Ansi "💻 DASHBOARD TRẠNG THÁI HỆ THỐNG" -Color "BrightCyan" -Bold
    Draw-HorizontalLine 28 3 85 "═" "Gray"
    
    # Vẽ các cột thông tin
    Move-Cursor 28 5
    Write-Ansi "THÔNG TIN PHẦN CỨNG" -Color "BrightWhite" -Underline
    
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
    Write-Ansi "CẤU HÌNH TỐI ƯU HIỆN TẠI" -Color "BrightWhite" -Underline
    
    # Trạng thái Game Mode
    Move-Cursor 28 14
    Write-Ansi "Game Mode: " -Color "Gray" -NoNewLine
    if ($sysInfo.GameMode) {
        Write-Ansi "🟢 Đang bật" -Color "BrightGreen"
    } else {
        Write-Ansi "🔴 Đang tắt" -Color "BrightRed"
    }
    
    # Trạng thái VBS
    Move-Cursor 28 15
    Write-Ansi "Virtualization-Based Security (VBS): " -Color "Gray" -NoNewLine
    if ($sysInfo.VBS) {
        Write-Ansi "🔴 Đang bật (Nặng máy khi game)" -Color "BrightRed"
    } else {
        Write-Ansi "🟢 Đang tắt (Tối ưu)" -Color "BrightGreen"
    }
    
    # Trạng thái Memory Integrity
    Move-Cursor 28 16
    Write-Ansi "Memory Integrity (HVCI): " -Color "Gray" -NoNewLine
    if ($sysInfo.MemoryIntegrity) {
        Write-Ansi "🔴 Đang bật" -Color "BrightRed"
    } else {
        Write-Ansi "🟢 Đang tắt" -Color "BrightGreen"
    }
    
    # Trạng thái Power Plan
    Move-Cursor 28 17
    Write-Ansi "Sơ đồ nguồn (Power Plan): " -Color "Gray" -NoNewLine
    if ($sysInfo.PowerPlanName -match "Ultimate") {
        Write-Ansi "🟢 $($sysInfo.PowerPlanName)" -Color "BrightGreen" -Bold
    } else {
        Write-Ansi "🟡 $($sysInfo.PowerPlanName) (Khuyên dùng Ultimate)" -Color "BrightYellow"
    }
    
    # Trạng thái Valorant
    Move-Cursor 28 18
    Write-Ansi "Valorant: " -Color "Gray" -NoNewLine
    if ($sysInfo.ValorantInstalled) {
        Write-Ansi "🟢 Đã cài đặt" -Color "BrightGreen"
    } else {
        Write-Ansi "🔴 Chưa cài đặt" -Color "BrightRed"
    }
    
    Move-Cursor 28 20
    Write-Ansi "Riot Vanguard: " -Color "Gray" -NoNewLine
    if ($sysInfo.VanguardInstalled) {
        Write-Ansi "🟢 Đang hoạt động" -Color "BrightGreen"
    } else {
        Write-Ansi "🔴 Chưa cài/chưa chạy" -Color "BrightRed"
    }
    
    Move-Cursor 28 22
    Write-Ansi "Phân loại Profile: " -Color "Gray" -NoNewLine
    Write-Ansi $sysInfo.DeviceProfile -Color "BrightYellow" -Bold
    
    # Footer nhỏ hướng dẫn
    Move-Cursor 28 26
    Write-Ansi "💡 Mẹo Gen Z: Hãy dùng phím mũi tên bên trái để chuyển qua 'One Click' hoặc 'Optimize Mode' nha ae!" -Color "Gray"
}

function Show-OptimizePage {
    Clear-ContentArea
    Move-Cursor 28 2
    Write-Ansi "⚡ CHỌN CHẾ ĐỘ TỐI ƯU HỦY DIỆT" -Color "BrightCyan" -Bold
    Draw-HorizontalLine 28 3 85 "═" "Gray"
    
    $optItems = @(
        "🟢 Competitive (Khuyên dùng cho Tryharder)",
        "🔵 Balanced (Mượt vừa phải, giữ pin ổn định)",
        "🔴 Extreme (Vắt kiệt phần cứng, tắt bảo mật)",
        "◀ Quay lại Menu chính"
    )
    
    $sel = 0
    $subLoop = $true
    
    while ($subLoop) {
        # Vẽ danh sách chế độ
        for ($i = 0; $i -lt $optItems.Count; $i++) {
            Move-Cursor 30 (6 + $i * 2)
            if ($i -eq $sel) {
                Write-Ansi "▶ $($optItems[$i])" -Color "BrightCyan" -Bold
            } else {
                Write-Ansi "  $($optItems[$i])" -Color "White"
            }
            # Thêm khoảng trắng đệm
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
                    
                    # Xác nhận trước khi áp dụng
                    $msg = "Bạn có chắc chắn muốn áp dụng tối ưu chế độ $profileName không?"
                    if ($profileName -eq "Extreme") {
                        $msg = "⚠️ CHÚ Ý: Chế độ Extreme có thể làm yếu bảo mật hệ thống. Vẫn chơi chứ ae?"
                    }
                    
                    $confirm = Get-Confirmation -PromptMessage $msg -Row 15
                    if ($confirm) {
                        Clear-ContentArea
                        Move-Cursor 28 5
                        Write-Ansi "Đang tiến hành tối ưu hóa profile: $profileName..." -Color "BrightCyan"
                        Start-BackupSession
                        
                        # Chạy Apply cho tất cả module
                        $successCount = 0
                        $modules = @("CPU", "GPU", "RAM", "Storage", "PowerPlan", "Timer", "MMCSS", "Services", "Network", "Mouse", "Keyboard", "Input", "Audio", "Security", "Telemetry", "Xbox", "GameMode", "GameStart", "BackgroundApps", "Visual", "Process", "Cleanup")
                        
                        $p = 0
                        foreach ($mName in $modules) {
                            $p += 4
                            Draw-ProgressBar 28 7 $p "Đang cấu hình $mName..."
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
                        Write-Ansi "🎉 Đã tối ưu xong chế độ $profileName cho máy của bạn!" -Color "BrightGreen" -Bold
                        Move-Cursor 28 11
                        Write-Ansi "Vui lòng khởi động lại máy để chiến game mượt đét nhé! 🚀" -Color "BrightYellow"
                        
                        Move-Cursor 28 13
                        Write-Ansi $Global:Lang.general.press_key -Color "Gray"
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
    
    # Reload lại thông tin
    $Global:sysInfo = Get-SystemInfo
    Show-Dashboard
}

function Show-RestorePage {
    Clear-ContentArea
    Move-Cursor 28 2
    Write-Ansi "🔄 HOÀN TRẢ CÀI ĐẶT HỆ THỐNG" -Color "BrightCyan" -Bold
    Draw-HorizontalLine 28 3 85 "═" "Gray"
    
    $backups = Get-BackupList
    if ($backups.Count -eq 0) {
        Move-Cursor 28 5
        Write-Ansi "Không tìm thấy bản sao lưu snapshot nào trong hệ thống!" -Color "BrightRed"
        Move-Cursor 28 7
        Write-Ansi $Global:Lang.general.press_key -Color "Gray"
        [Console]::ReadKey($true) | Out-Null
        return
    }
    
    Move-Cursor 28 5
    Write-Ansi "Chọn bản sao lưu muốn khôi phục:" -Color "BrightWhite"
    
    $sel = 0
    $subLoop = $true
    
    while ($subLoop) {
        for ($i = 0; $i -lt $backups.Count; $i++) {
            Move-Cursor 30 (7 + $i)
            $folderName = $backups[$i].Name
            if ($i -eq $sel) {
                Write-Ansi "▶ $folderName" -Color "BrightCyan" -Bold
            } else {
                Write-Ansi "  $folderName" -Color "White"
            }
        }
        
        Move-Cursor 30 (7 + $backups.Count + 1)
        if ($sel -eq $backups.Count) {
            Write-Ansi "▶ ◀ Quay lại" -Color "BrightCyan" -Bold
        } else {
            Write-Ansi "  Quay lại" -Color "White"
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
                    $confirm = Get-Confirmation -PromptMessage "Bạn có muốn khôi phục lại bản snapshot này không?" -Row 16
                    if ($confirm) {
                        Clear-ContentArea
                        Move-Cursor 28 5
                        Write-Ansi "Đang khôi phục cài đặt..." -Color "BrightCyan"
                        
                        # Chạy khôi phục
                        Restore-Snapshot -BackupDir $selectedBackup
                        
                        Move-Cursor 28 10
                        Write-Ansi "🎉 Khôi phục hoàn tất! Khởi động lại máy nha ae!" -Color "BrightGreen" -Bold
                        Move-Cursor 28 12
                        Write-Ansi $Global:Lang.general.press_key -Color "Gray"
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
    Write-Ansi "📜 NHẬT KÝ HOẠT ĐỘNG (LOG FILE)" -Color "BrightCyan" -Bold
    Draw-HorizontalLine 28 3 85 "═" "Gray"
    
    if (Test-Path $Global:LogFilePath) {
        $logs = Get-Content -Path $Global:LogFilePath -Tail 20
        $row = 5
        foreach ($line in $logs) {
            Move-Cursor 28 $row
            # Cắt bớt dòng dài
            $trimmed = if ($line.Length -gt 88) { $line.Substring(0, 85) + "..." } else { $line }
            
            # Tô màu log line
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
        Write-Ansi "Chưa có log file nào được tạo." -Color "Gray"
    }
    
    Move-Cursor 28 27
    Write-Ansi "Nhấn phím bất kỳ để quay lại menu..." -Color "Gray"
    [Console]::ReadKey($true) | Out-Null
}

function Show-AboutPage {
    Clear-ContentArea
    Move-Cursor 28 2
    Write-Ansi "ℹ GIỚI THIỆU PHẦN MỀM" -Color "BrightCyan" -Bold
    Draw-HorizontalLine 28 3 85 "═" "Gray"
    
    Move-Cursor 30 6
    Write-Ansi "🎮 Valorant Optimize 1.0.0" -Color "BrightWhite" -Bold
    Move-Cursor 30 8
    Write-Ansi "• Tác giả: " -Color "Gray" -NoNewLine
    Write-Ansi "VieX Digital & VieX Studio" -Color "BrightCyan" -Bold
    
    Move-Cursor 30 10
    Write-Ansi "• Mục tiêu: " -Color "Gray" -NoNewLine
    Write-Ansi "Mang lại trải nghiệm FPS mượt mà và giảm độ trễ chuột/phím" -Color "BrightWhite"
    Move-Cursor 32 11
    Write-Ansi "để ae leo rank Valorant dễ dàng hơn mà không bị khựng combat." -Color "BrightWhite"
    
    Move-Cursor 30 13
    Write-Ansi "• Bản quyền: " -Color "Gray" -NoNewLine
    Write-Ansi "Tự do chia sẻ và phi thương mại. Bảo hiểm khôi phục 100%." -Color "BrightWhite"
    
    Move-Cursor 30 16
    Write-Ansi "👉 Discord liên hệ hỗ trợ: " -Color "Gray" -NoNewLine
    Write-Ansi "https://discord.gg/VieX" -Color "BrightBlue" -Underline
    
    Move-Cursor 28 22
    Write-Ansi "Mẹo Gen Z: Trò chơi điện tử là để giải trí, nhớ giữ gìn sức khỏe nhé ae! 🤙" -Color "BrightYellow"
    
    Move-Cursor 28 26
    Write-Ansi "Nhấn phím bất kỳ để quay lại menu..." -Color "Gray"
    [Console]::ReadKey($true) | Out-Null
}

# Khởi tạo vẽ layout chính
Draw-Layout
Show-Dashboard

# Vòng lặp menu chính
$running = $true
while ($running) {
    # Vẽ lại menu sidebar để highlight mục hiện tại
    $sel = Get-MenuSelection $menuItems $activeMenu
    
    if ($sel -eq -1) {
        # Nếu nhấn ESC ngoài menu chính
        continue
    }
    
    $activeMenu = $sel
    
    switch ($sel) {
        0 { Show-Dashboard }
        1 { Show-OptimizePage }
        2 { Start-OneClickOptimize; $Global:sysInfo = Get-SystemInfo; Show-Dashboard }
        3 { Show-RestorePage }
        4 { Show-LogPage; Show-Dashboard }
        5 { Show-AboutPage; Show-Dashboard }
        6 {
            # Thoát ứng dụng
            Clear-Screen
            Move-Cursor 0 0
            [Console]::CursorVisible = $true
            Write-Ansi $Global:Lang.general.exit_msg -Color "BrightYellow"
            $running = $false
        }
    }
}


