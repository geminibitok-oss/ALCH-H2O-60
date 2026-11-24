# Алхимик H₂O-60 — Готовые прошивки (.bin / .hex) и Android (.apk / .aab)

Автоматическое зеркало скомпилированных бинарных файлов из основного сборочного конвейера (`geminibitok-oss/jucemaker`).

**Актуальная версия:** `v8.0.5`

---

## 📱 Мобильное приложение Android
* **`BuhlovarkaControl.apk`** — Установочный пакет для прямой установки на смартфон / планшет Android.
* **`BuhlovarkaControl.aab`** — Пакет Android App Bundle для публикации в Google Play / RuStore.

---

## ⚡ Бинарные файлы прошивок микроконтроллеров

| Файл | Назначение | Плата |
| :--- | :--- | :--- |
| **`firmware.bin`** | Основная прошивка моста Wi-Fi / Web / MQTT / Telegram | **ESP32-C3** |
| **`littlefs.bin`** | Файловая система LittleFS с веб-интерфейсом (`0x290000`) | **ESP32-C3** |
| **`bootloader.bin`** / **`partitions.bin`** | Загрузчик и таблица разделов | **ESP32-C3** |
| **`esp32_firmware.bin`** | Основная прошивка микроконтроллера | **ESP32 Classic (WROOM / DevKit)** |
| **`esp32_littlefs.bin`** | Файловая система LittleFS с веб-интерфейсом (`0x290000`) | **ESP32 Classic** |
| **`esp32_bootloader.bin`** / **`esp32_partitions.bin`** | Загрузчик и таблица разделов | **ESP32 Classic** |
| **`esp32s3_display_firmware.bin`** | Прошивка сенсорного дисплея 5" IPS 800×480 | **ESP32-8048S050 (ESP32-S3)** |
| **`esp32s3_display_littlefs.bin`** | Файловая система LittleFS с веб-интерфейсом (`0x610000`) | **ESP32-8048S050 (ESP32-S3)** |
| **`esp32s3_display_bootloader.bin`** / **`esp32s3_display_partitions.bin`** | Загрузчик и таблица разделов | **ESP32-8048S050 (ESP32-S3)** |
| **`mega2560_firmware.hex`** | Прошивка силовой автоматики | **Arduino Mega 2560** |

---

## 🔧 Быстрая прошивка по USB (Windows)
Скачайте архив релиза (или склонируйте этот репозиторий) и запустите `auto_flash_buhlovarka.bat` либо скрипт под вашу плату (`flash_esp32c3.bat`, `flash_esp32_classic.bat`, `flash_esp32s3_display.bat`, `flash_mega.bat`).
