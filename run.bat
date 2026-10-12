@echo off
:: Opens DOSBox with TASM already set up, builds the interrupts and the game
:: (game.bat) and runs it. Nothing gets installed: everything lives in tools\.
setlocal
cd /d "%~dp0"

if not exist "tools\dosbox\DOSBox.exe" (
    echo tools\dosbox\DOSBox.exe not found.
    echo Clone the full repo or download the ZIP from GitHub.
    pause
    exit /b 1
)
if not exist "tools\tasm\TASM.EXE" (
    echo tools\tasm\TASM.EXE not found.
    pause
    exit /b 1
)

start "" "tools\dosbox\DOSBox.exe" -conf "dosbox.conf" -noconsole
