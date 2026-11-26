@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
title Alhimik H2O-60 Auto Flasher
cd /d "%~dp0"

set "FW_DIR=%~dp0firmware_cache"
if not exist "%FW_DIR%" mkdir "%FW_DIR%"

echo ===================================================================
echo     Алхимик H₂O-60 Firmware Flasher
echo     Repository: github.com/geminibitok-oss/ALCH-H2O-60
echo ===================================================================
echo.

:sync_files
echo [1/2] Syncing latest firmware from GitHub (geminibitok-oss/ALCH-H2O-60)...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$sources = @('https://github.com/geminibitok-oss/ALCH-H2O-60/releases/latest/download', 'https://raw.githubusercontent.com/geminibitok-oss/ALCH-H2O-60/release-binaries', 'https://raw.githubusercontent.com/geminibitok-oss/ALCH-H2O-60/main/release_binaries');" ^
    "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;" ^
    "$wc = New-Object System.Net.WebClient;" ^
    "$wc.Headers.Add('User-Agent','Mozilla/5.0');" ^
    "$remVer = ''; foreach($s in $sources) { if(-not $remVer) { try { $remVer = $wc.DownloadString($s + '/version.txt').Trim() } catch {} } };" ^
    "$locVer = if (Test-Path '%FW_DIR%\version.txt') { (Get-Content '%FW_DIR%\version.txt' -Raw).Trim() } else { '' };" ^
    "if ($remVer -and ($remVer -ne $locVer)) {" ^
    "    Write-Host ('[INFO] New version available on GitHub: ' + $remVer) -ForegroundColor Cyan;" ^
    "    Remove-Item '%FW_DIR%\*.bin','%FW_DIR%\*.hex' -Force -ErrorAction SilentlyContinue;" ^
    "    [System.IO.File]::WriteAllText('%FW_DIR%\version.txt', $remVer);" ^
    "};" ^
    "$files = @('bootloader.bin','partitions.bin','firmware.bin','littlefs.bin','esp32_bootloader.bin','esp32_partitions.bin','esp32_firmware.bin','esp32_littlefs.bin','esp32s3_display_bootloader.bin','esp32s3_display_partitions.bin','esp32s3_display_firmware.bin','esp32s3_display_littlefs.bin','mega2560_firmware.hex');" ^
    "foreach($f in $files) {" ^
    "    $dst = Join-Path '%FW_DIR%' $f;" ^
    "    if (-not (Test-Path $dst)) {" ^
    "        Write-Host ('  Downloading ' + $f + '...') -ForegroundColor Yellow;" ^
    "        $ok = $false; foreach($s in $sources) { if(-not $ok) { try { $wc.DownloadFile($s + '/' + $f, $dst); if((Get-Item $dst).Length -gt 512) { $ok = $true; Write-Host ('  [OK] ' + $f) -ForegroundColor Green } } catch {} } };" ^
    "        if (-not $ok) { Remove-Item $dst -Force -ErrorAction SilentlyContinue; Write-Host ('  [WARN] Not found: ' + $f) -ForegroundColor DarkYellow }" ^
    "    } else {" ^
    "        Write-Host ('  [OK] ' + $f + ' (cached)') -ForegroundColor Green" ^
    "    }" ^
    "}"

set "VERSION=latest"
if exist "%FW_DIR%\version.txt" set /p VERSION=<"%FW_DIR%\version.txt"

