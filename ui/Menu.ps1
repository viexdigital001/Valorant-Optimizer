# ui/Menu.ps1
# Hệ thống điều hướng Menu Console bằng bàn phím cho Valorant Optimize 1.0.0

function Draw-SidebarMenu {
    param (
        [Parameter(Mandatory=$true)]
        [array]$Items,
        [Parameter(Mandatory=$true)]
        [int]$SelectedIndex
    )
    
    $startRow = 4
    $col = 3
    
    for ($i = 0; $i -lt $Items.Count; $i++) {
        Move-Cursor $col ($startRow + $i)
        
        $itemText = $Items[$i]
        
        if ($i -eq $SelectedIndex) {
            # Mục đang được chọn: Vẽ mũi tên màu Cyan, chữ in đậm
            Write-Ansi "▶ " -Color "BrightCyan" -NoNewLine
            Write-Ansi $itemText -Color "BrightCyan" -NoNewLine
            # Xóa các ký tự thừa phía sau bằng cách đệm khoảng trắng
            $padding = 20 - $itemText.Length
            if ($padding -gt 0) { Write-Host (" " * $padding) -NoNewline }
        } else {
            # Mục thường: In chữ xám/trắng
            Write-Ansi "  " -NoNewLine
            Write-Ansi $itemText -Color "White" -NoNewLine
            $padding = 20 - $itemText.Length
            if ($padding -gt 0) { Write-Host (" " * $padding) -NoNewline }
        }
    }
}

function Get-MenuSelection {
    param (
        [Parameter(Mandatory=$true)]
        [array]$Items,
        [Parameter(Mandatory=$false)]
        [int]$DefaultIndex = 0
    )
    
    $selectedIndex = $DefaultIndex
    $running = $true
    
    # Vẽ menu lần đầu tiên
    Draw-SidebarMenu $Items $selectedIndex
    
    while ($running) {
        # Đợi phím bấm của người dùng
        $key = [Console]::ReadKey($true)
        
        switch ($key.Key) {
            "UpArrow" {
                if ($selectedIndex -gt 0) {
                    $selectedIndex--
                    Draw-SidebarMenu $Items $selectedIndex
                } else {
                    $selectedIndex = $Items.Count - 1
                    Draw-SidebarMenu $Items $selectedIndex
                }
            }
            "DownArrow" {
                if ($selectedIndex -lt ($Items.Count - 1)) {
                    $selectedIndex++
                    Draw-SidebarMenu $Items $selectedIndex
                } else {
                    $selectedIndex = 0
                    Draw-SidebarMenu $Items $selectedIndex
                }
            }
            "Enter" {
                $running = $false
                return $selectedIndex
            }
            "Escape" {
                $running = $false
                return -1 # -1 nghĩa là nhấn ESC thoát hoặc quay lại
            }
        }
    }
}

# Hàm hiển thị prompt xác nhận Y/N Gen Z
function Get-Confirmation {
    param (
        [Parameter(Mandatory=$true)]
        [string]$PromptMessage,
        [int]$Col = 28,
        [int]$Row = 20
    )
    
    Move-Cursor $Col $Row
    # Xóa sạch dòng cần viết
    Write-Ansi (" " * 85) -NoNewLine
    Move-Cursor $Col $Row
    Write-Ansi "$PromptMessage [Y/N]: " -Color "BrightYellow" -NoNewLine
    
    while ($true) {
        $key = [Console]::ReadKey($true)
        if ($key.KeyChar -eq 'y' -or $key.KeyChar -eq 'Y') {
            return $true
        }
        if ($key.KeyChar -eq 'n' -or $key.KeyChar -eq 'N') {
            return $false
        }
    }
}

Export-ModuleMember -Function Draw-SidebarMenu, Get-MenuSelection, Get-Confirmation


