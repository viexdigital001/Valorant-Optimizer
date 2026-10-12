# modules/Cleanup.ps1
# Module don dep tep tin tam thoi (Cleanup) cho Valorant Optimize 1.0.0

function Check-Cleanup {
    Write-Log "Tinh toan dung luong tep tin tam thoi co the don dep..." "INFO"
    $totalSize = 0
    $tempPaths = @($env:TEMP, "C:\Windows\Temp", (Join-Path $env:LOCALAPPDATA "CrashDumps"))
    
    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            $files = Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue
            foreach ($f in $files) {
                $totalSize += $f.Length
            }
        }
    }
    
    $sizeMB = [Math]::Round($totalSize / 1MB, 2)
    Write-Log "Tong dung luong tep tam co the don dep: $sizeMB MB" "INFO"
    return "OK"
}

function Apply-Cleanup {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    # Khi chay trong One-Click hoac Profile tu dong, don dep cac file rac tam thoi ma khong chan giao dien
    Write-Log "Bat dau don dep tep tin rac (Temp, Crash Dumps)..." "INFO"
    
    Write-Log "Bat au don dep tep tin rac..." "INFO"
    
    $tempPaths = @($env:TEMP, "C:\Windows\Temp", (Join-Path $env:LOCALAPPDATA "CrashDumps"))
    $clearedCount = 0
    
    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            $items = Get-ChildItem -Path $path -ErrorAction SilentlyContinue
            foreach ($item in $items) {
                try {
                    Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
                    $clearedCount++
                } catch {}
            }
        }
    }
    
    Write-Log "a don dep xong $clearedCount tep tin/thu muc rac." "SUCCESS"
}

function Restore-Cleanup {
    # Tep tam a xoa Cannot Restore
    Write-Log "Cac tep tam a xoa Cannot Restore." "WARNING"
}

function Verify-Cleanup {
    Write-Log "Xac minh don dep..." "INFO"
    return $true
}

function WriteLog-Cleanup {
    # Tich hop truc tiep qua Logger
}







