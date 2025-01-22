@echo off
TITLE Bienvenid@ %USERNAME% - Menu
MODE 120, 50

:inicio
COLOR 1F
SET var=0
cls
echo ===================================
echo   MENU
echo ===================================
echo   1. Desinstalar SupportAssist  
echo   2. Instalar SupportAssist for Home PCs  
echo   3. Opcion 3  
echo   4. Opcion 4  
echo   5. Limpiar Archivos Temporales  
echo   6. Salir
echo ----------------------
echo.

SET /p var= ^> Seleccione una opcion [1-6]:

if "%var%"=="0" goto inicio
if "%var%"=="1" goto op1
if "%var%"=="2" goto op2
if "%var%"=="3" goto op3
if "%var%"=="4" goto op4
if "%var%"=="5" goto op5
if "%var%"=="6" goto salir

::Mensaje de error, validación cuando se selecciona una opción fuera de rango
echo. El numero "%var%" no es una opcion valida, por favor intente de nuevo.
echo.
pause
echo.
goto:inicio

:op1
    echo.
    echo. Has elegido la opcion No. 1 [Desinstalar SupportAssist]
    echo.
    ::Aquí van las líneas de comando de tu opción
    echo Iniciando Desinstalacion
         powershell -Command "iwr -useb https://raw.githubusercontent.com/SoporteLaRed/PowerShell/refs/heads/main/DeleteSupportAssist.ps1 | iex"	
    echo.
    pause
    goto:inicio

:op2
    echo.
    echo. Has elegido la opcion No. 2 [Instalar SupportAssist for Home PCs]
    echo.
        ::Aquí van las líneas de comando de tu opción
         powershell -Command "iwr -useb https://raw.githubusercontent.com/SoporteLaRed/PowerShell/refs/heads/main/DownInstall.ps1 | iex"
    echo.
    pause
    goto:inicio

:op3
    echo.
    echo. Has elegido la opcion No. 3
    echo.
        ::Aquí van las líneas de comando de tu opción
        color 0A
    echo.
    pause
    goto:inicio
  
:op4
    echo.
    echo. Has elegido la opcion No. 4
    echo.
        ::Aquí van las líneas de comando de tu opción
        color 0B
    echo.
    pause
    goto:inicio

:op5
    echo.
    echo. Has elegido la opcion No. 5
    echo.
        ::Aquí van las líneas de comando de tu opción
        powershell -Command "iwr -useb https://raw.githubusercontent.com/SoporteLaRed/PowerShell/refs/heads/main/CleanTemp.ps1 | iex"
    echo.
    pause
    goto:inicio

:salir
    @cls&exit
