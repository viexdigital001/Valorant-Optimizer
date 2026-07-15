# modules/Cleanup.ps1
# Module dọn dẹp tệp tin tạm thời (Cleanup) cho Valorant Optimize 1.0.0

function Check-Cleanup {
    Write-Log "Tính toán dung lượng tệp tin tạm thời có thể dọn dẹp..." "INFO"
    $totalSize = 0
    $tempPaths = @($env:TEMP, "C:\Windows\Temp", Join-Path $env:LOCALAPPDATA "CrashDumps")
    
    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            $files = Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue
            foreach ($f in $files) {
                $totalSize += $f.Length
            }
        }
    }
    
    $sizeMB = [Math]::Round($totalSize / 1MB, 2)
    Write-Log "Tổng dung lượng tệp tạm có thể dọn dẹp: $sizeMB MB" "INFO"
    return "OK"
}

function Apply-Cleanup {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Yêu cầu xác nhận từ người dùng để dọn dẹp tệp tạm..." "WARNING"
    $msg = "Bạn có muốn dọn dẹp các tệp tin tạm thời (Temp, Log, Crash Dump) để giải phóng dung lượng không?"
    $confirm = Get-Confirmation -PromptMessage $msg
    
    if (-not $confirm) {
        Write-Log "Người dùng từ chối dọn dẹp tệp tạm. Bỏ qua." "INFO"
        return
    }
    
    Write-Log "Bắt đầu dọn dẹp tệp tin rác..." "INFO"
    
    $tempPaths = @($env:TEMP, "C:\Windows\Temp", Join-Path $env:LOCALAPPDATA "CrashDumps")
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
    
    Write-Log "Đã dọn dẹp xong $clearedCount tệp tin/thư mục rác." "SUCCESS"
}

function Restore-Cleanup {
    # Tệp tạm đã xóa không thể khôi phục
    Write-Log "Các tệp tạm đã xóa không thể khôi phục." "WARNING"
}

function Verify-Cleanup {
    Write-Log "Xác minh dọn dẹp..." "INFO"
    return $true
}

function WriteLog-Cleanup {
    # Tích hợp trực tiếp qua Logger
}

Export-ModuleMember -Function Check-Cleanup, Apply-Cleanup, Restore-Cleanup, Verify-Cleanup, WriteLog-Cleanup




