# modules/PowerPlan.ps1
# Module cấu hình nguồn điện (Power Plan) cho Valorant Optimize 1.0.0

function Check-PowerPlan {
    Write-Log "Kiểm tra sơ đồ nguồn điện..." "INFO"
    $activeScheme = powercfg /getactivescheme
    Write-Log "Active Power Scheme: $activeScheme" "INFO"
    return "OK"
}

function Apply-PowerPlan {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bắt đầu cấu hình sơ đồ nguồn tối ưu..." "INFO"
    
    # 1. Sao lưu sơ đồ nguồn hiện tại
    Backup-PowerPlan
    
    # Định nghĩa các GUID chuẩn của Windows
    $ultimateGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61" # Ultimate Performance
    $highPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" # High Performance
    
    $targetGuid = $null
    
    # Thử tạo / nạp Ultimate Performance
    $output = powercfg /duplicatescheme $ultimateGuid 2>&1
    if ($output -match "GUID: ([a-f0-9\-]+)") {
        $targetGuid = $Matches[1]
        Write-Log "Đã nhân bản sơ đồ nguồn Ultimate Performance." "INFO"
    } else {
        # Nếu Ultimate không hỗ trợ, nhân bản High Performance
        $output = powercfg /duplicatescheme $highPerfGuid 2>&1
        if ($output -match "GUID: ([a-f0-9\-]+)") {
            $targetGuid = $Matches[1]
            Write-Log "Hệ thống không hỗ trợ Ultimate, đã nhân bản High Performance." "WARNING"
        }
    }
    
    if (-not $targetGuid) {
        # Nếu không nhân bản được gì cả, sử dụng sơ đồ High Performance gốc
        $targetGuid = $highPerfGuid
        powercfg /changename $targetGuid "VieX Ultimate Performance" 2>&1 | Out-Null
    } else {
        powercfg /changename $targetGuid "VieX Ultimate Performance" 2>&1 | Out-Null
    }
    
    # 2. Cấu hình chi tiết cho Sơ đồ nguồn mới
    # SUB_PROCESSOR (54533251-82be-4824-96c1-47b60b740d00)
    $subProcessor = "54533251-82be-4824-96c1-47b60b740d00"
    
    # Tối thiểu hóa trạng thái CPU khi cắm sạc (100%)
    powercfg /setacvalueindex $targetGuid $subProcessor PROCTHROTTLEMIN 100 2>&1 | Out-Null
    # Tối đa hóa trạng thái CPU khi cắm sạc (100%)
    powercfg /setacvalueindex $targetGuid $subProcessor PROCTHROTTLEMAX 100 2>&1 | Out-Null
    
    # Tắt Core Parking khi cắm sạc (Đặt số nhân tối thiểu ở 100%)
    # GUID: dec35c3c-058a-47ef-a97f-5370d7d68a41
    $cpMinCores = "dec35c3c-058a-47ef-a97f-5370d7d68a41"
    powercfg /setacvalueindex $targetGuid $subProcessor $cpMinCores 100 2>&1 | Out-Null
    
    # Thiết lập Processor Energy Performance Preference (EPP) thành 0 (Maximum Performance)
    # GUID: 3668a663-de38-4a55-8b38-a54c992d698e
    $eppGuid = "3668a663-de38-4a55-8b38-a54c992d698e"
    powercfg /setacvalueindex $targetGuid $subProcessor $eppGuid 0 2>&1 | Out-Null
    
    # Tắt ổ đĩa tự tắt khi rảnh (Turn off hard disk after = 0 phút)
    # SUB_DISK (0012ee47-9041-4b5d-9b77-535fba8b1442) -> DISKIDLE (6733a27e-28b9-4e49-87c7-bdc4463409d7)
    powercfg /setacvalueindex $targetGuid 0012ee47-9041-4b5d-9b77-535fba8b1442 6733a27e-28b9-4e49-87c7-bdc4463409d7 0 2>&1 | Out-Null
    
    # Kích hoạt sơ đồ nguồn mới làm mặc định
    powercfg /setactive $targetGuid 2>&1 | Out-Null
    
    Write-Log "Đã đặt VieX Ultimate Performance ($targetGuid) làm Power Plan hiện tại." "SUCCESS"
}

function Restore-PowerPlan {
    Write-Log "Đang khôi phục Power Plan..." "INFO"
}

function Verify-PowerPlan {
    Write-Log "Xác minh Power Plan..." "INFO"
    $active = powercfg /getactivescheme
    if ($active -match "VieX Ultimate Performance") {
        Write-Log "Xác minh Power Plan thành công!" "SUCCESS"
        return $true
    }
    return $false
}

function WriteLog-PowerPlan {
    # Tích hợp trực tiếp qua Logger
}





