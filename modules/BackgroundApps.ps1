# modules/BackgroundApps.ps1
# Module Disabling ung dung UWP chay ngam (Background Apps) cho Valorant Optimize 1.0.0

function Check-BackgroundApps {
    Write-Log "Kiem tra Configuring ung dung chay ngam..." "INFO"
    $appPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    if (Test-Path $appPath) {
        $val = Get-ItemPropertyValue -Path $appPath -Name "GlobalUserDisabled" -ErrorAction SilentlyContinue
        Write-Log "GlobalUserDisabled (Ung dung ngam): $val (1 la a Disabling)" "INFO"
    }
    return "OK"
}

function Apply-BackgroundApps {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bat au Disabling ung dung UWP chay ngam..." "INFO"
    
    $appPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    if (-not (Test-Path $appPath)) {
        New-Item -Path $appPath -Force | Out-Null
    }
    
    Backup-RegistryValue -Path $appPath -ValueName "GlobalUserDisabled"
    
    # GlobalUserDisabled = 1 (Tat hoan toan cac app Windows Store chay ngam vo bo)
    Set-ItemProperty -Path $appPath -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    
    # Tat chan oan ung dung chay ngam cua Windows Search
    $searchPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    if (Test-Path $searchPath) {
        Backup-RegistryValue -Path $searchPath -ValueName "BackgroundAppDiagnostic"
        Set-ItemProperty -Path $searchPath -Name "BackgroundAppDiagnostic" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    Write-Log "a Disabling cac ung dung chay ngam Success." "SUCCESS"
}

function Restore-BackgroundApps {
    Write-Log "Currently Restore ung dung chay ngam..." "INFO"
}

function Verify-BackgroundApps {
    Write-Log "Xac minh Configuring ung dung chay ngam..." "INFO"
    $appPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    if (Test-Path $appPath) {
        $val = Get-ItemPropertyValue -Path $appPath -Name "GlobalUserDisabled" -ErrorAction SilentlyContinue
        if ($val -eq 1) {
            Write-Log "Xac minh ung dung ngam Success!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-BackgroundApps {
    # Tich hop truc tiep qua Logger
}





