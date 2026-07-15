# core/Loader.ps1
# Bộ nạp module và tài nguyên hệ thống cho Valorant Optimize 1.0.0

$Global:ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$Global:DebugMode = $false

function Load-Configs {
    Write-Log "Đang nạp file cấu hình JSON..." "INFO"

    $compPath = Join-Path $Global:ProjectRoot "configs\Competitive.json"
    $balPath = Join-Path $Global:ProjectRoot "configs\Balanced.json"
    $extPath = Join-Path $Global:ProjectRoot "configs\Extreme.json"
    $langPath = Join-Path $Global:ProjectRoot "configs\lang\vi-VN.json"

    if (Test-Path $compPath) { $Global:ConfigCompetitive = Get-Content $compPath -Raw | ConvertFrom-Json }
    if (Test-Path $balPath) { $Global:ConfigBalanced = Get-Content $balPath -Raw | ConvertFrom-Json }
    if (Test-Path $extPath) { $Global:ConfigExtreme = Get-Content $extPath -Raw | ConvertFrom-Json }
    if (Test-Path $langPath) { $Global:Lang = Get-Content $langPath -Raw | ConvertFrom-Json }

    Write-Log "Đã nạp xong cấu hình & ngôn ngữ vi-VN" "SUCCESS"
}

function Load-Core {
    Write-Log "Đang nạp các thư viện lõi..." "INFO"
    
    # Nạp các file core bằng dot-sourcing
    . (Join-Path $PSScriptRoot "Logger.ps1")
    Initialize-Logger
    
    . (Join-Path $PSScriptRoot "System.ps1")
    . (Join-Path $PSScriptRoot "Backup.ps1")
    . (Join-Path $PSScriptRoot "Restore.ps1")
    . (Join-Path $PSScriptRoot "OptimizeEngine.ps1")

    # Nạp thư viện UI
    . (Join-Path $Global:ProjectRoot "ui\Color.ps1")
    . (Join-Path $Global:ProjectRoot "ui\Draw.ps1")
    . (Join-Path $Global:ProjectRoot "ui\Progress.ps1")
    . (Join-Path $Global:ProjectRoot "ui\Menu.ps1")
    
    Write-Log "Đã nạp toàn bộ thư viện cốt lõi & UI" "SUCCESS"
}

function Load-OptimizationModules {
    Write-Log "Đang quét và nạp các module tối ưu..." "INFO"
    $modulesDir = Join-Path $Global:ProjectRoot "modules"
    if (Test-Path $modulesDir) {
        $moduleFiles = Get-ChildItem -Path $modulesDir -Filter "*.ps1"
        $Global:Optimizers = @{}
        foreach ($file in $moduleFiles) {
            try {
                # Dot-source để nạp hàm của từng module vào global scope
                . $file.FullName
                $moduleName = $file.BaseName
                $Global:Optimizers[$moduleName] = $file.FullName
                Write-Log "Đã nạp Module: $moduleName" "INFO"
            } catch {
                Write-Log "Lỗi khi nạp module $($file.Name): $_" "ERROR"
            }
        }
        Write-Log "Đã nạp xong $($Global:Optimizers.Count) module tối ưu." "SUCCESS"
    } else {
        Write-Log "Không tìm thấy thư mục modules!" "WARNING"
    }
}

function Initialize-Project {
    Load-Core
    Load-Configs
    Load-OptimizationModules
}

# Export hàm
Export-ModuleMember -Function Initialize-Project, Load-Configs, Load-Core, Load-OptimizationModules


