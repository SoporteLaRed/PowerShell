# Define la URL de la aplicación y la ruta de destino
$AppUrl = "https://downloads.dell.com/serviceability/catalog/SupportAssistinstaller.exe"  # Reemplaza con la URL real
$Destino = "$env:Temp\mi-aplicacion.exe"          # Ruta de destino temporal

# Descarga la aplicación
Write-Host "Descargando la aplicacion desde $AppUrl..."
Invoke-WebRequest -Uri $AppUrl -OutFile $Destino -UseBasicParsing

# Verifica si la descarga fue exitosa
if (Test-Path $Destino) {
    Write-Host "Descarga completada. Ejecutando la aplicacion..."
    
    # Ejecuta la aplicación
    Start-Process -FilePath $Destino -Wait
} else {
    Write-Host "Error: No se pudo descargar la aplicacion."
}
