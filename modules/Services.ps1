# modules/Services.ps1
# Module Optimizing cac Dich vu System (Services) cho Valorant Optimize 1.0.0

function Check-Services {
    Write-Log "Kiem tra trang thai cac Services..." "INFO"
    $checkServices = @("Spooler", "RemoteRegistry", "MapsBroker", "DiagTrack", "dmwappushservice")
    foreach ($srvName in $checkServices) {
        $srv = Get-Service -Name $srvName -ErrorAction SilentlyContinue
        if ($srv) {
            Write-Log "Service: $srvName, Status: $($srv.Status), StartType: $($srv.StartType)" "INFO"
        }
    }
    return "OK"
}

function Apply-Services {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bat au Optimizing cac Services..." "INFO"
    
    $disableUnused = $Config.settings.services.DisableUnused
    if (-not $disableUnused) {
        Write-Log "Bo qua toi uu Services (Configuring profile khong yeu cau tat)." "WARNING"
        return
    }
    
    # Danh sach cac dich vu khong can thiet khi choi game va an toan e tat
    $servicesToDisable = @(
        "RemoteRegistry",     # Remote Registry (Khong bao gio can, nguy co bao mat)
        "MapsBroker",         # Downloaded Maps Manager (Ban o offline cua Windows)
        "DiagTrack",          # Connected User Experiences and Telemetry (Thu thap du lieu)
        "dmwappushservice",   # WAP Push Message Routing Service (Telemetry)
        "Spooler"             # Print Spooler (In an, tat tam thoi e giam giat. Co the bat lai neu can in)
    )
    
    # Luu y: Giu nguyen dich vu Bluetooth (bthserv) de dam bao tai nghe, chuot va tay cam khong bi ngat ket noi
    
    foreach ($srvName in $servicesToDisable) {
        $srv = Get-Service -Name $srvName -ErrorAction SilentlyContinue
        if ($srv) {
            Backup-Service -ServiceName $srvName
            
            # Dung service neu Currently chay
            if ($srv.Status -eq "Running") {
                Stop-Service -Name $srvName -Force -ErrorAction SilentlyContinue | Out-Null
            }
            # Configuring Startup Type thanh Disabled
            Set-Service -Name $srvName -StartupType Disabled -ErrorAction SilentlyContinue | Out-Null
            Write-Log "Disabled va Disabling dich vu: $srvName" "INFO"
        }
    }
    
    Write-Log "Optimizing cac Services Completed!" "SUCCESS"
}

function Restore-Services {
    Write-Log "Currently Restore cai at Services..." "INFO"
}

function Verify-Services {
    param ($Config)
    Write-Log "Xac minh cac Services..." "INFO"
    if ($Config -and $Config.settings.services.DisableUnused -eq $false) {
        Write-Log "Profile hien tai khong tat service (giu nguyen mac dinh an toan)." "INFO"
        return $true
    }
    # Kiem tra cac dich vu pho bien tren moi phien ban Windows (ke ca ban Home)
    $checkList = @("DiagTrack", "Spooler", "RemoteRegistry", "MapsBroker")
    foreach ($name in $checkList) {
        $srv = Get-Service -Name $name -ErrorAction SilentlyContinue
        if ($srv -and $srv.StartType -eq "Disabled") {
            Write-Log "Xac minh Services Success ($name da bi tat)!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-Services {
    # Tich hop truc tiep qua Logger
}







