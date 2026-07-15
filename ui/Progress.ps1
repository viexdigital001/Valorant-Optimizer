# ui/Progress.ps1
# Thanh tien trinh o hoa chong nhap nhay cho Valorant Optimize 1.0.0

function Draw-ProgressBar {
    param (
        [Parameter(Mandatory=$true)]
        [int]$Col,
        [Parameter(Mandatory=$true)]
        [int]$Row,
        [Parameter(Mandatory=$true)]
        [int]$Percent,
        [Parameter(Mandatory=$false)]
        [string]$StatusText = "",
        [Parameter(Mandatory=$false)]
        [string]$Color = "BrightCyan"
    )
    
    $barWidth = 40
    $filledLength = [Math]::Floor(($Percent / 100) * $barWidth)
    if ($filledLength -gt $barWidth) { $filledLength = $barWidth }
    $unfilledLength = $barWidth - $filledLength
    
    $filledBar = "#" * $filledLength
    $unfilledBar = "-" * $unfilledLength
    
    Move-Cursor $Col $Row
    # Xoa sach dong cu truoc khi ghi e e khong bi e chu thua
    Write-Ansi (" " * 90) -NoNewLine
    
    Move-Cursor $Col $Row
    Write-Ansi "[" -Color "Gray" -NoNewLine
    Write-Ansi "$filledBar" -Color $Color -NoNewLine
    Write-Ansi "$unfilledBar" -Color "Gray" -NoNewLine
    Write-Ansi "] " -Color "Gray" -NoNewLine
    Write-Ansi "$Percent%" -Color "BrightWhite" -NoNewLine
    
    if ($StatusText -ne "") {
        Write-Ansi " - $StatusText" -Color "Gray" -NoNewLine
    }
}





