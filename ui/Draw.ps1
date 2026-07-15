# ui/Draw.ps1
# Thu vien ve giao dien Console Gaming cho Valorant Optimize 1.0.0

# ieu chinh kich thuoc Console
function Set-ConsoleSize {
    param (
        [int]$Width = 120,
        [int]$Height = 35
    )
    
    # An con tro nhap nhay e o ngua mat
    [Console]::CursorVisible = $false
    
    try {
        # at kich thuoc buffer truoc, kich thuoc window sau e tranh crash
        if ($Host.UI.RawUI.BufferSize.Width -lt $Width -or $Host.UI.RawUI.BufferSize.Height -lt $Height) {
            $bufferSize = New-Object System.Management.Automation.Host.Size($Width, 2000)
            $Host.UI.RawUI.BufferSize = $bufferSize
        }
        $windowSize = New-Object System.Management.Automation.Host.Size($Width, $Height)
        $Host.UI.RawUI.WindowSize = $windowSize
        
        # at lai buffer bang ung window e bo thanh cuon ben phai
        $bufferSize = New-Object System.Management.Automation.Host.Size($Width, $Height)
        $Host.UI.RawUI.BufferSize = $bufferSize
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
    [Console]::SetCursorPosition($Col, $Row)
}

# Xoa man hinh
function Clear-Screen {
    [Console]::Clear()
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
    
    # Progress Bar mo man
    for ($k = 0; $k -le 10; $k++) {
        Move-Cursor 40 22
        $bar = ("#" * $k) + ("-" * (10 - $k))
        Write-Ansi "[$bar]" -Color "BrightCyan" -NoNewLine
        Write-Ansi " $($k * 10)%" -Color "BrightWhite" -NoNewLine
        Start-Sleep -Milliseconds 150
    }
    
    Start-Sleep -Milliseconds 400
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
    for ($i = 1; $i -lt 33; $i++) {
        Move-Cursor 26 $i
        # Xoa sach dong tu cot 26 en 119
        Write-Ansi (" " * 93) -NoNewLine
    }
}





