# Directorios comunes de archivos temporales
$TempPaths = @(
    "$env:Temp",                           # Carpeta temporal del usuario actual
    "$env:WinDir\Temp"                     # Carpeta temporal de Windows
)

# Función para eliminar archivos y carpetas temporales
function Limpiar-ArchivosTemporales {
    param (
        [string[]]$Paths
    )

    foreach ($Path in $Paths) {
        if (Test-Path $Path) {
            Write-Host "Limpiando $Path..."
            
            # Intenta eliminar archivos
            try {
                Get-ChildItem -Path $Path -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "Archivos temporales eliminados en: $Path"
            } catch {
                Write-Warning "No se pudo limpiar $Path: $_"
            }
        } else {
            Write-Warning "El directorio $Path no existe."
        }
    }
}

# Ejecutar la función con las rutas especificadas
Limpiar-ArchivosTemporales -Paths $TempPaths

Write-Host "Limpieza de archivos temporales completada."