$githubRepo = 'viexdigital001/Valorant-Optimizer'
$rawBaseUrl = "https://raw.githubusercontent.com/$githubRepo/main"
Invoke-RestMethod -Uri "$rawBaseUrl/core/OptimizeEngine.ps1?t=$(Get-Date -UFormat %s)" -OutFile 'test_opt.ps1'
Format-Hex 'test_opt.ps1' | Select-Object -First 3
