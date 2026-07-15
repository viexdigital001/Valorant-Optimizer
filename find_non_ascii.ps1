Get-ChildItem -Path '.' -Filter '*.ps1' -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw -Encoding UTF8
    if ($content -match '[^\x00-\x7F]') {
        Write-Host $_.FullName
    }
}
