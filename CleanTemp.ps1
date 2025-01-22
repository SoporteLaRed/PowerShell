# Directorios comunes de archivos temporales
$TempPaths = @(
    "$env:Temp",               # Carpeta temporal del usuario actual
    "$env:WinDir\Temp",        # Carpeta temporal de Windows
    "$env:LocalAppData\Temp"   # Carpeta temporal adicional del usuario actual
)

# Función para eliminar archivos temporales
function Eliminar-ArchivosTemporales {
    param (
        [string[]]$Paths
    )

    foreach ($Path in $Paths) {
        if (Test-Path $Path) {
            Write-Host "Limpiando archivos temporales en: $Path"
            try {
                # Eliminar archivos
                Get-ChildItem -Path $Path -File -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
                
                # Eliminar carpetas vacías
                Get-ChildItem -Path $Path -Directory -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                
                Write-Host "Limpieza completada en: $Path"
            } catch {
                Write-Warning "No se pudo limpiar $Path"
            }
        } else {
            Write-Warning "El directorio $Path no existe."
        }
    }
}

# Ejecutar la función para las rutas especificadas
Eliminar-ArchivosTemporales -Paths $TempPaths

Write-Host "Limpieza de archivos temporales finalizada."
