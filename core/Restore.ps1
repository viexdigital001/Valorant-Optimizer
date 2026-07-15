# core/Restore.ps1
# ong co hoan tra (Restore) Configuring System cho Valorant Optimize 1.0.0

function Get-BackupList {
    $backupRoot = Join-Path $Global:ProjectRoot "backup"
    if (-not (Test-Path $backupRoot)) {
        return @()
    }
    
    # Lay danh sach cac thu muc con va sap xep theo ngay giam dan
    $dirs = Get-ChildItem -Path $backupRoot -Directory | Sort-Object Name -Descending
    return $dirs
}

function Restore-Snapshot {
    param (
        [string]$BackupDir
    )
    
    Write-Log "Khoi ong quy trinh Restore tu snapshot: $BackupDir" "INFO"
    
    $regFile = Join-Path $BackupDir "Registry.json"
    $srvFile = Join-Path $BackupDir "Services.json"
    $pwrFile = Join-Path $BackupDir "PowerPlan.json"
    
    # 1. Restore Registry
    if (Test-Path $regFile) {
        Write-Log "Currently Restore Registry..." "INFO"
        try {
            $regBackup = Get-Content $regFile -Raw | ConvertFrom-Json
            foreach ($item in $regBackup) {
                # am bao uong dan ton tai
                if (-not (Test-Path $item.Path)) {
                    if ($item.Exists) {
                        New-Item -Path $item.Path -Force | Out-Null
                    }
                }
                
                if ($item.Exists) {
                    # Tra lai gia tri cu
                    # Mot so gia tri dang Hex/DWord/QWord nap tu JSON co the can ep kieu
                    $val = $item.Value
                    if ($item.Type -eq "DWord") { $val = [int]$item.Value }
                    elseif ($item.Type -eq "QWord") { $val = [long]$item.Value }
                    
                    Set-ItemProperty -Path $item.Path -Name $item.ValueName -Value $val -Type $item.Type -Force -ErrorAction SilentlyContinue | Out-Null
                    Write-Log "a Restore Registry: $($item.Path) \ $($item.ValueName) = $val" "DEBUG"
                } else {
                    # Neu luc truoc khong ton tai -> Xoa no i
                    if (Test-Path $item.Path) {
                        Remove-ItemProperty -Path $item.Path -Name $item.ValueName -Force -ErrorAction SilentlyContinue | Out-Null
                        Write-Log "a xoa Registry tao them: $($item.Path) \ $($item.ValueName)" "DEBUG"
                    }
                }
            }
            Write-Log "a Restore xong Registry Success." "SUCCESS"
        } catch {
            Write-Log "ERROR khi Restore Registry: $_" "ERROR"
        }
    }
    
    # 2. Restore Services
    if (Test-Path $srvFile) {
        Write-Log "Currently Restore Services..." "INFO"
        try {
            $srvBackup = Get-Content $srvFile -Raw | ConvertFrom-Json
            foreach ($item in $srvBackup) {
                if ($item.Exists -and $item.ServiceName -ne "NonExistent") {
                    $srvName = $item.ServiceName
                    $startupType = $item.StartupType
                    
                    # Chuan hoa startup type cho Set-Service (Automatic, Manual, Disabled)
                    if ($startupType -eq "Auto") { $startupType = "Automatic" }
                    elseif ($startupType -eq "Demand") { $startupType = "Manual" }
                    
                    # Thiet lap Startup Type
                    Set-Service -Name $srvName -StartupType $startupType -ErrorAction SilentlyContinue | Out-Null
                    
                    # Thiet lap Status (Running/Stopped)
                    $srv = Get-Service -Name $srvName -ErrorAction SilentlyContinue
                    if ($srv) {
                        if ($item.Status -eq "Running" -and $srv.Status -ne "Running") {
                            Start-Service -Name $srvName -ErrorAction SilentlyContinue | Out-Null
                        } elseif ($item.Status -eq "Stopped" -and $srv.Status -ne "Stopped") {
                            Stop-Service -Name $srvName -ErrorAction SilentlyContinue | Out-Null
                        }
                    }
                    Write-Log "a Restore Service: $srvName ($startupType, status: $($item.Status))" "DEBUG"
                }
            }
            Write-Log "a Restore xong cac Services." "SUCCESS"
        } catch {
            Write-Log "ERROR khi Restore Services: $_" "ERROR"
        }
    }
    
    # 3. Restore Power Plan
    if (Test-Path $pwrFile) {
        Write-Log "Currently Restore Power Plan..." "INFO"
        try {
            $pwrBackup = Get-Content $pwrFile -Raw | ConvertFrom-Json
            if ($pwrBackup -and $pwrBackup.GUID) {
                $guid = $pwrBackup.GUID
                powercfg /setactive $guid
                Write-Log "a Restore Power Plan thanh: $($pwrBackup.Name) ($guid)" "SUCCESS"
            }
        } catch {
            Write-Log "ERROR khi Restore Power Plan: $_" "ERROR"
        }
    }
    
    Write-Log "Restore Snapshot Completed Success!" "SUCCESS"
    return $true
}





