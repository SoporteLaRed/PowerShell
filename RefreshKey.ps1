# Ruta del archivo .smt y la clave de implementación
$RutaArchivo = "C:\ruta\a\archivo.smt"  # Reemplaza con la ruta de tu archivo
$DeploymentKey = "MiClaveDeDeployment"  # La clave de implementación deseada

# Verifica si el archivo existe
if (-Not (Test-Path $RutaArchivo)) {
    Write-Warning "El archivo $RutaArchivo no existe."
    return
}

# Leer el contenido del archivo .smt
$Contenido = Get-Content -Path $RutaArchivo -Raw

# Buscar si ya existe una clave 'deploymentkey' y actualizarla o agregarla
if ($Contenido -match "<deploymentkey>(.*?)</deploymentkey>") {
    # Actualiza el valor de 'deploymentkey'
    $Contenido = $Contenido -replace "<deploymentkey>(.*?)</deploymentkey>", "<deploymentkey>$DeploymentKey</deploymentkey>"
    Write-Host "La clave 'deploymentkey' fue actualizada en el archivo."
} else {
    # Agrega la clave 'deploymentkey' (suponiendo que es un archivo XML)
    $Contenido = $Contenido -replace "(</root>|</config>|</settings>)", "<deploymentkey>$DeploymentKey</deploymentkey>`n`$1"
    Write-Host "La clave 'deploymentkey' fue agregada al archivo."
}

# Guardar los cambios en el archivo original
if ($RutaArchivo) {
    Set-Content -Path $RutaArchivo -Value $Contenido -Encoding UTF8
    Write-Host "El archivo original fue actualizado."
}