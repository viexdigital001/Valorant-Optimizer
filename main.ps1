# main.ps1
# iem bat au chinh (Main Entrypoint) cua ung dung Valorant Optimize 1.0.0

# 1. Kiem tra quyen Administrator
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Automatically requesting Administrator privileges..." -ForegroundColor Yellow
    try {
        if ($PSCommandPath) {
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        } else {
            Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\main.ps1`"" -Verb RunAs
        }
        Exit
    } catch {
        Write-Host "[X] FATAL ERROR: Administrator privileges not granted!" -ForegroundColor Red
        Write-Host "Press any key to exit..." -ForegroundColor Gray
        Read-Host | Out-Null
        Exit
    }
}

# 2. Nap Loader va khoi tao du an
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $PSScriptRoot "core\Loader.ps1")
Initialize-Project

# 3. Man hinh mo au (Loading & Logo)
Draw-StartupLogo

# 4. Vong lap giao dien chinh
$menuItems = @(
    "Dashboard",
    "Optimize Mode",
    "One Click Optimize",
    "Restore",
    "Log",
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

function Show-AboutPage {
    Clear-ContentArea
    Move-Cursor 28 2
    Write-Ansi "[ ABOUT ]" -Color "BrightCyan" -Bold
    Draw-HorizontalLine 28 3 85 "-" "Gray"
    
    Move-Cursor 30 6
    Write-Ansi "[*] Valorant Optimize 1.0.0" -Color "BrightWhite" -Bold
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
    Write-Ansi "https://discord.gg/vie-x-digital-1274585470633906176" -Color "BrightBlue" -Underline
    
    Move-Cursor 28 22
    Write-Ansi "[i] Tip: Video games are for entertainment, remember to take care of your health!" -Color "BrightYellow"
    
    Move-Cursor 28 26
    Write-Ansi "Press any key to return to menu..." -Color "Gray"
    [Console]::ReadKey($true) | Out-Null
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
        1 { Show-OptimizePage }
        2 { Start-OneClickOptimize; $Global:sysInfo = Get-SystemInfo; Show-Dashboard }
        3 { Show-RestorePage }
        4 { Show-LogPage; Show-Dashboard }
        5 { Show-AboutPage; Show-Dashboard }
        6 {
            # Thoat ung dung
            Clear-Screen
            Move-Cursor 0 0
            [Console]::CursorVisible = $true
            Write-Ansi "Exiting Valorant Optimize..." -Color "BrightYellow"
            $running = $false
        }
    }
}




