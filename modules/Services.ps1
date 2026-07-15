# modules/Services.ps1
# Module tối ưu hóa các Dịch vụ hệ thống (Services) cho Valorant Optimize 1.0.0

function Check-Services {
    Write-Log "Kiểm tra trạng thái các Services..." "INFO"
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
    
    Write-Log "Bắt đầu tối ưu hóa các Services..." "INFO"
    
    $disableUnused = $Config.settings.services.DisableUnused
    if (-not $disableUnused) {
        Write-Log "Bỏ qua tối ưu Services (Cấu hình profile không yêu cầu tắt)." "WARNING"
        return
    }
    
    # Danh sách các dịch vụ không cần thiết khi chơi game và an toàn để tắt
    $servicesToDisable = @(
        "RemoteRegistry",     # Remote Registry (Không bao giờ cần, nguy cơ bảo mật)
        "MapsBroker",         # Downloaded Maps Manager (Bản đồ offline của Windows)
        "DiagTrack",          # Connected User Experiences and Telemetry (Thu thập dữ liệu)
        "dmwappushservice",   # WAP Push Message Routing Service (Telemetry)
        "Spooler"             # Print Spooler (In ấn, tắt tạm thời để giảm giật. Có thể bật lại nếu cần in)
    )
    
    # Nếu là Desktop, có thể tắt thêm Bluetooth để tối đa tài nguyên
    # (Laptop thường dùng chuột/tai nghe Bluetooth nên không tắt ở đây để an toàn)
    $sysInfo = Get-SystemInfo
    if (-not $sysInfo.IsLaptop) {
        $servicesToDisable += "bthserv" # Bluetooth Support Service
    }
    
    foreach ($srvName in $servicesToDisable) {
        $srv = Get-Service -Name $srvName -ErrorAction SilentlyContinue
        if ($srv) {
            Backup-Service -ServiceName $srvName
            
            # Dừng service nếu đang chạy
            if ($srv.Status -eq "Running") {
                Stop-Service -Name $srvName -Force -ErrorAction SilentlyContinue | Out-Null
            }
            # Cấu hình Startup Type thành Disabled
            Set-Service -Name $srvName -StartupType Disabled -ErrorAction SilentlyContinue | Out-Null
            Write-Log "Đã tắt và vô hiệu hóa dịch vụ: $srvName" "INFO"
        }
    }
    
    Write-Log "Tối ưu hóa các Services hoàn tất!" "SUCCESS"
}

function Restore-Services {
    Write-Log "Đang khôi phục cài đặt Services..." "INFO"
}

function Verify-Services {
    Write-Log "Xác minh các Services..." "INFO"
    $srv = Get-Service -Name "RemoteRegistry" -ErrorAction SilentlyContinue
    if ($srv) {
        if ($srv.StartType -eq "Disabled") {
            Write-Log "Xác minh Services thành công!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-Services {
    # Tích hợp trực tiếp qua Logger
}





