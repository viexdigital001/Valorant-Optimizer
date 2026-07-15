# core/OptimizeEngine.ps1
# Bo may Optimizing thong minh One Click cho Valorant Optimize 1.0.0

function Start-OneClickOptimize {
    Clear-ContentArea
    
    # Tieu e con tro
    Move-Cursor 28 2
    Write-Ansi "[*] ONE CLICK SMART OPTIMIZE ENGINE" -Color "BrightCyan" -Bold
    Draw-HorizontalLine 28 3 85 "-" "Gray"
    
    Move-Cursor 28 5
    Write-Ansi "Currently phan tich System..." -Color "BrightWhite"
    Start-Sleep -Milliseconds 300
    
    # 1. Thu thap thong tin phan cung
    $sys = Get-SystemInfo
    
    $itemsToCheck = @(
        @{ Label = "CPU Model"; Value = $sys.CPUModel }
        @{ Label = "GPU Model"; Value = $sys.GPUModel }
        @{ Label = "RAM Size"; Value = "$($sys.RAMSizeGB) GB" }
        @{ Label = "Windows"; Value = $sys.OSName }
        @{ Label = "Device Type"; Value = if ($sys.IsLaptop) { "Laptop" } else { "Desktop" } }
        @{ Label = "Secure Boot"; Value = if ($sys.SecureBoot) { "Bat" } else { "Tat" } }
        @{ Label = "Game Mode"; Value = if ($sys.GameMode) { "Bat" } else { "Tat" } }
        @{ Label = "Memory Integrity"; Value = if ($sys.MemoryIntegrity) { "Bat" } else { "Tat" } }
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
    
    # 2. Phan loai Configuring va chon Profile toi uu phu hop
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
    Write-Ansi "a xac inh ho so thiet bi: " -Color "BrightWhite" -NoNewLine
    Write-Ansi "$($sys.DeviceProfile)" -Color "BrightGreen" -Bold
    
    Move-Cursor 28 ($row + 2)
    Write-Ansi "Profile toi uu e xuat: " -Color "BrightWhite" -NoNewLine
    Write-Ansi "$recommendedProfile" -Color "BrightYellow" -Bold
    
    # Neu phat hien laptop -> WARNING nhe nhang Gen Z
    if ($sys.IsLaptop) {
        Move-Cursor 28 ($row + 4)
        Write-Ansi "[PC] a phat hien Laptop chien game. Currently Configuring nguon bao ve quat va pin nha ae!" -Color "BrightCyan"
        Start-Sleep -Milliseconds 500
    }
    
    # Xac nhan truoc khi toi uu
    $confirm = Get-Confirmation -PromptMessage "Ban co muon bat au toi uu ngay khong?" -Row ($row + 6)
    if (-not $confirm) {
        Clear-ContentArea
        Move-Cursor 28 10
        Write-Ansi "a huy Optimizing. Hay chon lai menu ben trai nha ae! " -Color "BrightYellow"
        return
    }
    
    # 3. Chay Optimizing
    Clear-ContentArea
    Move-Cursor 28 2
    Write-Ansi "[*] TIEN TRINH Optimizing System" -Color "BrightCyan" -Bold
    Draw-HorizontalLine 28 3 85 "-" "Gray"
    
    # Bat au sao luu
    Move-Cursor 28 5
    Write-Ansi "Currently khoi tao Backup snapshot snapshot..." -Color "BrightWhite"
    Start-BackupSession
    Start-Sleep -Milliseconds 500
    
    # Danh sach cac module chay
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
        
        # Ve thanh tien trinh
        Draw-ProgressBar 28 6 $percent "Currently Configuring module: $($mod.Name)..."
        
        # Chay ham apply tuong ung
        if (Get-Command $mod.Func -ErrorAction SilentlyContinue) {
            try {
                Invoke-Expression "$($mod.Func) -Config `$configObject" | Out-Null
                
                # Xac minh
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
                Write-Log "ERROR Applying module $($mod.Name): $_" "ERROR"
                $skipCount++
            }
        } else {
            Write-Log "Bo qua module $($mod.Name) (Khong tim thay lenh thuc thi)" "WARNING"
            $skipCount++
        }
        
        Start-Sleep -Milliseconds 200
    }
    
    # Luu Backup snapshot
    Save-BackupSession
    
    # 4. Hien thi bao cao va quang cao
    Clear-ContentArea
    Move-Cursor 28 2
    Write-Ansi "[*] Optimizing Completed" -Color "BrightGreen" -Bold
    Draw-HorizontalLine 28 3 85 "-" "Gray"
    
    Move-Cursor 28 5
    Write-Ansi " Xong luon! May cua ban a uoc toi uu cuc ky muot ma." -Color "BrightCyan"
    
    Move-Cursor 28 7
    Write-Ansi "Ket qua toi uu:" -Color "BrightWhite" -Underline
    Move-Cursor 28 9
    Write-Ansi "[V] So module Optimized: " -NoNewLine
    Write-Ansi "$successCount" -Color "BrightGreen" -Bold
    
    Move-Cursor 28 10
    Write-Ansi " So module bo qua/ERROR: " -NoNewLine
    Write-Ansi "$skipCount" -Color "BrightYellow" -Bold
    
    Move-Cursor 28 12
    Write-Ansi "[i] Khuyen nghi: Hay Restart PC e cac thay oi hoat ong tot nhat." -Color "BrightWhite"
    Move-Cursor 28 13
    Write-Ansi "Chuc ae co nhung pha ACE that chay, giu aim dinh nhu keo 502 nha! " -Color "BrightYellow"
    
    # Banner quang cao premium
    Move-Cursor 28 16
    Write-Ansi "" -Color "Gray"
    Move-Cursor 28 17
    Write-Ansi " MUON MAY CON MUOT HON NUA? TIM HIEU PHIEN BAN NANG CAP:" -Color "BrightRed" -Bold
    Move-Cursor 28 18
    Write-Ansi "   VieXF Ultimate" -Color "BrightCyan" -Bold -NoNewLine
    Write-Ansi " - Optimizing triet e, cap nhat tweak thuong xuyen." -Color "BrightWhite"
    Move-Cursor 28 20
    Write-Ansi "-> Discord: " -NoNewLine
    Write-Ansi "https://discord.com/channels/1274585470633906176/1416609764779098162" -Color "BrightBlue" -Underline
    Move-Cursor 28 21
    Write-Ansi "" -Color "Gray"
    
    Move-Cursor 28 23
    Write-Ansi "Press any key to quay lai menu..." -Color "Gray"
    [Console]::ReadKey($true) | Out-Null
}





