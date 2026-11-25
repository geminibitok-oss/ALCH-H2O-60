@echo off
setlocal enabledelayedexpansion

:: Check directory
if exist "%~dp0platformio_mega2560\platformio.ini" (
    cd /d "%~dp0platformio_mega2560"
) else (
    cd /d "%~dp0"
)

echo ===================================================
echo     Arduino Mega 2560 Flasher (Alhimik H2O-60)
echo ===================================================

set PIO="%USERPROFILE%\.platformio\penv\Scripts\pio.exe"
if not exist %PIO% (
    set PIO=pio
)

echo.
echo Compiling and uploading to Arduino Mega 2560...
%PIO% run -t upload
if errorlevel 1 (
    echo.
    echo [ERROR] Failed to upload to Arduino Mega 2560.
    echo Check USB connection and COM port.
    pause
    exit /b 1
)

echo.
echo ===================================================
echo [SUCCESS] Arduino Mega 2560 Flashed Successfully!
echo ===================================================
pause
