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
        [AllowEmptyString()]
        [AllowNull()]
        [string]$StatusText = "",
        [Parameter(Mandatory=$false)]
        [string]$Color = "BrightCyan"
    )
    
    try {
        # 1. Clamp Percent an toan trong pham vi [0, 100]
        $clampedPercent = [Math]::Max(0, [Math]::Min(100, $Percent))
        
        # 2. Tinh toan chieu dai thanh tien trinh (do rong 40 ky tu)
        $barWidth = 40
        $filledLength = [Math]::Max(0, [Math]::Min($barWidth, [int][Math]::Floor(($clampedPercent / 100.0) * $barWidth)))
        $unfilledLength = [Math]::Max(0, $barWidth - $filledLength)
        
        $filledBar = if ($filledLength -gt 0) { "#" * $filledLength } else { "" }
        $unfilledBar = if ($unfilledLength -gt 0) { "-" * $unfilledLength } else { "" }
        
        Move-Cursor $Col $Row
        # Xoa sach dong cu truoc khi ghi de khong bi de chu thua
        try {
            $bufWidth = [Console]::BufferWidth
            $clearLen = [Math]::Max(10, [Math]::Min(90, $bufWidth - $Col - 1))
            Write-Ansi (" " * $clearLen) -NoNewLine
        } catch {
            Write-Ansi (" " * 80) -NoNewLine
        }
        
        Move-Cursor $Col $Row
        Write-Ansi "[" -Color "Gray" -NoNewLine
        if ($filledLength -gt 0) {
            Write-Ansi $filledBar -Color $Color -NoNewLine
        }
        if ($unfilledLength -gt 0) {
            Write-Ansi $unfilledBar -Color "Gray" -NoNewLine
        }
        Write-Ansi "] " -Color "Gray" -NoNewLine
        Write-Ansi "$clampedPercent%" -Color "BrightWhite" -NoNewLine
        
        if (-not [string]::IsNullOrEmpty($StatusText)) {
            Write-Ansi " - $StatusText" -Color "Gray" -NoNewLine
        }
    } catch {
        # Defensive catch: prevent any UI drawing glitch from crashing the application
    }
}







