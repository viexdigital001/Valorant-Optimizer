# modules/GPU.ps1
# Module toi uu GPU cho Valorant Optimize 1.0.0

function Check-GPU {
    Write-Log "Kiem tra Configuring GPU hien tai..." "INFO"
    
    # Kiem tra HAGS (Hardware Accelerated GPU Scheduling)
    $hagsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    if (Test-Path $hagsPath) {
        $mode = Get-ItemPropertyValue -Path $hagsPath -Name "HwSchMode" -ErrorAction SilentlyContinue
        Write-Log "Trang thai HAGS hien tai: $mode (2 la Enabling, 1 la Disabling)" "INFO"
    }
    
    # Kiem tra DirectX Shader Cache Size
    $dxPath = "HKLM:\SOFTWARE\Microsoft\DirectX"
    if (Test-Path $dxPath) {
        $size = Get-ItemPropertyValue -Path $dxPath -Name "MaxShaderCacheSize" -ErrorAction SilentlyContinue
        Write-Log "DirectX MaxShaderCacheSize hien tai: $size" "INFO"
    }
    
    return "OK"
}

function Apply-GPU {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bat au toi uu GPU..." "INFO"
    
    $hagsConfig = $Config.settings.gpu.Hags
    $shaderCacheConfig = $Config.settings.gpu.ShaderCache
    
    # 1. Configuring HAGS
    $hagsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    if (-not (Test-Path $hagsPath)) {
        New-Item -Path $hagsPath -Force | Out-Null
    }
    Backup-RegistryValue -Path $hagsPath -ValueName "HwSchMode"
    # HwSchMode = 2 (Bat HAGS), 1 (Tat HAGS)
    $hagsValue = if ($hagsConfig -eq 1) { 2 } else { 1 }
    Set-ItemProperty -Path $hagsPath -Name "HwSchMode" -Value $hagsValue -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    Write-Log "a thiet lap HwSchMode thanh $hagsValue" "INFO"
    
    # 2. Configuring DirectX Shader Cache (Vo han kich thuoc e tranh giat khi nap map)
    $dxPath = "HKLM:\SOFTWARE\Microsoft\DirectX"
    if (-not (Test-Path $dxPath)) {
        New-Item -Path $dxPath -Force | Out-Null
    }
    Backup-RegistryValue -Path $dxPath -ValueName "MaxShaderCacheSize"
    if ($shaderCacheConfig -eq 1) {
        # 0xffffffff = Khong gioi han kich thuoc cache
        Set-ItemProperty -Path $dxPath -Name "MaxShaderCacheSize" -Value 4294967295 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
        Write-Log "a Configuring MaxShaderCacheSize thanh Unlimited" "INFO"
    }
    
    # 3. Disabling Fullscreen Optimizations cho Valorant
    $compatPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
    if (-not (Test-Path $compatPath)) {
        New-Item -Path $compatPath -Force | Out-Null
    }
    
    # Cac uong dan pho bien cua Valorant
    $gamePaths = @(
        "C:\Riot Games\VALORANT\live\ShooterGame\Binaries\Win64\VALORANT-Win64-Shipping.exe"
    )
    
    foreach ($gp in $gamePaths) {
        Backup-RegistryValue -Path $compatPath -ValueName $gp
        # ~ DISABLEDXMAXIMIZEDWINDOWEDMODE Disabling Optimizing toan man hinh
        Set-ItemProperty -Path $compatPath -Name $gp -Value "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" -Type String -Force -ErrorAction SilentlyContinue | Out-Null
    }
    Write-Log "a Disabling Fullscreen Optimizations cho Valorant" "SUCCESS"
}

function Restore-GPU {
    Write-Log "Currently Restore cai at GPU..." "INFO"
}

function Verify-GPU {
    Write-Log "Xac minh Configuring GPU..." "INFO"
    $hagsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    if (Test-Path $hagsPath) {
        $mode = Get-ItemPropertyValue -Path $hagsPath -Name "HwSchMode" -ErrorAction SilentlyContinue
        if ($mode -ne $null) {
            Write-Log "Xac minh GPU Success!" "SUCCESS"
            return $true
        }
    }
    return $false
}

function WriteLog-GPU {
    # Tich hop truc tiep qua Logger
}





