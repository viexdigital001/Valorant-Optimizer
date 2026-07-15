# core/OptimizeEngine.ps1
# Bộ máy tối ưu hóa thông minh One Click cho Valorant Optimize 1.0.0

function Start-OneClickOptimize {
    Clear-ContentArea
    
    # Tiêu đề con trỏ
    Move-Cursor 28 2
    Write-Ansi "⚡ ONE CLICK SMART OPTIMIZE ENGINE" -Color "BrightCyan" -Bold
    Draw-HorizontalLine 28 3 85 "═" "Gray"
    
    Move-Cursor 28 5
    Write-Ansi "Đang phân tích hệ thống..." -Color "BrightWhite"
    Start-Sleep -Milliseconds 300
    
    # 1. Thu thập thông tin phần cứng
    $sys = Get-SystemInfo
    
    $itemsToCheck = @(
        @{ Label = "CPU Model"; Value = $sys.CPUModel }
        @{ Label = "GPU Model"; Value = $sys.GPUModel }
        @{ Label = "RAM Size"; Value = "$($sys.RAMSizeGB) GB" }
        @{ Label = "Windows"; Value = $sys.OSName }
        @{ Label = "Device Type"; Value = if ($sys.IsLaptop) { "Laptop" } else { "Desktop" } }
        @{ Label = "Secure Boot"; Value = if ($sys.SecureBoot) { "Bật" } else { "Tắt" } }
        @{ Label = "Game Mode"; Value = if ($sys.GameMode) { "Bật" } else { "Tắt" } }
        @{ Label = "Memory Integrity"; Value = if ($sys.MemoryIntegrity) { "Bật" } else { "Tắt" } }
    )
    
    $row = 7
    foreach ($item in $itemsToCheck) {
        Move-Cursor 28 $row
        $dots = "." * (30 - $item.Label.Length)
        Write-Ansi "$($item.Label) $dots " -Color "Gray" -NoNewLine
        Write-Ansi $item.Value -Color "BrightCyan"
        $row++
        Start-Sleep -Milliseconds 100
    }
    
    # 2. Phân loại cấu hình và chọn Profile tối ưu phù hợp
    $recommendedProfile = "Balanced"
    $configObject = $Global:ConfigBalanced
    
    if ($sys.DeviceProfile -eq "High-End PC") {
        $recommendedProfile = "Extreme"
        $configObject = $Global:ConfigExtreme
    } elseif ($sys.DeviceProfile -eq "Mid-End PC") {
        $recommendedProfile = "Competitive"
        $configObject = $Global:ConfigCompetitive
    }
    
    Move-Cursor 28 ($row + 1)
    Write-Ansi "Đã xác định hồ sơ thiết bị: " -Color "BrightWhite" -NoNewLine
    Write-Ansi "$($sys.DeviceProfile)" -Color "BrightGreen" -Bold
    
    Move-Cursor 28 ($row + 2)
    Write-Ansi "Profile tối ưu đề xuất: " -Color "BrightWhite" -NoNewLine
    Write-Ansi "$recommendedProfile" -Color "BrightYellow" -Bold
    
    # Nếu phát hiện laptop -> cảnh báo nhẹ nhàng Gen Z
    if ($sys.IsLaptop) {
        Move-Cursor 28 ($row + 4)
        Write-Ansi "💻 Đã phát hiện Laptop chiến game. Đang cấu hình nguồn bảo vệ quạt và pin nha ae!" -Color "BrightCyan"
        Start-Sleep -Milliseconds 500
    }
    
    # Xác nhận trước khi tối ưu
    $confirm = Get-Confirmation -PromptMessage "Bạn có muốn bắt đầu tối ưu ngay không?" -Row ($row + 6)
    if (-not $confirm) {
        Clear-ContentArea
        Move-Cursor 28 10
        Write-Ansi "Đã hủy tối ưu hóa. Hãy chọn lại menu bên trái nha ae! 🤙" -Color "BrightYellow"
        return
    }
    
    # 3. Chạy tối ưu hóa
    Clear-ContentArea
    Move-Cursor 28 2
    Write-Ansi "🚀 TIẾN TRÌNH TỐI ƯU HÓA HỆ THỐNG" -Color "BrightCyan" -Bold
    Draw-HorizontalLine 28 3 85 "═" "Gray"
    
    # Bắt đầu sao lưu
    Move-Cursor 28 5
    Write-Ansi "Đang khởi tạo bản sao lưu snapshot..." -Color "BrightWhite"
    Start-BackupSession
    Start-Sleep -Milliseconds 500
    
    # Danh sách các module chạy
    $modules = @(
        @{ Name = "CPU"; Func = "Apply-CPU"; Verify = "Verify-CPU" }
        @{ Name = "GPU"; Func = "Apply-GPU"; Verify = "Verify-GPU" }
        @{ Name = "RAM"; Func = "Apply-RAM"; Verify = "Verify-RAM" }
        @{ Name = "Storage"; Func = "Apply-Storage"; Verify = "Verify-Storage" }
        @{ Name = "PowerPlan"; Func = "Apply-PowerPlan"; Verify = "Verify-PowerPlan" }
        @{ Name = "Timer"; Func = "Apply-Timer"; Verify = "Verify-Timer" }
        @{ Name = "MMCSS"; Func = "Apply-MMCSS"; Verify = "Verify-MMCSS" }
        @{ Name = "Services"; Func = "Apply-Services"; Verify = "Verify-Services" }
        @{ Name = "Network"; Func = "Apply-Network"; Verify = "Verify-Network" }
        @{ Name = "Mouse"; Func = "Apply-Mouse"; Verify = "Verify-Mouse" }
        @{ Name = "Keyboard"; Func = "Apply-Keyboard"; Verify = "Verify-Keyboard" }
        @{ Name = "Input"; Func = "Apply-Input"; Verify = "Verify-Input" }
        @{ Name = "Audio"; Func = "Apply-Audio"; Verify = "Verify-Audio" }
        @{ Name = "Security"; Func = "Apply-Security"; Verify = "Verify-Security" }
        @{ Name = "Telemetry"; Func = "Apply-Telemetry"; Verify = "Verify-Telemetry" }
        @{ Name = "Xbox"; Func = "Apply-Xbox"; Verify = "Verify-Xbox" }
        @{ Name = "GameMode"; Func = "Apply-GameMode"; Verify = "Verify-GameMode" }
        @{ Name = "GameStart"; Func = "Apply-GameStart"; Verify = "Verify-GameStart" }
        @{ Name = "BackgroundApps"; Func = "Apply-BackgroundApps"; Verify = "Verify-BackgroundApps" }
        @{ Name = "Visual"; Func = "Apply-Visual"; Verify = "Verify-Visual" }
        @{ Name = "Process"; Func = "Apply-Process"; Verify = "Verify-Process" }
        @{ Name = "Cleanup"; Func = "Apply-Cleanup"; Verify = "Verify-Cleanup" }
    )
    
    $successCount = 0
    $skipCount = 0
    
    for ($idx = 0; $idx -lt $modules.Count; $idx++) {
        $mod = $modules[$idx]
        $percent = [int](($idx + 1) / $modules.Count * 100)
        
        # Vẽ thanh tiến trình
        Draw-ProgressBar 28 6 $percent "Đang cấu hình module: $($mod.Name)..."
        
        # Chạy hàm apply tương ứng
        if (Get-Command $mod.Func -ErrorAction SilentlyContinue) {
            try {
                Invoke-Expression "$($mod.Func) -Config `$configObject" | Out-Null
                
                # Xác minh
                $verified = $true
                if (Get-Command $mod.Verify -ErrorAction SilentlyContinue) {
                    $verified = Invoke-Expression $mod.Verify
                }
                
                if ($verified) {
                    $successCount++
                } else {
                    $skipCount++
                }
            } catch {
                Write-Log "Lỗi áp dụng module $($mod.Name): $_" "ERROR"
                $skipCount++
            }
        } else {
            Write-Log "Bỏ qua module $($mod.Name) (Không tìm thấy lệnh thực thi)" "WARNING"
            $skipCount++
        }
        
        Start-Sleep -Milliseconds 200
    }
    
    # Lưu bản sao lưu
    Save-BackupSession
    
    # 4. Hiển thị báo cáo và quảng cáo
    Clear-ContentArea
    Move-Cursor 28 2
    Write-Ansi "🎉 TỐI ƯU HÓA HOÀN TẤT" -Color "BrightGreen" -Bold
    Draw-HorizontalLine 28 3 85 "═" "Gray"
    
    Move-Cursor 28 5
    Write-Ansi "🔥 Xong luôn! Máy của bạn đã được tối ưu cực kỳ mượt mà." -Color "BrightCyan"
    
    Move-Cursor 28 7
    Write-Ansi "Kết quả tối ưu:" -Color "BrightWhite" -Underline
    Move-Cursor 28 9
    Write-Ansi "✔ Số module đã tối ưu: " -NoNewLine
    Write-Ansi "$successCount" -Color "BrightGreen" -Bold
    
    Move-Cursor 28 10
    Write-Ansi "⚠ Số module bỏ qua/lỗi: " -NoNewLine
    Write-Ansi "$skipCount" -Color "BrightYellow" -Bold
    
    Move-Cursor 28 12
    Write-Ansi "💡 Khuyến nghị: Hãy khởi động lại máy để các thay đổi hoạt động tốt nhất." -Color "BrightWhite"
    Move-Cursor 28 13
    Write-Ansi "Chúc ae có những pha ACE thật cháy, giữ aim dính như keo 502 nha! 🎯" -Color "BrightYellow"
    
    # Banner quảng cáo premium
    Move-Cursor 28 16
    Write-Ansi "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -Color "Gray"
    Move-Cursor 28 17
    Write-Ansi "🔥 MUỐN MÁY CÒN MƯỢT HƠN NỮA? TÌM HIỂU PHIÊN BẢN NÂNG CẤP:" -Color "BrightRed" -Bold
    Move-Cursor 28 18
    Write-Ansi "   VieXF Ultimate" -Color "BrightCyan" -Bold -NoNewLine
    Write-Ansi " - Tối ưu hóa triệt để, cập nhật tweak thường xuyên." -Color "BrightWhite"
    Move-Cursor 28 20
    Write-Ansi "👉 Discord: " -NoNewLine
    Write-Ansi "https://discord.com/channels/1274585470633906176/1416609764779098162" -Color "BrightBlue" -Underline
    Move-Cursor 28 21
    Write-Ansi "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -Color "Gray"
    
    Move-Cursor 28 23
    Write-Ansi "Nhấn phím bất kỳ để quay lại menu..." -Color "Gray"
    [Console]::ReadKey($true) | Out-Null
}