:menu
cls
echo ===================================================================
echo     Alhimik H2O-60 Flasher - Version: %VERSION%
echo     Repo: geminibitok-oss/ALCH-H2O-60
echo ===================================================================
echo.
echo Select action:
echo.
echo   --- ESP32-C3 (SuperMini / DevKit) ---
echo   [1] Flash ESP32-C3 COMPLETE (Boot + Partitions + Firmware + Web)
echo   [2] Flash ESP32-C3 LittleFS ONLY (Web Interface)
echo   [3] Flash ESP32-C3 Firmware ONLY (C++ Code)
echo.
echo   --- ESP32-8048S050 (5.0" IPS Display, ESP32-S3) ---
echo   [4] Flash ESP32-S3 Display COMPLETE (Boot + Part + FW + Web)
echo   [5] Flash ESP32-S3 Display Firmware ONLY
echo   [6] Flash ESP32-S3 Display LittleFS ONLY
echo.
echo   --- ESP32 Classic & Arduino Mega 2560 ---
echo   [7] Flash ESP32 Classic COMPLETE (Boot + Part + FW + Web)
echo   [8] Flash Arduino Mega 2560 ONLY (mega2560_firmware.hex)
echo.
echo   --- Tools ---
echo   [9] Serial Monitor (115200 baud)
echo   [R] Force Redownload from GitHub (Clear Cache)
echo   [0] Exit
echo.

choice /c 123456789R0 /n /m "Press key [0-9, R]: "
if errorlevel 11 goto end
if errorlevel 10 goto redownload
if errorlevel 9 goto serial_monitor
if errorlevel 8 goto flash_mega
if errorlevel 7 goto flash_esp32_full
if errorlevel 6 goto flash_s3_web
if errorlevel 5 goto flash_s3_fw
if errorlevel 4 goto flash_s3_full
if errorlevel 3 goto flash_c3_fw
if errorlevel 2 goto flash_c3_web
if errorlevel 1 goto flash_c3_full

goto menu

:redownload
echo.
echo Clearing firmware cache and redownloading...
del /q "%FW_DIR%\*.bin" "%FW_DIR%\*.hex" "%FW_DIR%\version.txt" >nul 2>nul
goto sync_files

:detect_ports
echo.
echo Detecting COM ports...
set "DETECTED_PORT="
for /f "usebackq delims=" %%P in (`powershell -NoProfile -Command "$p = [System.IO.Ports.SerialPort]::GetPortNames() | Where-Object { $_ -ne 'COM1' } | Select-Object -First 1; if(-not $p){ $p = [System.IO.Ports.SerialPort]::GetPortNames() | Select-Object -First 1 }; $p"`) do set "DETECTED_PORT=%%P"
if defined DETECTED_PORT (
    set "DEFAULT_PORT=%DETECTED_PORT%"
) else (
    set "DEFAULT_PORT=COM3"
)
echo Available port: %DEFAULT_PORT%
set "PORT="
set /p PORT="Enter COM port (press Enter for %DEFAULT_PORT%): "
if "%PORT%"=="" set "PORT=%DEFAULT_PORT%"
echo Using port: %PORT%
echo.
exit /b 0

:find_esptool
set "ESPTOOL="
if exist "%FW_DIR%\esptool_pkg\esptool-win64\esptool.exe" set "ESPTOOL=%FW_DIR%\esptool_pkg\esptool-win64\esptool.exe"
if not defined ESPTOOL if exist "%USERPROFILE%\.platformio\penv\Scripts\esptool.exe" set "ESPTOOL=%USERPROFILE%\.platformio\penv\Scripts\esptool.exe"
if not defined ESPTOOL (
    where esptool.py >nul 2>nul
    if not errorlevel 1 set "ESPTOOL=esptool.py"
)
if not defined ESPTOOL (
    echo [INFO] Downloading official esptool flasher...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('https://github.com/espressif/esptool/releases/download/v4.7.0/esptool-v4.7.0-win64.zip', '%FW_DIR%\esptool.zip'); Expand-Archive -Path '%FW_DIR%\esptool.zip' -DestinationPath '%FW_DIR%\esptool_pkg' -Force; Remove-Item '%FW_DIR%\esptool.zip' -Force" >nul 2>nul
    if exist "%FW_DIR%\esptool_pkg\esptool-win64\esptool.exe" (
        set "ESPTOOL=%FW_DIR%\esptool_pkg\esptool-win64\esptool.exe"
    )
)
if not defined ESPTOOL (
    echo [ERROR] Could not find or download esptool flasher.
    pause
    goto menu
)
exit /b 0

:find_avrdude
set "AVRDUDE="
set "AVRCONF="
if exist "%USERPROFILE%\.platformio\packages\tool-avrdude\bin\avrdude.exe" (
    set "AVRDUDE=%USERPROFILE%\.platformio\packages\tool-avrdude\bin\avrdude.exe"
    set "AVRCONF=%USERPROFILE%\.platformio\packages\tool-avrdude\etc\avrdude.conf"
)
if not defined AVRDUDE (
    where avrdude >nul 2>nul
    if not errorlevel 1 set "AVRDUDE=avrdude"
)
if not defined AVRDUDE (
    echo [INFO] Downloading official avrdude for Arduino Mega 2560...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('https://github.com/avrdudes/avrdude/releases/download/v7.2/avrdude-v7.2-windows-x64.zip', '%FW_DIR%\avrdude.zip'); Expand-Archive -Path '%FW_DIR%\avrdude.zip' -DestinationPath '%FW_DIR%\avrdude_pkg' -Force; Remove-Item '%FW_DIR%\avrdude.zip' -Force" >nul 2>nul
    if exist "%FW_DIR%\avrdude_pkg\avrdude.exe" (
        set "AVRDUDE=%FW_DIR%\avrdude_pkg\avrdude.exe"
        if exist "%FW_DIR%\avrdude_pkg\avrdude.conf" set "AVRCONF=%FW_DIR%\avrdude_pkg\avrdude.conf"
    )
)
if not defined AVRDUDE (
    echo [ERROR] Could not find or download avrdude flasher.
    pause
    goto menu
)
exit /b 0

:flash_c3_full
call :find_esptool
call :detect_ports
echo.
echo Flashing ESP32-C3 COMPLETE on %PORT%...
"%ESPTOOL%" --chip esp32c3 --port %PORT% --baud 460800 write_flash --flash_mode dio --flash_freq 40m --flash_size 4MB -z 0x0 "%FW_DIR%\bootloader.bin" 0x8000 "%FW_DIR%\partitions.bin" 0x10000 "%FW_DIR%\firmware.bin" 0x290000 "%FW_DIR%\littlefs.bin"
echo.
if errorlevel 1 (echo [ERROR] Flashing failed.) else (echo [SUCCESS] ESP32-C3 flashed!)
pause
goto menu

:flash_c3_web
call :find_esptool
call :detect_ports
echo.
echo Flashing ESP32-C3 LittleFS on %PORT%...
"%ESPTOOL%" --chip esp32c3 --port %PORT% --baud 460800 write_flash -z 0x290000 "%FW_DIR%\littlefs.bin"
echo.
if errorlevel 1 (echo [ERROR] Flashing LittleFS failed.) else (echo [SUCCESS] Web interface updated!)
pause
goto menu

:flash_c3_fw
call :find_esptool
call :detect_ports
echo.
echo Flashing ESP32-C3 Firmware on %PORT%...
"%ESPTOOL%" --chip esp32c3 --port %PORT% --baud 460800 write_flash --flash_mode dio --flash_freq 40m -z 0x10000 "%FW_DIR%\firmware.bin"
echo.
if errorlevel 1 (echo [ERROR] Flashing firmware failed.) else (echo [SUCCESS] C++ firmware updated!)
pause
goto menu

:flash_s3_full
call :find_esptool
call :detect_ports
echo.
echo Flashing ESP32-S3 Display 8048S050 COMPLETE on %PORT%...
"%ESPTOOL%" --chip esp32s3 --port %PORT% --baud 921600 write_flash --flash_mode qio --flash_freq 80m --flash_size 16MB -z 0x0 "%FW_DIR%\esp32s3_display_bootloader.bin" 0x8000 "%FW_DIR%\esp32s3_display_partitions.bin" 0x10000 "%FW_DIR%\esp32s3_display_firmware.bin" 0x610000 "%FW_DIR%\esp32s3_display_littlefs.bin"
echo.
if errorlevel 1 (echo [ERROR] Flashing ESP32-S3 Display failed.) else (echo [SUCCESS] ESP32-S3 Display flashed!)
pause
goto menu

:flash_s3_fw
call :find_esptool
call :detect_ports
echo.
echo Flashing ESP32-S3 Display Firmware on %PORT%...
"%ESPTOOL%" --chip esp32s3 --port %PORT% --baud 921600 write_flash --flash_mode qio --flash_freq 80m -z 0x10000 "%FW_DIR%\esp32s3_display_firmware.bin"
echo.
if errorlevel 1 (echo [ERROR] Flashing ESP32-S3 Firmware failed.) else (echo [SUCCESS] ESP32-S3 Display Firmware updated!)
pause
goto menu

:flash_s3_web
call :find_esptool
call :detect_ports
echo.
echo Flashing ESP32-S3 Display LittleFS on %PORT%...
"%ESPTOOL%" --chip esp32s3 --port %PORT% --baud 921600 write_flash -z 0x610000 "%FW_DIR%\esp32s3_display_littlefs.bin"
echo.
if errorlevel 1 (echo [ERROR] Flashing ESP32-S3 LittleFS failed.) else (echo [SUCCESS] ESP32-S3 Display Web Interface updated!)
pause
goto menu

:flash_esp32_full
call :find_esptool
call :detect_ports
echo.
echo Flashing ESP32 Classic COMPLETE on %PORT%...
"%ESPTOOL%" --chip esp32 --port %PORT% --baud 460800 write_flash --flash_mode dio --flash_freq 40m --flash_size 4MB -z 0x1000 "%FW_DIR%\esp32_bootloader.bin" 0x8000 "%FW_DIR%\esp32_partitions.bin" 0x10000 "%FW_DIR%\esp32_firmware.bin" 0x290000 "%FW_DIR%\esp32_littlefs.bin"
echo.
if errorlevel 1 (echo [ERROR] Flashing ESP32 Classic failed.) else (echo [SUCCESS] ESP32 Classic flashed!)
pause
goto menu

:flash_mega
call :find_avrdude
call :detect_ports
echo.
echo Flashing Arduino Mega 2560 on %PORT%...
set "CONF_FLAG="
if defined AVRCONF set "CONF_FLAG=-C "%AVRCONF%""
"%AVRDUDE%" %CONF_FLAG% -v -p atmega2560 -c wiring -P %PORT% -b 115200 -D -U flash:w:"%FW_DIR%\mega2560_firmware.hex":i
echo.
if errorlevel 1 (echo [ERROR] Flashing Arduino Mega 2560 failed.) else (echo [SUCCESS] Arduino Mega 2560 flashed!)
pause
goto menu

:serial_monitor
call :detect_ports
echo.
echo Serial Monitor on %PORT% (115200 baud) - Press Ctrl+C to exit
if exist "%USERPROFILE%\.platformio\penv\Scripts\python.exe" (
    "%USERPROFILE%\.platformio\penv\Scripts\python.exe" -m serial.tools.miniterm %PORT% 115200
    pause
    goto menu
)
powershell -NoProfile -Command "$p = New-Object System.IO.Ports.SerialPort '%PORT%', 115200; $p.DtrEnable = $true; $p.RtsEnable = $true; $p.Open(); Write-Host '--- Monitor Connected ---' -ForegroundColor Green; while($true){ if($p.BytesToRead -gt 0){ [Console]::Write($p.ReadExisting()) } Start-Sleep -Milliseconds 50 }"
pause
goto menu

:end
echo.
echo Closing flasher...
exit /b 0
