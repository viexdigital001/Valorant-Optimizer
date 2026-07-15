$response = Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/viexdigital001/Valorant-Optimizer/main/core/OptimizeEngine.ps1' -Method Head
$response.Headers | Out-String
