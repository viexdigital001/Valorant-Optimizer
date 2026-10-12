# ui/Draw.ps1
# Thu vien ve giao dien Console Gaming cho Valorant Optimize 1.0.0

# ieu chinh kich thuoc Console
function Set-ConsoleSize {
    param (
        [int]$Width = 120,
        [int]$Height = 35
    )
    
    try {
        [Console]::CursorVisible = $false
    } catch {}
    
    try {
        $rawUI = $Host.UI.RawUI
        if ($rawUI) {
            $curBuf = $rawUI.BufferSize
            $newBufWidth = [Math]::Max($curBuf.Width, $Width)
            $newBufHeight = [Math]::Max($curBuf.Height, 2000)
            $rawUI.BufferSize = New-Object System.Management.Automation.Host.Size($newBufWidth, $newBufHeight)
            
            $rawUI.WindowSize = New-Object System.Management.Automation.Host.Size($Width, $Height)
            $rawUI.BufferSize = New-Object System.Management.Automation.Host.Size($Width, $Height)
        }
    } catch {
        # Bo qua neu moi truong khong cho phep resize (VD: VSCode terminal)
    }
}

# Di chuyen con tro
function Move-Cursor {
    param (
        [int]$Col,
        [int]$Row
    )
    try {
        $maxCol = [Console]::BufferWidth - 1
        $maxRow = [Console]::BufferHeight - 1
        if ($maxCol -gt 0 -and $Col -gt $maxCol) { $Col = $maxCol }
        if ($maxRow -gt 0 -and $Row -gt $maxRow) { $Row = $maxRow }
        if ($Col -lt 0) { $Col = 0 }
        if ($Row -lt 0) { $Row = 0 }
        [Console]::SetCursorPosition($Col, $Row)
    } catch {}
}

# Xoa man hinh
function Clear-Screen {
    try {
        [Console]::Clear()
    } catch {
        Clear-Host
    }
}

# Ve uong ke ngang
function Draw-HorizontalLine {
    param (
        [int]$Col,
        [int]$Row,
        [int]$Length,
        [string]$Char = "-",
        [string]$Color = "Gray"
    )
    Move-Cursor $Col $Row
    $line = $Char * $Length
    Write-Ansi $line -Color $Color -NoNewLine
}

# Ve khung chu nhat (Double-line box)
function Draw-Box {
    param (
        [int]$Col,
        [int]$Row,
        [int]$Width,
        [int]$Height,
        [string]$Title = "",
        [string]$Color = "Cyan"
    )
    
    $topLeft = "+"
    $topRight = "+"
    $bottomLeft = "+"
    $bottomRight = "+"
    $horizontal = "-"
    $vertical = "|"
    
    # Ve goc tren va tieu e
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
    
    # Ve cac hang ben canh
    for ($i = 1; $i -lt ($Height - 1); $i++) {
        Move-Cursor $Col ($Row + $i)
        Write-Ansi $vertical -Color $Color -NoNewLine
        Move-Cursor ($Col + $Width - 1) ($Row + $i)
        Write-Ansi $vertical -Color $Color -NoNewLine
    }
    
    # Ve canh duoi
    Move-Cursor $Col ($Row + $Height - 1)
    $footerLine = $bottomLeft + ($horizontal * ($Width - 2)) + $bottomRight
    Write-Ansi $footerLine -Color $Color -NoNewLine
}

# Ve logo mo man ASCII va hoat anh typing / fade
function Draw-StartupLogo {
    Clear-Screen
    $logo = @(
        ' __      __  ___   _____   __  __  ',
        ' \ \    / / |_ _| |  ___|  \ \/ /  ',
        '  \ \  / /   | |  | |__     \  /   ',
        '   \ \/ /    | |  |  __|    /  \   ',
        '    \  /    _| |_ | |___   / /\ \  ',
        '     \/    |_____||_____| /_/  \_\ '
    )
    
    $startRow = 5
    $startCol = 42
    
    # Hieu ung go chu (typing)
    for ($i = 0; $i -lt $logo.Count; $i++) {
        Move-Cursor $startCol ($startRow + $i)
        $line = $logo[$i]
        for ($j = 0; $j -lt $line.Length; $j++) {
            Write-Ansi $line[$j] -Color "BrightCyan" -NoNewLine
            Start-Sleep -Milliseconds 3
        }
    }
    
    # In them thong tin ban quyen
    Move-Cursor 45 13
    Write-Ansi "VALORANT OPTIMIZE 1.0.0" -Color "BrightWhite"
    Move-Cursor 47 15
    Write-Ansi "Powered by VieX Digital" -Color "Gray"
    Move-Cursor 49 16
    Write-Ansi "License: VieX Studio" -Color "Gray"
    
    # Ve tien trinh gia lap luc mo man
    Move-Cursor 40 20
    Write-Ansi "Loading optimization engine..." -Color "Cyan"
    
    # Progress Bar mo man (nhanh va muot ma)
    for ($k = 0; $k -le 10; $k++) {
        Move-Cursor 40 22
        $bar = ("#" * $k) + ("-" * (10 - $k))
        Write-Ansi "[$bar]" -Color "BrightCyan" -NoNewLine
        Write-Ansi " $($k * 10)%" -Color "BrightWhite" -NoNewLine
        Start-Sleep -Milliseconds 45
    }
    
    Start-Sleep -Milliseconds 150
}

# Ve khung cau truc chinh (Layout)
function Draw-Layout {
    Clear-Screen
    Set-ConsoleSize 120 35
    
    # Ve khung tong the ung dung
    Draw-Box 0 0 120 34 " VALORANT OPTIMIZE v1.0.0 " "Cyan"
    
    # Phan chia vung Sidebar va Content
    # Ve uong ngan doc cho Sidebar (cot 25)
    for ($i = 1; $i -lt 33; $i++) {
        Move-Cursor 25 $i
        Write-Ansi "|" -Color "Cyan" -NoNewLine
    }
    
    # Ve nga ba bien tren va duoi cot ngan doc
    Move-Cursor 25 0
    Write-Ansi "+" -Color "Cyan" -NoNewLine
    Move-Cursor 25 33
    Write-Ansi "+" -Color "Cyan" -NoNewLine
    
    # In footer ban quyen ben duoi cung
    Move-Cursor 3 33
    Write-Ansi "VieX Digital | VieX Studio" -Color "Gray" -NoNewLine
    
    # Trang thai go phim huong dan goc phai
    Move-Cursor 85 33
    Write-Ansi "[Up/Down]: Select | [Enter]: Accept" -Color "Gray" -NoNewLine
}

# Xuat thong tin len vung content
function Clear-ContentArea {
    try {
        $bufWidth = [Console]::BufferWidth
        $contentWidth = [Math]::Max(10, [Math]::Min(93, $bufWidth - 27))
        $spaces = " " * $contentWidth
        for ($i = 1; $i -lt 33; $i++) {
            Move-Cursor 26 $i
            Write-Ansi $spaces -NoNewLine
        }
    } catch {}
}







