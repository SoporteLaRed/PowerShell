@echo off
:: Verifica si el script se está ejecutando como administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    ECHO El script necesita ejecutarse como administrador.
    pause
    :: Relanzar el script como administrador
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
:: Continuar con el resto del script
ECHO El script se está ejecutando como administrador.
pause
cls
COLOR 1F
ECHO Bienvenido a la instalacion de SupportAssistBusiness
powershell -Command "iwr -useb https://raw.githubusercontent.com/SoporteLaRed/PowerShell/refs/heads/main/FullInstall.ps1 | iex"
pause
@cls&exit
