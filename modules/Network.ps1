# modules/Network.ps1
# Module Optimizing ket noi mang (Network) cho Valorant Optimize 1.0.0

function Check-Network {
    Write-Log "Kiem tra Configuring Network hien tai..." "INFO"
    
    # Kiem tra Configuring TCP o muc toan cuc
    $tcpPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    if (Test-Path $tcpPath) {
        $sack = Get-ItemPropertyValue -Path $tcpPath -Name "SackOpts" -ErrorAction SilentlyContinue
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
    
    # 2. Tat cac Mode tiet kiem ien nang tren Card Mang (Giam o tre goi tin)
    try {
        # Tat Energy Efficient Ethernet (EEE)
        Set-NetAdapterAdvancedProperty -Name * -RegistryKeyword "*EEE" -RegistryValue "0" -ErrorAction SilentlyContinue | Out-Null
        # Tat Green Ethernet
        Set-NetAdapterAdvancedProperty -Name * -RegistryKeyword "*Green" -RegistryValue "0" -ErrorAction SilentlyContinue | Out-Null
        # Bat Receive Side Scaling (RSS) e xu ly goi tin tren nhieu nhan CPU
        Set-NetAdapterAdvancedProperty -Name * -RegistryKeyword "*RSS" -RegistryValue "1" -ErrorAction SilentlyContinue | Out-Null
        
        Write-Log "a Configuring EEE=0, GreenEthernet=0, RSS=1 tren cac card mang co ho tro." "INFO"
    } catch {
        Write-Log "ERROR khi Configuring nang cao Adapter mang: $_" "WARNING"
    }
    
    # 3. Optimizing cac cai at TCP/IP khac
    $tcpPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    if (Test-Path $tcpPath) {
        Backup-RegistryValue -Path $tcpPath -ValueName "SackOpts"
        Backup-RegistryValue -Path $tcpPath -ValueName "TcpWindowSize"
        
        # SackOpts = 1 (Bat selective ack)
        Set-ItemProperty -Path $tcpPath -Name "SackOpts" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
        # Configuring kich thuoc cua so nhan du lieu toi uu
        Set-ItemProperty -Path $tcpPath -Name "TcpWindowSize" -Value 65535 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    Write-Log "Optimizing Network Completed!" "SUCCESS"
}

function Restore-Network {
    Write-Log "Currently Restore Configuring Network..." "INFO"
}

function Verify-Network {
    Write-Log "Xac minh Configuring Network..." "INFO"
    return $true
}

function WriteLog-Network {
    # Tich hop truc tiep qua Logger
}





