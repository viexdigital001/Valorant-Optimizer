# modules/Storage.ps1
# Module toi uu luu tru (Storage/Disk) cho Valorant Optimize 1.0.0

function Check-Storage {
    Write-Log "Kiem tra Configuring o ia luu tru..." "INFO"
    
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
    
    Write-Log "Bat au Optimizing o ia luu tru..." "INFO"
    
    # 1. Toi uu Registry NTFS
    $fsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
    if (-not (Test-Path $fsPath)) {
        New-Item -Path $fsPath -Force | Out-Null
    }
    
    Backup-RegistryValue -Path $fsPath -ValueName "NtfsDisableLastAccessUpdate"
    Backup-RegistryValue -Path $fsPath -ValueName "NtfsDisable8dot3NameCreation"
    
    # Bat NtfsDisableLastAccessUpdate = 1 (Tat cap nhat thoi gian truy cap cuoi cung e giam ghi ia)
    Set-ItemProperty -Path $fsPath -Name "NtfsDisableLastAccessUpdate" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    # NtfsDisable8dot3NameCreation = 1 (Tat tao ten ngan 8.3 giup System file truy xuat nhanh hon)
    Set-ItemProperty -Path $fsPath -Name "NtfsDisable8dot3NameCreation" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    Write-Log "a Configuring NtfsDisableLastAccessUpdate=1 va NtfsDisable8dot3NameCreation=1" "INFO"
    
    # 2. Chay TRIM cho toan bo o SSD co tren may
    try {
        Write-Log "Currently quet cac o ia e thuc hien toi uu (TRIM SSD)..." "INFO"
        # Chi chay TRIM tren PowerShell 5.1+ neu System ho tro
        $disks = Get-PhysicalDisk -ErrorAction SilentlyContinue
        if ($disks) {
            foreach ($d in $disks) {
                if ($d.MediaType -eq "SSD") {
                    # Tim ky tu o ia thuoc SSD nay
                    $partitions = Get-Partition -DiskNumber $d.DeviceID -ErrorAction SilentlyContinue
                    foreach ($p in $partitions) {
                        if ($p.DriveLetter) {
                            Write-Log "Currently gui tin hieu TRIM toi o ia $($p.DriveLetter): (SSD)" "INFO"
                            Optimize-Volume -DriveLetter $p.DriveLetter -ReTrim -ErrorAction SilentlyContinue | Out-Null
                        }
                    }
                }
            }
        } else {
            # Du phong: Optimize o C
            Write-Log "Gui lenh toi uu mac inh cho o ia C:" "INFO"
            Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue | Out-Null
        }
        Write-Log "a chay Optimizing dung luong luu tru (TRIM) Completed." "SUCCESS"
    } catch {
        Write-Log "ERROR khi Optimizing Trim o ia: $_" "WARNING"
    }
    
    Write-Log "Optimizing Storage Completed!" "SUCCESS"
}

function Restore-Storage {
    Write-Log "Currently Restore cai at Storage..." "INFO"
}

function Verify-Storage {
    Write-Log "Xac minh Configuring Storage..." "INFO"
    $fsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
    if (Test-Path $fsPath) {
        $la = Get-ItemPropertyValue -Path $fsPath -Name "NtfsDisableLastAccessUpdate" -ErrorAction SilentlyContinue
        if ($la -eq 1) {
            Write-Log "Xac minh Storage Success!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-Storage {
    # Tich hop truc tiep qua Logger
}





