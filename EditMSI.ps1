<#Descargar Archivos OnLine
# Define la URL del MSI y la ruta de destino
$AppUrlMSI = "http://soporte.lared.mx/SupportAssistInstaller.msi"  # Reemplaza con la URL real
$DestinoMSI = "$env:Temp\MSI-aplicacion.msi"          # Ruta de destino temporal
# Define la URL del MST y la ruta de destino
$AppUrlMST = "https://github.com/SoporteLaRed/PowerShell/raw/refs/heads/main/SupportAssistConfiguration.mst"  # Reemplaza con la URL real
$DestinoMST = "$env:Temp\MST-aplicacion.mst"          # Ruta de destino temporal
# Descarga la archivos
Write-Host "Descargando MSI desde $UrlMSI..."
Invoke-WebRequest -Uri $UrlMSI -OutFile $DestinoMSI -UseBasicParsing
Write-Host "Descargando MST desde $UrlMST..."
Invoke-WebRequest -Uri $UrlMST -OutFile $DestinoMST -UseBasicParsing
# Verifica si la descarga fue exitosa
if (Test-Path $DestinoMSI) {
    Write-Host "Descarga MSI completada. Ejecutando la aplicacion..."
    
    # Ejecuta la aplicación
    #Start-Process -FilePath $Destino -Wait
    
    if (Test-Path $DestinoMST) {
    Write-Host "Descarga MST completada. Ejecutando la aplicacion..."
    
    # Ejecuta la aplicación
    #Start-Process -FilePath $Destino -Wait
    $msiPath = $DestinoMSI
    $mstPath = $DestinoMST
    $token = "L4r3d2025$"
    # Aplicar el MST durante la instalación
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiPath`" TRANSFORMS=`"$mstPath`" DEPLOYMENTKEY=`"$token`" /quiet /norestart" -Wait
    Write-Host "MSI instalado con el transformador aplicado."
  } else {
    Write-Host "Error: No se pudo descargar la archivo MST."
    }
} else {
    Write-Host "Error: No se pudo descargar la archivo MSI."
}
#>
#Ejecutar Archivos Locales

$installerPath = "C:\Users\Administrador\Desktop\SupportAssistBusiness_GobTabasco\SupportAssist\SupportAssistInstaller-x64.msi" # Ruta del instalador MSI
$transformPath = "C:\Users\Administrador\Desktop\SupportAssistBusiness_GobTabasco\SupportAssist\SupportAssistConfiguration.mst" # Ruta del instalador MST
$deploymentToken = "L4r3d2025$" # Token de implementación

# Comando de instalación con token y opciones
$arguments = @(
    "/i", "`"$installerPath`"",             # Ruta del archivo MSI
    "TRANSFORM="`"$transformPath`"",              # Agregar el token
    "DEPLOYMENTKEY=$deploymentToken",              # Agregar el token
    "/quiet",                              # Instalación silenciosa
    "/norestart"                           # Evitar reinicio automático
)
# Ejecutar el instalador con los argumentos
Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait
Write-Host "Instalación de SupportAssist Business completada."
