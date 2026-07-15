# modules/PowerPlan.ps1
# Module Configuring nguon ien (Power Plan) cho Valorant Optimize 1.0.0

function Check-PowerPlan {
    Write-Log "Kiem tra so o nguon ien..." "INFO"
    $activeScheme = powercfg /getactivescheme
    Write-Log "Active Power Scheme: $activeScheme" "INFO"
    return "OK"
}

function Apply-PowerPlan {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bat au Configuring so o nguon toi uu..." "INFO"
    
    # 1. Sao luu so o nguon hien tai
    Backup-PowerPlan
    
    # inh nghia cac GUID chuan cua Windows
    $ultimateGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61" # Ultimate Performance
    $highPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" # High Performance
    
    $targetGuid = $null
    
    # Thu tao / nap Ultimate Performance
    $output = powercfg /duplicatescheme $ultimateGuid 2>&1
    if ($output -match "GUID: ([a-f0-9\-]+)") {
        $targetGuid = $Matches[1]
        Write-Log "a nhan ban so o nguon Ultimate Performance." "INFO"
    } else {
        # Neu Ultimate khong ho tro, nhan ban High Performance
        $output = powercfg /duplicatescheme $highPerfGuid 2>&1
        if ($output -match "GUID: ([a-f0-9\-]+)") {
            $targetGuid = $Matches[1]
            Write-Log "System khong ho tro Ultimate, a nhan ban High Performance." "WARNING"
        }
    }
    
    if (-not $targetGuid) {
        # Neu khong nhan ban uoc gi ca, su dung so o High Performance goc
        $targetGuid = $highPerfGuid
        powercfg /changename $targetGuid "VieX Ultimate Performance" 2>&1 | Out-Null
    } else {
        powercfg /changename $targetGuid "VieX Ultimate Performance" 2>&1 | Out-Null
    }
    
    # 2. Configuring chi tiet cho So o nguon moi
    # SUB_PROCESSOR (54533251-82be-4824-96c1-47b60b740d00)
    $subProcessor = "54533251-82be-4824-96c1-47b60b740d00"
    
    # Toi thieu hoa trang thai CPU khi cam sac (100%)
    powercfg /setacvalueindex $targetGuid $subProcessor PROCTHROTTLEMIN 100 2>&1 | Out-Null
    # Toi a hoa trang thai CPU khi cam sac (100%)
    powercfg /setacvalueindex $targetGuid $subProcessor PROCTHROTTLEMAX 100 2>&1 | Out-Null
    
    # Tat Core Parking khi cam sac (at so nhan toi thieu o 100%)
    # GUID: dec35c3c-058a-47ef-a97f-5370d7d68a41
    $cpMinCores = "dec35c3c-058a-47ef-a97f-5370d7d68a41"
    powercfg /setacvalueindex $targetGuid $subProcessor $cpMinCores 100 2>&1 | Out-Null
    
    # Thiet lap Processor Energy Performance Preference (EPP) thanh 0 (Maximum Performance)
    # GUID: 3668a663-de38-4a55-8b38-a54c992d698e
    $eppGuid = "3668a663-de38-4a55-8b38-a54c992d698e"
    powercfg /setacvalueindex $targetGuid $subProcessor $eppGuid 0 2>&1 | Out-Null
    
    # Tat o ia tu tat khi ranh (Turn off hard disk after = 0 phut)
    # SUB_DISK (0012ee47-9041-4b5d-9b77-535fba8b1442) -> DISKIDLE (6733a27e-28b9-4e49-87c7-bdc4463409d7)
    powercfg /setacvalueindex $targetGuid 0012ee47-9041-4b5d-9b77-535fba8b1442 6733a27e-28b9-4e49-87c7-bdc4463409d7 0 2>&1 | Out-Null
    
    # Kich hoat so o nguon moi lam mac inh
    powercfg /setactive $targetGuid 2>&1 | Out-Null
    
    Write-Log "a at VieX Ultimate Performance ($targetGuid) lam Power Plan hien tai." "SUCCESS"
}

function Restore-PowerPlan {
    Write-Log "Currently Restore Power Plan..." "INFO"
}

function Verify-PowerPlan {
    Write-Log "Xac minh Power Plan..." "INFO"
    $active = powercfg /getactivescheme
    if ($active -match "VieX Ultimate Performance") {
        Write-Log "Xac minh Power Plan Success!" "SUCCESS"
        return $true
    }
    return $false
}

function WriteLog-PowerPlan {
    # Tich hop truc tiep qua Logger
}





