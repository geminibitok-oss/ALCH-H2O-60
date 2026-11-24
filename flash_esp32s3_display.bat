@echo off
echo ===================================================
echo    Alhimik H2O-60 ESP32-S3 Display (8048S050) Flasher
echo ===================================================
echo.
set ESPTOOL="%USERPROFILE%\.platformio\penv\Scripts\esptool.py.exe"
if not exist %ESPTOOL% set ESPTOOL="%USERPROFILE%\.platformio\penv\Scripts\esptool.exe"
if not exist %ESPTOOL% set ESPTOOL=esptool.py
%ESPTOOL% --chip esp32s3 write_flash --flash_mode qio --flash_freq 80m --flash_size 16MB -z 0x0 esp32s3_display_bootloader.bin 0x8000 esp32s3_display_partitions.bin 0x10000 esp32s3_display_firmware.bin 0x610000 esp32s3_display_littlefs.bin
pause
