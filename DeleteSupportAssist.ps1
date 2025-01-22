# Función para desinstalar Dell SupportAssist
function Eliminar-DellSupportAssist {
    Write-Host " Buscando Dell SupportAssist en el sistema..." -ForegroundColor Cyan

    # Buscar el producto por nombre en programas instalados
    $SupportAssist = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*SupportAssist*" }

    if ($SupportAssist) {
        Write-Host " Se encontro Dell SupportAssist. Procediendo con la desinstalacion..." -ForegroundColor Green

        # Intentar desinstalar el programa
        try {
            $SupportAssist.Uninstall()
            Write-Host " Dell SupportAssist fue desinstalado exitosamente." -ForegroundColor Green
        } catch {
            Write-Warning " Hubo un error durante la desinstalacion: $_"
        }
    } else {
        Write-Warning " Dell SupportAssist no esta instalado en este sistema."
    }
}

# Ejecutar la función
Eliminar-DellSupportAssist
