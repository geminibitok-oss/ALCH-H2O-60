@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"

echo ===================================================
echo   Alhimik H2O-60: Flash From GitHub Release
echo   Repo: geminibitok-oss/jucemaker
echo ===================================================
echo.
echo Select target board:
echo   [1] ESP32-C3 (SuperMini / DevKit)
echo   [2] ESP32 Classic (WROOM / DevKit)
echo   [3] ESP32-S3 Display (ESP32-8048S050 5.0 IPS)
echo.

set "CHOICE="
set /p CHOICE="Enter choice [1-3] (default 1): "
if "%CHOICE%"=="" set "CHOICE=1"

if "%CHOICE%"=="1" goto sel_c3
if "%CHOICE%"=="2" goto sel_esp32
if "%CHOICE%"=="3" goto sel_s3
goto sel_c3

:sel_c3
set "CHIP=esp32c3"
set "FLASH_ARGS=--flash_mode dio --flash_freq 40m --flash_size 4MB"
set "F_BOOT=bootloader.bin"
set "F_PART=partitions.bin"
set "F_FW=firmware.bin"
set "F_FS=littlefs.bin"
set "BOOT_OFF=0x0"
set "FS_OFF=0x290000"
set "BOARD_NAME=ESP32-C3"
goto download

:sel_esp32
set "CHIP=esp32"
set "FLASH_ARGS=--flash_mode dio --flash_freq 40m --flash_size 4MB"
set "F_BOOT=esp32_bootloader.bin"
set "F_PART=esp32_partitions.bin"
set "F_FW=esp32_firmware.bin"
set "F_FS=esp32_littlefs.bin"
set "BOOT_OFF=0x1000"
set "FS_OFF=0x290000"
set "BOARD_NAME=ESP32 Classic"
goto download

:sel_s3
set "CHIP=esp32s3"
set "FLASH_ARGS=--flash_mode qio --flash_freq 80m --flash_size 16MB"
set "F_BOOT=esp32s3_display_bootloader.bin"
set "F_PART=esp32s3_display_partitions.bin"
set "F_FW=esp32s3_display_firmware.bin"
set "F_FS=esp32s3_display_littlefs.bin"
set "BOOT_OFF=0x0"
set "FS_OFF=0x610000"
set "BOARD_NAME=ESP32-S3 Display 8048S050"
goto download

:download
set "DOWNLOAD_DIR=%~dp0github_firmware\%CHIP%"
if not exist "%DOWNLOAD_DIR%" mkdir "%DOWNLOAD_DIR%"

echo.
echo [1/3] Downloading %BOARD_NAME% binaries from GitHub...
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $repo = 'geminibitok-oss/jucemaker'; $files = @('%F_BOOT%', '%F_PART%', '%F_FW%', '%F_FS%'); foreach ($f in $files) { Write-Host ('Looking for ' + $f + '...'); $downloaded = $false; $urls = @('https://github.com/' + $repo + '/releases/latest/download/' + $f, 'https://raw.githubusercontent.com/' + $repo + '/release-binaries/' + $f, 'https://raw.githubusercontent.com/' + $repo + '/main/release_binaries/' + $f); foreach ($url in $urls) { try { Invoke-WebRequest -Uri $url -OutFile ('%DOWNLOAD_DIR%\' + $f) -UseBasicParsing -ErrorAction Stop; if ((Get-Item ('%DOWNLOAD_DIR%\' + $f)).Length -gt 512) { Write-Host ('  [OK] Downloaded ' + $f); $downloaded = $true; break } } catch {} }; if (-not $downloaded) { Write-Host ('  [WARN] Could not find ' + $f) } }"

if not exist "%DOWNLOAD_DIR%\%F_FW%" (
    echo.
    echo [ERROR] Firmware file %F_FW% not found on GitHub!
    echo Run GitHub Actions or "python publish_release.py" first.
    pause
    exit /b 1
)

echo.
echo [2/3] Locating esptool...
set "ESPTOOL=%USERPROFILE%\.platformio\penv\Scripts\esptool.exe"
if not exist "%ESPTOOL%" set "ESPTOOL=%~dp0firmware_cache\esptool_pkg\esptool-win64\esptool.exe"
if not exist "%ESPTOOL%" set "ESPTOOL=esptool.py"

echo.
echo [3/3] Flashing %BOARD_NAME%...
"%ESPTOOL%" --chip %CHIP% --baud 460800 write_flash %FLASH_ARGS% -z %BOOT_OFF% "%DOWNLOAD_DIR%\%F_BOOT%" 0x8000 "%DOWNLOAD_DIR%\%F_PART%" 0x10000 "%DOWNLOAD_DIR%\%F_FW%" %FS_OFF% "%DOWNLOAD_DIR%\%F_FS%"

if errorlevel 1 (
    echo.
    echo [ERROR] Flashing failed. Check USB cable, COM port, and BOOT button.
) else (
    echo.
    echo [SUCCESS] %BOARD_NAME% flashed successfully from GitHub!
)

echo.
pause
