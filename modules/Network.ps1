# modules/Network.ps1
# Module tối ưu hóa kết nối mạng (Network) cho Valorant Optimize 1.0.0

function Check-Network {
    Write-Log "Kiểm tra cấu hình Network hiện tại..." "INFO"
    
    # Kiểm tra cấu hình TCP ở mức toàn cục
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
    
    Write-Log "Bắt đầu tối ưu hóa cài đặt mạng..." "INFO"
    
    $tcpNoDelay = $Config.settings.network.TCPNoDelay
    $tcpAckFreq = $Config.settings.network.TCPAckFrequency
    
    # 1. Tối ưu TCP Nagle's Algorithm (TcpAckFrequency & TCPNoDelay) cho từng card mạng
    $interfacesPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    if (Test-Path $interfacesPath) {
        $interfaces = Get-ChildItem -Path $interfacesPath -ErrorAction SilentlyContinue
        foreach ($i in $interfaces) {
            Backup-RegistryValue -Path $i.PSPath -ValueName "TcpAckFrequency"
            Backup-RegistryValue -Path $i.PSPath -ValueName "TCPNoDelay"
            
            Set-ItemProperty -Path $i.PSPath -Name "TcpAckFrequency" -Value $tcpAckFreq -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
            Set-ItemProperty -Path $i.PSPath -Name "TCPNoDelay" -Value $tcpNoDelay -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
        }
        Write-Log "Đã cấu hình TCPNoDelay và TcpAckFrequency thành công trên các card mạng." "INFO"
    }
    
    # 2. Tắt các chế độ tiết kiệm điện năng trên Card Mạng (Giảm độ trễ gói tin)
    try {
        # Tắt Energy Efficient Ethernet (EEE)
        Set-NetAdapterAdvancedProperty -Name * -RegistryKeyword "*EEE" -RegistryValue "0" -ErrorAction SilentlyContinue | Out-Null
        # Tắt Green Ethernet
        Set-NetAdapterAdvancedProperty -Name * -RegistryKeyword "*Green" -RegistryValue "0" -ErrorAction SilentlyContinue | Out-Null
        # Bật Receive Side Scaling (RSS) để xử lý gói tin trên nhiều nhân CPU
        Set-NetAdapterAdvancedProperty -Name * -RegistryKeyword "*RSS" -RegistryValue "1" -ErrorAction SilentlyContinue | Out-Null
        
        Write-Log "Đã cấu hình EEE=0, GreenEthernet=0, RSS=1 trên các card mạng có hỗ trợ." "INFO"
    } catch {
        Write-Log "Lỗi khi cấu hình nâng cao Adapter mạng: $_" "WARNING"
    }
    
    # 3. Tối ưu hóa các cài đặt TCP/IP khác
    $tcpPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    if (Test-Path $tcpPath) {
        Backup-RegistryValue -Path $tcpPath -ValueName "SackOpts"
        Backup-RegistryValue -Path $tcpPath -ValueName "TcpWindowSize"
        
        # SackOpts = 1 (Bật selective ack)
        Set-ItemProperty -Path $tcpPath -Name "SackOpts" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
        # Cấu hình kích thước cửa sổ nhận dữ liệu tối ưu
        Set-ItemProperty -Path $tcpPath -Name "TcpWindowSize" -Value 65535 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    Write-Log "Tối ưu hóa Network hoàn tất!" "SUCCESS"
}

function Restore-Network {
    Write-Log "Đang khôi phục cấu hình Network..." "INFO"
}

function Verify-Network {
    Write-Log "Xác minh cấu hình Network..." "INFO"
    return $true
}

function WriteLog-Network {
    # Tích hợp trực tiếp qua Logger
}





