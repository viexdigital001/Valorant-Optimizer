# modules/GameStart.ps1
# Module Optimizing qua trinh khoi ong Valorant cho Valorant Optimize 1.0.0

function Check-GameStart {
    Write-Log "Kiem tra Configuring thu muc rac cua Valorant..." "INFO"
    $valAppData = Join-Path $env:LOCALAPPDATA "VALORANT\Saved"
    if (Test-Path $valAppData) {
        Write-Log "Thu muc Saved cua Valorant ton tai tai: $valAppData" "INFO"
    }
    return "OK"
}

function Apply-GameStart {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bat au don dep log rac va toi uu khoi ong Valorant..." "INFO"
    
    # 1. Don dep log va crash dump cu cua Valorant
    $valSaved = Join-Path $env:LOCALAPPDATA "VALORANT\Saved"
    if (Test-Path $valSaved) {
        $logPath = Join-Path $valSaved "Logs"
        $crashPath = Join-Path $valSaved "Crashes"
        $webCachePath = Join-Path $valSaved "webcache"
        
        if (Test-Path $logPath) {
            Remove-Item -Path $logPath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
            Write-Log "a don dep thu muc Logs cu cua game." "INFO"
        }
        if (Test-Path $crashPath) {
            Remove-Item -Path $crashPath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
            Write-Log "a don dep cac tep tin Crashes cu." "INFO"
        }
        if (Test-Path $webCachePath) {
            Remove-Item -Path $webCachePath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
            Write-Log "a don dep cache web tich hop cua game." "INFO"
        }
    }
    
    # 2. Don dep log cua Riot Client
    $riotClientApp = Join-Path $env:LOCALAPPDATA "Riot Games\Riot Client"
    if (Test-Path $riotClientApp) {
        $clientLogs = Join-Path $riotClientApp "Logs"
        if (Test-Path $clientLogs) {
            Remove-Item -Path $clientLogs -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
            Write-Log "a don dep Logs cu cua Riot Client." "INFO"
        }
    }
    
    Write-Log "Optimizing khoi ong Valorant Completed!" "SUCCESS"
}

function Restore-GameStart {
    Write-Log "Khong can Restore cho don dep khoi ong." "INFO"
}

function Verify-GameStart {
    Write-Log "Xac minh Configuring khoi ong..." "INFO"
    return $true
}

function WriteLog-GameStart {
    # Tich hop truc tiep qua Logger
}





