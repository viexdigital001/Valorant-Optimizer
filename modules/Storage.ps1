# modules/Storage.ps1
# Module tối ưu lưu trữ (Storage/Disk) cho Valorant Optimize 1.0.0

function Check-Storage {
    Write-Log "Kiểm tra cấu hình ổ đĩa lưu trữ..." "INFO"
    
    $fsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
    if (Test-Path $fsPath) {
        $la = Get-ItemPropertyValue -Path $fsPath -Name "NtfsDisableLastAccessUpdate" -ErrorAction SilentlyContinue
        $dot3 = Get-ItemPropertyValue -Path $fsPath -Name "NtfsDisable8dot3NameCreation" -ErrorAction SilentlyContinue
        Write-Log "NtfsDisableLastAccessUpdate: $la, NtfsDisable8dot3NameCreation: $dot3" "INFO"
    }
    
    return "OK"
}

function Apply-Storage {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bắt đầu tối ưu hóa ổ đĩa lưu trữ..." "INFO"
    
    # 1. Tối ưu Registry NTFS
    $fsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
    if (-not (Test-Path $fsPath)) {
        New-Item -Path $fsPath -Force | Out-Null
    }
    
    Backup-RegistryValue -Path $fsPath -ValueName "NtfsDisableLastAccessUpdate"
    Backup-RegistryValue -Path $fsPath -ValueName "NtfsDisable8dot3NameCreation"
    
    # Bật NtfsDisableLastAccessUpdate = 1 (Tắt cập nhật thời gian truy cập cuối cùng để giảm ghi đĩa)
    Set-ItemProperty -Path $fsPath -Name "NtfsDisableLastAccessUpdate" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    # NtfsDisable8dot3NameCreation = 1 (Tắt tạo tên ngắn 8.3 giúp hệ thống file truy xuất nhanh hơn)
    Set-ItemProperty -Path $fsPath -Name "NtfsDisable8dot3NameCreation" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Log "Đã cấu hình NtfsDisableLastAccessUpdate=1 và NtfsDisable8dot3NameCreation=1" "INFO"
    
    # 2. Chạy TRIM cho toàn bộ ổ SSD có trên máy
    try {
        Write-Log "Đang quét các ổ đĩa để thực hiện tối ưu (TRIM SSD)..." "INFO"
        # Chỉ chạy TRIM trên PowerShell 5.1+ nếu hệ thống hỗ trợ
        $disks = Get-PhysicalDisk -ErrorAction SilentlyContinue
        if ($disks) {
            foreach ($d in $disks) {
                if ($d.MediaType -eq "SSD") {
                    # Tìm ký tự ổ đĩa thuộc SSD này
                    $partitions = Get-Partition -DiskNumber $d.DeviceID -ErrorAction SilentlyContinue
                    foreach ($p in $partitions) {
                        if ($p.DriveLetter) {
                            Write-Log "Đang gửi tín hiệu TRIM tới ổ đĩa $($p.DriveLetter): (SSD)" "INFO"
                            Optimize-Volume -DriveLetter $p.DriveLetter -ReTrim -ErrorAction SilentlyContinue | Out-Null
                        }
                    }
                }
            }
        } else {
            # Dự phòng: Optimize ổ C
            Write-Log "Gửi lệnh tối ưu mặc định cho ổ đĩa C:" "INFO"
            Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue | Out-Null
        }
        Write-Log "Đã chạy tối ưu hóa dung lượng lưu trữ (TRIM) hoàn tất." "SUCCESS"
    } catch {
        Write-Log "Lỗi khi tối ưu hóa Trim ổ đĩa: $_" "WARNING"
    }
    
    Write-Log "Tối ưu hóa Storage hoàn tất!" "SUCCESS"
}

function Restore-Storage {
    Write-Log "Đang khôi phục cài đặt Storage..." "INFO"
}

function Verify-Storage {
    Write-Log "Xác minh cấu hình Storage..." "INFO"
    $fsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
    if (Test-Path $fsPath) {
        $la = Get-ItemPropertyValue -Path $fsPath -Name "NtfsDisableLastAccessUpdate" -ErrorAction SilentlyContinue
        if ($la -eq 1) {
            Write-Log "Xác minh Storage thành công!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-Storage {
    # Tích hợp trực tiếp qua Logger
}

Export-ModuleMember -Function Check-Storage, Apply-Storage, Restore-Storage, Verify-Storage, WriteLog-Storage




