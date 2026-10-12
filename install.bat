@echo off
:: Abre DOSBox con TASM ya configurado, compila las interrupciones y el juego
:: (game.bat) y lo ejecuta. No instala nada en el sistema: todo esta en tools\.
setlocal
cd /d "%~dp0"

if not exist "tools\dosbox\DOSBox.exe" (
    echo No se encontro tools\dosbox\DOSBox.exe
    echo Clona el repo completo o descarga el ZIP desde GitHub.
    pause
    exit /b 1
)
if not exist "tools\tasm\TASM.EXE" (
    echo No se encontro tools\tasm\TASM.EXE
    pause
    exit /b 1
)

start "" "tools\dosbox\DOSBox.exe" -conf "dosbox.conf" -noconsole
