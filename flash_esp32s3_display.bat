@echo off
setlocal enabledelayedexpansion

:: Check directory
if exist "%~dp0platformio_esp32s3_display\platformio.ini" (
    cd /d "%~dp0platformio_esp32s3_display"
) else (
    cd /d "%~dp0"
)

echo ===================================================
echo     ESP32-S3 Display 5" (8048S050) Flasher
echo ===================================================

set PIO="%USERPROFILE%\.platformio\penv\Scripts\pio.exe"
if not exist %PIO% (
    set PIO=pio
)

echo.
echo [Step 1/2] Uploading LittleFS Web Interface...
%PIO% run -t uploadfs
if errorlevel 1 (
    echo.
    echo [ERROR] Failed to upload LittleFS filesystem.
    echo Check USB connection and COM port.
    pause
    exit /b 1
)

echo.
echo [Step 2/2] Uploading ESP32-S3 Display Firmware...
%PIO% run -t upload
if errorlevel 1 (
    echo.
    echo [ERROR] Failed to upload firmware.
    echo Hold BOOT and press RESET if port does not enter bootloader.
    pause
    exit /b 1
)

echo.
echo ===================================================
echo [SUCCESS] ESP32-S3 Display Flashed Successfully!
echo AP: Alhimik_H2O-60_S3 (Pass: 12345678) IP: 192.168.4.1
echo ===================================================
pause
