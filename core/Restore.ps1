# core/Restore.ps1
# Động cơ hoàn trả (Restore) cấu hình hệ thống cho Valorant Optimize 1.0.0

function Get-BackupList {
    $backupRoot = Join-Path $Global:ProjectRoot "backup"
    if (-not (Test-Path $backupRoot)) {
        return @()
    }
    
    # Lấy danh sách các thư mục con và sắp xếp theo ngày giảm dần
    $dirs = Get-ChildItem -Path $backupRoot -Directory | Sort-Object Name -Descending
    return $dirs
}

function Restore-Snapshot {
    param (
        [string]$BackupDir
    )
    
    Write-Log "Khởi động quy trình khôi phục từ snapshot: $BackupDir" "INFO"
    
    $regFile = Join-Path $BackupDir "Registry.json"
    $srvFile = Join-Path $BackupDir "Services.json"
    $pwrFile = Join-Path $BackupDir "PowerPlan.json"
    
    # 1. Khôi phục Registry
    if (Test-Path $regFile) {
        Write-Log "Đang khôi phục Registry..." "INFO"
        try {
            $regBackup = Get-Content $regFile -Raw | ConvertFrom-Json
            foreach ($item in $regBackup) {
                # Đảm bảo đường dẫn tồn tại
                if (-not (Test-Path $item.Path)) {
                    if ($item.Exists) {
                        New-Item -Path $item.Path -Force | Out-Null
                    }
                }
                
                if ($item.Exists) {
                    # Trả lại giá trị cũ
                    # Một số giá trị dạng Hex/DWord/QWord nạp từ JSON có thể cần ép kiểu
                    $val = $item.Value
                    if ($item.Type -eq "DWord") { $val = [int]$item.Value }
                    elseif ($item.Type -eq "QWord") { $val = [long]$item.Value }
                    
                    Set-ItemProperty -Path $item.Path -Name $item.ValueName -Value $val -Type $item.Type -Force -ErrorAction SilentlyContinue | Out-Null
                    Write-Log "Đã khôi phục Registry: $($item.Path) \ $($item.ValueName) = $val" "DEBUG"
                } else {
                    # Nếu lúc trước không tồn tại -> Xóa nó đi
                    if (Test-Path $item.Path) {
                        Remove-ItemProperty -Path $item.Path -Name $item.ValueName -Force -ErrorAction SilentlyContinue | Out-Null
                        Write-Log "Đã xóa Registry tạo thêm: $($item.Path) \ $($item.ValueName)" "DEBUG"
                    }
                }
            }
            Write-Log "Đã khôi phục xong Registry thành công." "SUCCESS"
        } catch {
            Write-Log "Lỗi khi khôi phục Registry: $_" "ERROR"
        }
    }
    
    # 2. Khôi phục Services
    if (Test-Path $srvFile) {
        Write-Log "Đang khôi phục Services..." "INFO"
        try {
            $srvBackup = Get-Content $srvFile -Raw | ConvertFrom-Json
            foreach ($item in $srvBackup) {
                if ($item.Exists -and $item.ServiceName -ne "NonExistent") {
                    $srvName = $item.ServiceName
                    $startupType = $item.StartupType
                    
                    # Chuẩn hóa startup type cho Set-Service (Automatic, Manual, Disabled)
                    if ($startupType -eq "Auto") { $startupType = "Automatic" }
                    elseif ($startupType -eq "Demand") { $startupType = "Manual" }
                    
                    # Thiết lập Startup Type
                    Set-Service -Name $srvName -StartupType $startupType -ErrorAction SilentlyContinue | Out-Null
                    
                    # Thiết lập Status (Running/Stopped)
                    $srv = Get-Service -Name $srvName -ErrorAction SilentlyContinue
                    if ($srv) {
                        if ($item.Status -eq "Running" -and $srv.Status -ne "Running") {
                            Start-Service -Name $srvName -ErrorAction SilentlyContinue | Out-Null
                        } elseif ($item.Status -eq "Stopped" -and $srv.Status -ne "Stopped") {
                            Stop-Service -Name $srvName -ErrorAction SilentlyContinue | Out-Null
                        }
                    }
                    Write-Log "Đã khôi phục Service: $srvName ($startupType, status: $($item.Status))" "DEBUG"
                }
            }
            Write-Log "Đã khôi phục xong các Services." "SUCCESS"
        } catch {
            Write-Log "Lỗi khi khôi phục Services: $_" "ERROR"
        }
    }
    
    # 3. Khôi phục Power Plan
    if (Test-Path $pwrFile) {
        Write-Log "Đang khôi phục Power Plan..." "INFO"
        try {
            $pwrBackup = Get-Content $pwrFile -Raw | ConvertFrom-Json
            if ($pwrBackup -and $pwrBackup.GUID) {
                $guid = $pwrBackup.GUID
                powercfg /setactive $guid
                Write-Log "Đã khôi phục Power Plan thành: $($pwrBackup.Name) ($guid)" "SUCCESS"
            }
        } catch {
            Write-Log "Lỗi khi khôi phục Power Plan: $_" "ERROR"
        }
    }
    
    Write-Log "Khôi phục Snapshot hoàn tất thành công!" "SUCCESS"
    return $true
}

Export-ModuleMember -Function Get-BackupList, Restore-Snapshot


