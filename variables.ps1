    # Ruta del archivo de texto
    #$filePath = "https://github.com/SoporteLaRed/PowerShell/raw/refs/heads/main/variables.txt"
    $filePath = "https://raw.githubusercontent.com/SoporteLaRed/PowerShell/refs/heads/main/variables.txt"
    # Leer las líneas del archivo
    $lines = Get-Content $filePath
    # Procesar cada línea como clave=valor
    foreach ($line in $lines) {
        $key, $value = $line -split "="
        Set-Variable -Name $key -Value $value
    }
    # Usar las variables
    Write-Host "Token: $Token"
    Write-Host "UrlMST: $UrlMST"
    Write-Host "UrlMSI $UrlM"
