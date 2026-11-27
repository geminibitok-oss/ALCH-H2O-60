@echo off
setlocal enabledelayedexpansion

:: Check directory
if exist "%~dp0platformio_esp32\platformio.ini" (
    cd /d "%~dp0platformio_esp32"
) else (
    cd /d "%~dp0"
)

echo ===================================================
echo     ESP32 (WROOM/DevKit) Firmware & WebUI Flasher
echo ===================================================

set PIO="%USERPROFILE%\.platformio\penv\Scripts\pio.exe"
if not exist %PIO% (
    set PIO=pio
)

echo.
echo [Step 1/3] Cleaning redundant fonts...
if exist "data\fonts" (
    del /q /f data\fonts\glyphicons-halflings-regular.* 2>nul
    del /q /f data\fonts\glyphicons.svg 2>nul
    del /q /f data\fonts\glyphicons.eot 2>nul
    del /q /f data\fonts\glyphicons.ttf 2>nul
)
if exist "data\js\highstock.js.gz" (
    del /q /f data\js\highstock.js 2>nul
    del /q /f data\js\jquery.min.js 2>nul
    del /q /f data\js\bootstrap.min.js 2>nul
    del /q /f data\css\bootstrap.min.css 2>nul
)

echo.
echo [Step 2/3] Uploading LittleFS Web Interface...
%PIO% run -t uploadfs
if errorlevel 1 (
    echo.
    echo [ERROR] Failed to upload LittleFS filesystem.
    echo Check USB connection and COM port.
    pause
    exit /b 1
)

echo.
echo [Step 3/3] Uploading ESP32 Firmware...
%PIO% run -t upload
if errorlevel 1 (
    echo.
    echo [ERROR] Failed to upload firmware.
    echo If stuck at Connecting..., hold BOOT button (IO0) and press RESET (EN).
    pause
    exit /b 1
)

echo.
echo ===================================================
echo [SUCCESS] ESP32 Flashed Successfully!
echo AP: Alhimik_H2O-60_ESP32 (Pass: 12345678) IP: 192.168.4.1
echo Default UART2 Pins: RX2=GPIO16, TX2=GPIO17
echo ===================================================
pause
