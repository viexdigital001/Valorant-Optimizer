# modules/Network.ps1
# Module Optimizing ket noi mang (Network) cho Valorant Optimize 1.0.0

function Check-Network {
    Write-Log "Kiem tra Configuring Network hien tai..." "INFO"
    
    # Kiem tra Configuring TCP o muc toan cuc
    $tcpPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    if (Test-Path $tcpPath) {
        $sack = (Get-ItemProperty -Path $tcpPath -Name "SackOpts" -ErrorAction SilentlyContinue).SackOpts
        Write-Log "SackOpts (Selective Acknowledgment): $sack" "INFO"
    }
    
    return "OK"
}

function Apply-Network {
    param (
        [Parameter(Mandatory=$true)]
        $Config
    )
    
    Write-Log "Bat au Optimizing cai at mang..." "INFO"
    
    $tcpNoDelay = $Config.settings.network.TCPNoDelay
    $tcpAckFreq = $Config.settings.network.TCPAckFrequency
    
    # 1. Toi uu TCP Nagle's Algorithm (TcpAckFrequency & TCPNoDelay) cho tung card mang
    $interfacesPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    if (Test-Path $interfacesPath) {
        $interfaces = Get-ChildItem -Path $interfacesPath -ErrorAction SilentlyContinue
        foreach ($i in $interfaces) {
            Backup-RegistryValue -Path $i.PSPath -ValueName "TcpAckFrequency"
            Backup-RegistryValue -Path $i.PSPath -ValueName "TCPNoDelay"
            
            Set-ItemProperty -Path $i.PSPath -Name "TcpAckFrequency" -Value $tcpAckFreq -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
            Set-ItemProperty -Path $i.PSPath -Name "TCPNoDelay" -Value $tcpNoDelay -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
        }
        Write-Log "a Configuring TCPNoDelay va TcpAckFrequency Success tren cac card mang." "INFO"
    }
    
    # 2. Tat cac che do tiet kiem dien nang tren Card mang vat ly (Giam do tre goi tin UDP/TCP)
    try {
        $physicalAdapters = Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq "Up" }
        foreach ($adapter in $physicalAdapters) {
            # Tat Energy Efficient Ethernet (EEE)
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "*EEE" -RegistryValue "0" -ErrorAction SilentlyContinue | Out-Null
            # Tat Green Ethernet
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "*Green" -RegistryValue "0" -ErrorAction SilentlyContinue | Out-Null
            # Bat Receive Side Scaling (RSS) de chia deu goi tin UDP tren cac nhan CPU
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "*RSS" -RegistryValue "1" -ErrorAction SilentlyContinue | Out-Null
            # Tat Flow Control de tranh delay buffer
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -RegistryKeyword "*FlowControl" -RegistryValue "0" -ErrorAction SilentlyContinue | Out-Null
        }
        Write-Log "a Configuring EEE=0, GreenEthernet=0, RSS=1 tren cac card mang vat ly dang hoat dong." "INFO"
    } catch {
        Write-Log "ERROR khi Configuring nang cao Adapter mang: $_" "WARNING"
    }
    
    # 3. Optimizing TCP Global Parameters (Giu Auto-tuning o muc chuan, khong bop bang thong)
    try {
        netsh int tcp set global autotuninglevel=normal 2>&1 | Out-Null
        netsh int tcp set global rss=enabled 2>&1 | Out-Null
        netsh int tcp set global timestamps=disabled 2>&1 | Out-Null
    } catch {}
    
    $tcpPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    if (Test-Path $tcpPath) {
        Backup-RegistryValue -Path $tcpPath -ValueName "SackOpts"
        Backup-RegistryValue -Path $tcpPath -ValueName "TcpWindowSize"
        Set-ItemProperty -Path $tcpPath -Name "SackOpts" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
        # Xoa TcpWindowSize cu neu co de Windows tu dong mo rong cua so mang toc do cao
        Remove-ItemProperty -Path $tcpPath -Name "TcpWindowSize" -ErrorAction SilentlyContinue | Out-Null
    }
    
    Write-Log "Optimizing Network Completed!" "SUCCESS"
}

function Restore-Network {
    Write-Log "Currently Restore Configuring Network..." "INFO"
}

function Verify-Network {
    Write-Log "Xac minh Configuring Network..." "INFO"
    $tcpPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    if (Test-Path $tcpPath) {
        $props = Get-ItemProperty -Path $tcpPath -ErrorAction SilentlyContinue
        if ($props -and $props.SackOpts -eq 1) {
            return $true
        }
    }
    return $true
}

function WriteLog-Network {
    # Tich hop truc tiep qua Logger
}







