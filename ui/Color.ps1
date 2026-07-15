# ui/Color.ps1
# Định nghĩa bảng màu ANSI cho Valorant Optimize 1.0.0

$esc = [char]27
$Global:Colors = @{
    Reset        = "$esc[0m"
    Bold         = "$esc[1m"
    Dim          = "$esc[2m"
    Underline    = "$esc[4m"
    
    # Foreground colors
    Black        = "$esc[30m"
    Red          = "$esc[31m"
    Green        = "$esc[32m"
    Yellow       = "$esc[33m"
    Blue         = "$esc[34m"
    Magenta      = "$esc[35m"
    Cyan         = "$esc[36m"
    White        = "$esc[37m"
    
    # Bright foreground colors
    Gray         = "$esc[90m"
    BrightRed    = "$esc[91m"
    BrightGreen  = "$esc[92m"
    BrightYellow = "$esc[93m"
    BrightBlue   = "$esc[94m"
    BrightMagenta= "$esc[95m"
    BrightCyan   = "$esc[96m"
    BrightWhite  = "$esc[97m"
    
    # Background colors
    BGBlack      = "$esc[40m"
    BGRed        = "$esc[41m"
    BGGreen      = "$esc[42m"
    BGYellow     = "$esc[43m"
    BGBlue       = "$esc[44m"
    BGMagenta    = "$esc[45m"
    BGCyan       = "$esc[46m"
    BGWhite      = "$esc[47m"
    BGGray       = "$esc[100m"
}

# Hàm ghi văn bản màu ra màn hình
function Write-Ansi {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string]$Text,
        [Parameter(Mandatory=$false)]
        [string]$Color = "White",
        [Parameter(Mandatory=$false)]
        [string]$BGColor = "",
        [Parameter(Mandatory=$false)]
        [switch]$NoNewLine,
        [Parameter(Mandatory=$false)]
        [switch]$Bold,
        [Parameter(Mandatory=$false)]
        [switch]$Underline
    )
    
    $colorCode = ""
    if ($Bold) { $colorCode += $Global:Colors['Bold'] }
    if ($Underline) { $colorCode += $Global:Colors['Underline'] }
    if ($Global:Colors.ContainsKey($Color)) {
        $colorCode += $Global:Colors[$Color]
    }
    if ($BGColor -and $Global:Colors.ContainsKey($BGColor)) {
        $colorCode += $Global:Colors[$BGColor]
    }
    
    $outputText = "${colorCode}${Text}$($Global:Colors['Reset'])"
    
    if ($NoNewLine) {
        Write-Host $outputText -NoNewline
    } else {
        Write-Host $outputText
    }
}

# Trả về chuỗi màu thay vì in ra trực tiếp (tiện cho vẽ khung phức tạp)
function Get-AnsiStr {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string]$Text,
        [Parameter(Mandatory=$false)]
        [string]$Color = "White",
        [Parameter(Mandatory=$false)]
        [string]$BGColor = "",
        [Parameter(Mandatory=$false)]
        [switch]$Bold,
        [Parameter(Mandatory=$false)]
        [switch]$Underline
    )
    
    $colorCode = ""
    if ($Bold) { $colorCode += $Global:Colors['Bold'] }
    if ($Underline) { $colorCode += $Global:Colors['Underline'] }
    if ($Global:Colors.ContainsKey($Color)) {
        $colorCode += $Global:Colors[$Color]
    }
    if ($BGColor -and $Global:Colors.ContainsKey($BGColor)) {
        $colorCode += $Global:Colors[$BGColor]
    }
    
    return "${colorCode}${Text}$($Global:Colors['Reset'])"
}





