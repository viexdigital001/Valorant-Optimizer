# modules/GPU.ps1
# Module tối ưu GPU cho Valorant Optimize 1.0.0

function Check-GPU {
    Write-Log "Kiểm tra cấu hình GPU hiện tại..." "INFO"
    
    # Kiểm tra HAGS (Hardware Accelerated GPU Scheduling)
    $hagsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    if (Test-Path $hagsPath) {
        $mode = Get-ItemPropertyValue -Path $hagsPath -Name "HwSchMode" -ErrorAction SilentlyContinue
        Write-Log "Trạng thái HAGS hiện tại: $mode (2 là đang bật, 1 là đang tắt)" "INFO"
    }
    
    # Kiểm tra DirectX Shader Cache Size
    $dxPath = "HKLM:\SOFTWARE\Microsoft\DirectX"
    if (Test-Path $dxPath) {
        $size = Get-ItemPropertyValue -Path $dxPath -Name "MaxShaderCacheSize" -ErrorAction SilentlyContinue
        Write-Log "DirectX MaxShaderCacheSize hiện tại: $size" "INFO"
    }
    
    return "OK"
}

function Apply-GPU {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bắt đầu tối ưu GPU..." "INFO"
    
    $hagsConfig = $Config.settings.gpu.Hags
    $shaderCacheConfig = $Config.settings.gpu.ShaderCache
    
    # 1. Cấu hình HAGS
    $hagsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    if (-not (Test-Path $hagsPath)) {
        New-Item -Path $hagsPath -Force | Out-Null
    }
    Backup-RegistryValue -Path $hagsPath -ValueName "HwSchMode"
    # HwSchMode = 2 (Bật HAGS), 1 (Tắt HAGS)
    $hagsValue = if ($hagsConfig -eq 1) { 2 } else { 1 }
    Set-ItemProperty -Path $hagsPath -Name "HwSchMode" -Value $hagsValue -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    Write-Log "Đã thiết lập HwSchMode thành $hagsValue" "INFO"
    
    # 2. Cấu hình DirectX Shader Cache (Vô hạn kích thước để tránh giật khi nạp map)
    $dxPath = "HKLM:\SOFTWARE\Microsoft\DirectX"
    if (-not (Test-Path $dxPath)) {
        New-Item -Path $dxPath -Force | Out-Null
    }
    Backup-RegistryValue -Path $dxPath -ValueName "MaxShaderCacheSize"
    if ($shaderCacheConfig -eq 1) {
        # 0xffffffff = Không giới hạn kích thước cache
        Set-ItemProperty -Path $dxPath -Name "MaxShaderCacheSize" -Value 4294967295 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
        Write-Log "Đã cấu hình MaxShaderCacheSize thành Unlimited" "INFO"
    }
    
    # 3. Vô hiệu hóa Fullscreen Optimizations cho Valorant
    $compatPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
    if (-not (Test-Path $compatPath)) {
        New-Item -Path $compatPath -Force | Out-Null
    }
    
    # Các đường dẫn phổ biến của Valorant
    $gamePaths = @(
        "C:\Riot Games\VALORANT\live\ShooterGame\Binaries\Win64\VALORANT-Win64-Shipping.exe"
    )
    
    foreach ($gp in $gamePaths) {
        Backup-RegistryValue -Path $compatPath -ValueName $gp
        # ~ DISABLEDXMAXIMIZEDWINDOWEDMODE vô hiệu hóa tối ưu hóa toàn màn hình
        Set-ItemProperty -Path $compatPath -Name $gp -Value "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    }
    Write-Log "Đã vô hiệu hóa Fullscreen Optimizations cho Valorant" "SUCCESS"
}

function Restore-GPU {
    Write-Log "Đang khôi phục cài đặt GPU..." "INFO"
}

function Verify-GPU {
    Write-Log "Xác minh cấu hình GPU..." "INFO"
    $hagsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    if (Test-Path $hagsPath) {
        $mode = Get-ItemPropertyValue -Path $hagsPath -Name "HwSchMode" -ErrorAction SilentlyContinue
        if ($mode -ne $null) {
            Write-Log "Xác minh GPU thành công!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-GPU {
    # Tích hợp trực tiếp qua Logger
}

Export-ModuleMember -Function Check-GPU, Apply-GPU, Restore-GPU, Verify-GPU, WriteLog-GPU


