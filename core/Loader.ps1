# core/Loader.ps1
# Bo nap module va tai nguyen System cho Valorant Optimize 1.0.0

$Global:ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$Global:DebugMode = $false

# 1. Nap Logger truoc e dung
. (Join-Path $PSScriptRoot "Logger.ps1")
Initialize-Logger

Write-Log "Currently nap file Configuring JSON..." "INFO"
$compPath = Join-Path $Global:ProjectRoot "configs\Competitive.json"
$balPath = Join-Path $Global:ProjectRoot "configs\Balanced.json"
$extPath = Join-Path $Global:ProjectRoot "configs\Extreme.json"
$langPath = Join-Path $Global:ProjectRoot "configs\lang\vi-VN.json"

if (Test-Path $compPath) { $Global:ConfigCompetitive = Get-Content $compPath -Raw | ConvertFrom-Json }
if (Test-Path $balPath) { $Global:ConfigBalanced = Get-Content $balPath -Raw | ConvertFrom-Json }
if (Test-Path $extPath) { $Global:ConfigExtreme = Get-Content $extPath -Raw | ConvertFrom-Json }
if (Test-Path $langPath) { $Global:Lang = Get-Content $langPath -Raw | ConvertFrom-Json }
Write-Log "a nap xong Configuring & ngon ngu vi-VN" "SUCCESS"

Write-Log "Currently nap cac thu vien loi..." "INFO"
# Nap cac file core bang dot-sourcing
. (Join-Path $PSScriptRoot "System.ps1")
. (Join-Path $PSScriptRoot "Backup.ps1")
. (Join-Path $PSScriptRoot "Restore.ps1")
. (Join-Path $PSScriptRoot "OptimizeEngine.ps1")

# Nap thu vien UI
. (Join-Path $Global:ProjectRoot "ui\Color.ps1")
. (Join-Path $Global:ProjectRoot "ui\Draw.ps1")
. (Join-Path $Global:ProjectRoot "ui\Progress.ps1")
. (Join-Path $Global:ProjectRoot "ui\Menu.ps1")
Write-Log "a nap toan bo thu vien cot loi & UI" "SUCCESS"

Write-Log "Currently quet va nap cac module toi uu..." "INFO"
$modulesDir = Join-Path $Global:ProjectRoot "modules"
if (Test-Path $modulesDir) {
    $moduleFiles = Get-ChildItem -Path $modulesDir -Filter "*.ps1"
    $Global:Optimizers = @{}
    foreach ($file in $moduleFiles) {
        try {
            # Dot-source e nap ham cua tung module vao global scope
            . $file.FullName
            $moduleName = $file.BaseName
            $Global:Optimizers[$moduleName] = $file.FullName
            Write-Log "a nap Module: $moduleName" "INFO"
        } catch {
            Write-Log "ERROR khi nap module $($file.Name): $_" "ERROR"
        }
    }
    Write-Log "a nap xong $($Global:Optimizers.Count) module toi uu." "SUCCESS"
} else {
    Write-Log "Khong tim thay thu muc modules!" "WARNING"
}

function Initialize-Project {
    Write-Log "Khoi tao du an Completed!" "SUCCESS"
}
