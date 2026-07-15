# core/Backup.ps1
# Động cơ sao lưu snapshot thiết lập cho Valorant Optimize 1.0.0

$Global:BackupSessionActive = $false
$Global:BackupRegistry = @()
$Global:BackupServices = @()
$Global:BackupPowerPlan = @{}
$Global:BackupNetwork = @{}
$Global:BackupWindows = @{}

function Start-BackupSession {
    $dateStr = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
    $Global:CurrentBackupDir = Join-Path $Global:ProjectRoot "backup\$dateStr"
    
    if (-not (Test-Path $Global:CurrentBackupDir)) {
        New-Item -ItemType Directory -Path $Global:CurrentBackupDir -Force | Out-Null
    }
    
    $Global:BackupRegistry = @()
    $Global:BackupServices = @()
    $Global:BackupPowerPlan = @{}
    $Global:BackupNetwork = @{}
    $Global:BackupWindows = @{}
    $Global:BackupSessionActive = $true
    
    Write-Log "Khởi tạo phiên sao lưu tại: $Global:CurrentBackupDir" "INFO"
}

function Backup-RegistryValue {
    param (
        [string]$Path,
        [string]$ValueName
    )
    
    if (-not $Global:BackupSessionActive) { return }

    # Chuẩn hóa đường dẫn registry (VD: HKEY_LOCAL_MACHINE -> HKLM)
    $normalizedPath = $Path
    if ($Path -like "HKEY_LOCAL_MACHINE*") {
        $normalizedPath = $Path -replace "HKEY_LOCAL_MACHINE", "HKLM:"
    } elseif ($Path -like "HKEY_CURRENT_USER*") {
        $normalizedPath = $Path -replace "HKEY_CURRENT_USER", "HKCU:"
    }
    
    $exists = $false
    $type = ""
    $val = $null
    
    if (Test-Path $normalizedPath) {
        $key = Get-Item -Path $normalizedPath
        if ($key.GetValueNames() -contains $ValueName) {
            $exists = $true
            $val = $key.GetValue($ValueName)
            $type = $key.GetValueKind($ValueName).ToString()
        }
    }
    
    $record = [ordered]@{
        Path      = $normalizedPath
        ValueName = $ValueName
        Exists    = $exists
        Type      = $type
        Value     = $val
    }
    
    # Kiểm tra xem đã backup trùng chưa
    $alreadyBackedUp = $Global:BackupRegistry | Where-Object { $_.Path -eq $normalizedPath -and $_.ValueName -eq $ValueName }
    if (-not $alreadyBackedUp) {
        $Global:BackupRegistry += [PSCustomObject]$record
        Write-Log "Backup Registry: $normalizedPath \ $ValueName (Exists: $exists)" "DEBUG"
    }
}

function Backup-Service {
    param (
        [string]$ServiceName
    )
    
    if (-not $Global:BackupSessionActive) { return }
    
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($service) {
        # Lấy StartupType từ WMI/CIM vì Get-Service không hỗ trợ trên PowerShell 5.1
        $startupType = "Manual"
        try {
            $serviceWmi = Get-CimInstance -ClassName Win32_Service -Filter "Name='$ServiceName'" -ErrorAction SilentlyContinue
            if ($serviceWmi) {
                $startupType = $serviceWmi.StartMode
            }
        } catch {}
        
        $record = [ordered]@{
            ServiceName = $ServiceName
            Exists      = $true
            Status      = $service.Status.ToString() # Running, Stopped
            StartupType = $startupType
        }
        
        $alreadyBackedUp = $Global:BackupServices | Where-Object { $_.ServiceName -eq $ServiceName }
        if (-not $alreadyBackedUp) {
            $Global:BackupServices += [PSCustomObject]$record
            Write-Log "Backup Service: $ServiceName ($startupType, $($service.Status))" "DEBUG"
        }
    } else {
        $record = [ordered]@{
            ServiceName = $ServiceName
            Exists      = $false
            Status      = "NonExistent"
            StartupType = "NonExistent"
        }
        $Global:BackupServices += [PSCustomObject]$record
    }
}

function Backup-PowerPlan {
    if (-not $Global:BackupSessionActive) { return }
    
    $activePlan = powercfg /getactivescheme
    if ($activePlan -match "GUID: ([a-f0-9\-]+)\s+\((.+)\)") {
        $Global:BackupPowerPlan = [ordered]@{
            GUID = $Matches[1]
            Name = $Matches[2]
        }
        Write-Log "Backup Power Plan: $($Matches[2])" "DEBUG"
    }
}

function Save-BackupSession {
    if (-not $Global:BackupSessionActive) { return }
    
    # Ghi ra các file JSON riêng biệt
    $regPath = Join-Path $Global:CurrentBackupDir "Registry.json"
    $srvPath = Join-Path $Global:CurrentBackupDir "Services.json"
    $pwrPath = Join-Path $Global:CurrentBackupDir "PowerPlan.json"
    $netPath = Join-Path $Global:CurrentBackupDir "Network.json"
    $winPath = Join-Path $Global:CurrentBackupDir "Windows.json"
    $infPath = Join-Path $Global:CurrentBackupDir "OptimizeInfo.json"
    
    $Global:BackupRegistry | ConvertTo-Json -Depth 5 | Out-File -FilePath $regPath -Force
    $Global:BackupServices | ConvertTo-Json -Depth 5 | Out-File -FilePath $srvPath -Force
    $Global:BackupPowerPlan | ConvertTo-Json -Depth 5 | Out-File -FilePath $pwrPath -Force
    
    # Ghi dữ liệu rỗng làm placeholder cho các tệp khác nếu không đổi
    $Global:BackupNetwork | ConvertTo-Json -Depth 5 | Out-File -FilePath $netPath -Force
    $Global:BackupWindows | ConvertTo-Json -Depth 5 | Out-File -FilePath $winPath -Force
    
    $info = [ordered]@{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Version = "1.0.0"
        Author = "VieX Studio"
    }
    $info | ConvertTo-Json -Depth 5 | Out-File -FilePath $infPath -Force
    
    $Global:BackupSessionActive = $false
    Write-Log "Đã lưu toàn bộ Snapshot Backup vào thư mục: $Global:CurrentBackupDir" "SUCCESS"
}

Export-ModuleMember -Function Start-BackupSession, Backup-RegistryValue, Backup-Service, Backup-PowerPlan, Save-BackupSession




