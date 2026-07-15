# ui/Draw.ps1
# Thư viện vẽ giao diện Console Gaming cho Valorant Optimize 1.0.0

# Điều chỉnh kích thước Console
function Set-ConsoleSize {
    param (
        [int]$Width = 120,
        [int]$Height = 35
    )
    
    # Ẩn con trỏ nhấp nháy để đỡ ngứa mắt
    [Console]::CursorVisible = $false
    
    try {
        # Đặt kích thước buffer trước, kích thước window sau để tránh crash
        if ($Host.UI.RawUI.BufferSize.Width -lt $Width -or $Host.UI.RawUI.BufferSize.Height -lt $Height) {
            $bufferSize = New-Object System.Management.Automation.Host.Size($Width, 2000)
            $Host.UI.RawUI.BufferSize = $bufferSize
        }
        $windowSize = New-Object System.Management.Automation.Host.Size($Width, $Height)
        $Host.UI.RawUI.WindowSize = $windowSize
        
        # Đặt lại buffer bằng đúng window để bỏ thanh cuộn bên phải
        $bufferSize = New-Object System.Management.Automation.Host.Size($Width, $Height)
        $Host.UI.RawUI.BufferSize = $bufferSize
    } catch {
        # Bỏ qua nếu môi trường không cho phép resize (VD: VSCode terminal)
    }
}

# Di chuyển con trỏ
function Move-Cursor {
    param (
        [int]$Col,
        [int]$Row
    )
    [Console]::SetCursorPosition($Col, $Row)
}

# Xóa màn hình
function Clear-Screen {
    [Console]::Clear()
}

# Vẽ đường kẻ ngang
function Draw-HorizontalLine {
    param (
        [int]$Col,
        [int]$Row,
        [int]$Length,
        [string]$Char = "═",
        [string]$Color = "Gray"
    )
    Move-Cursor $Col $Row
    $line = $Char * $Length
    Write-Ansi $line -Color $Color -NoNewLine
}

# Vẽ khung chữ nhật (Double-line box)
function Draw-Box {
    param (
        [int]$Col,
        [int]$Row,
        [int]$Width,
        [int]$Height,
        [string]$Title = "",
        [string]$Color = "Cyan"
    )
    
    $topLeft = "╔"
    $topRight = "╗"
    $bottomLeft = "╚"
    $bottomRight = "╝"
    $horizontal = "═"
    $vertical = "║"
    
    # Vẽ góc trên và tiêu đề
    Move-Cursor $Col $Row
    if ($Title -ne "") {
        $titleStr = " $Title "
        $leftLength = [Math]::Floor(($Width - $titleStr.Length - 2) / 2)
        $rightLength = $Width - $titleStr.Length - 2 - $leftLength
        $headerLine = $topLeft + ($horizontal * $leftLength) + (Get-AnsiStr $titleStr -Color "BrightWhite") + ($horizontal * $rightLength) + $topRight
        Write-Ansi $headerLine -Color $Color -NoNewLine
    } else {
        $headerLine = $topLeft + ($horizontal * ($Width - 2)) + $topRight
        Write-Ansi $headerLine -Color $Color -NoNewLine
    }
    
    # Vẽ các hàng bên cạnh
    for ($i = 1; $i -lt ($Height - 1); $i++) {
        Move-Cursor $Col ($Row + $i)
        Write-Ansi $vertical -Color $Color -NoNewLine
        Move-Cursor ($Col + $Width - 1) ($Row + $i)
        Write-Ansi $vertical -Color $Color -NoNewLine
    }
    
    # Vẽ cạnh dưới
    Move-Cursor $Col ($Row + $Height - 1)
    $footerLine = $bottomLeft + ($horizontal * ($Width - 2)) + $bottomRight
    Write-Ansi $footerLine -Color $Color -NoNewLine
}

# Vẽ logo mở màn ASCII và hoạt ảnh typing / fade
function Draw-StartupLogo {
    Clear-Screen
    $logo = @(
        "   ██████╗ ██╗███████╗██╗  ██╗    ",
        "   ██╔══██╗██║██╔════╝╚██╗██╔╝    ",
        "   ██████╔╝██║█████╗   ╚███╔╝     ",
        "   ██╔══██╗██║██╔══╝   ██╔██╗     ",
        "   ██║  ██║██║███████╗██╔╝ ██╗    ",
        "   ╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═╝    "
    )
    
    $startRow = 5
    $startCol = 42
    
    # Hiệu ứng gõ chữ (typing)
    for ($i = 0; $i -lt $logo.Count; $i++) {
        Move-Cursor $startCol ($startRow + $i)
        $line = $logo[$i]
        for ($j = 0; $j -lt $line.Length; $j++) {
            Write-Ansi $line[$j] -Color "BrightCyan" -NoNewLine
            Start-Sleep -Milliseconds 3
        }
    }
    
    # In thêm thông tin bản quyền
    Move-Cursor 45 13
    Write-Ansi "VALORANT OPTIMIZE 1.0.0" -Color "BrightWhite"
    Move-Cursor 47 15
    Write-Ansi "Powered by VieX Digital" -Color "Gray"
    Move-Cursor 49 16
    Write-Ansi "License: VieX Studio" -Color "Gray"
    
    # Vẽ tiến trình giả lập lúc mở màn
    Move-Cursor 40 20
    Write-Ansi "Đang nạp động cơ tối ưu..." -Color "Cyan"
    
    # Progress Bar mở màn
    for ($k = 0; $k -le 10; $k++) {
        Move-Cursor 40 22
        $bar = ("█" * $k) + ("░" * (10 - $k))
        Write-Ansi $bar -Color "BrightCyan" -NoNewLine
        Write-Ansi " $($k * 10)%" -Color "BrightWhite" -NoNewLine
        Start-Sleep -Milliseconds 150
    }
    
    Start-Sleep -Milliseconds 400
}

# Vẽ khung cấu trúc chính (Layout)
function Draw-Layout {
    Clear-Screen
    Set-ConsoleSize 120 35
    
    # Vẽ khung tổng thể ứng dụng
    Draw-Box 0 0 120 34 " VALORANT OPTIMIZE v1.0.0 " "Cyan"
    
    # Phân chia vùng Sidebar và Content
    # Vẽ đường ngăn dọc cho Sidebar (cột 25)
    for ($i = 1; $i -lt 33; $i++) {
        Move-Cursor 25 $i
        Write-Ansi "║" -Color "Cyan" -NoNewLine
    }
    
    # Vẽ ngã ba biên trên và dưới cột ngăn dọc
    Move-Cursor 25 0
    Write-Ansi "╦" -Color "Cyan" -NoNewLine
    Move-Cursor 25 33
    Write-Ansi "╩" -Color "Cyan" -NoNewLine
    
    # In footer bản quyền bên dưới cùng
    Move-Cursor 3 33
    Write-Ansi "VieX Digital | VieX Studio" -Color "Gray" -NoNewLine
    
    # Trạng thái gõ phím hướng dẫn góc phải
    Move-Cursor 90 33
    Write-Ansi "↑↓: Chọn | Enter: Đồng ý" -Color "Gray" -NoNewLine
}

# Xuất thông tin lên vùng content
function Clear-ContentArea {
    for ($i = 1; $i -lt 33; $i++) {
        Move-Cursor 26 $i
        # Xóa sạch dòng từ cột 26 đến 119
        Write-Ansi (" " * 93) -NoNewLine
    }
}

Export-ModuleMember -Function Set-ConsoleSize, Move-Cursor, Clear-Screen, Draw-Box, Draw-StartupLogo, Draw-Layout, Clear-ContentArea, Draw-HorizontalLine




