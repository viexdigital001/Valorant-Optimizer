# ui/Menu.ps1
# He thong ieu huong Menu Console bang ban phim cho Valorant Optimize 1.0.0

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
            # Muc ang uoc chon: Ve mui ten mau Cyan, chu in am
            Write-Ansi "> " -Color "BrightCyan" -NoNewLine
            Write-Ansi $itemText -Color "BrightCyan" -NoNewLine
            # Xoa cac ky tu thua phia sau bang cach em khoang trang
            $padding = 20 - $itemText.Length
            if ($padding -gt 0) { Write-Host (" " * $padding) -NoNewline }
        } else {
            # Muc thuong: In chu xam/trang
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
    
    # Ve menu lan au tien
    Draw-SidebarMenu $Items $selectedIndex
    
    while ($running) {
        # oi phim bam cua nguoi dung
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
                return -1 # -1 nghia la nhan ESC thoat hoac quay lai
            }
        }
    }
}

# Ham hien thi prompt xac nhan Y/N Gen Z
function Get-Confirmation {
    param (
        [Parameter(Mandatory=$true)]
        [string]$PromptMessage,
        [int]$Col = 28,
        [int]$Row = 20
    )
    
    Move-Cursor $Col $Row
    # Xoa sach dong can viet
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





