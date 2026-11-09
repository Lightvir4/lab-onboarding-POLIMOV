@echo off
chcp 65001 > nul
setlocal EnableExtensions EnableDelayedExpansion

REM Практическая работа 8. Диагностика и аудит клиентского компьютера.
set "SCRIPT_DIR=%~dp0"
set "REPORT=%SCRIPT_DIR%pc_report.txt"
set "APPS=%TEMP%\lab_onboarding_apps_%RANDOM%.txt"
set /a RECOMMENDATIONS=0
> "%REPORT%" echo.

call :log "Диагностика клиентского компьютера"
call :log "Дата и время: %DATE% %TIME%"
call :log "============================================================"

REM Операционная система
set "OS_NAME="
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).Caption"`) do set "OS_NAME=%%A"
if defined OS_NAME (call :log "Операционная система: !OS_NAME!") else (call :log "Операционная система: данные получить не удалось")

REM Процессор
set "CPU_NAME="
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "(Get-CimInstance Win32_Processor ^| Select-Object -First 1 -ExpandProperty Name)"`) do set "CPU_NAME=%%A"
if defined CPU_NAME (call :log "Процессор: !CPU_NAME!") else (call :log "Процессор: данные получить не удалось")

REM Память и диск: вычисление выполняется PowerShell, чтобы избежать переполнения set /a.
for /f "tokens=1,2" %%A in ('powershell -NoProfile -Command "$o=Get-CimInstance Win32_OperatingSystem; [math]::Round($o.TotalVisibleMemorySize/1MB),[math]::Round($o.FreePhysicalMemory/1MB)"') do (set "MEM_TOTAL=%%A" & set "MEM_FREE=%%B")
if defined MEM_TOTAL (call :log "Память: всего !MEM_TOTAL! ГБ, свободно !MEM_FREE! ГБ") else (call :log "Память: данные получить не удалось")
for /f "tokens=1,2" %%A in ('powershell -NoProfile -Command "$d=Get-CimInstance Win32_LogicalDisk -Filter \"DeviceID='C:'\"; [math]::Round($d.Size/1GB),[math]::Round($d.FreeSpace/1GB)"') do (set "DISK_TOTAL=%%A" & set "DISK_FREE=%%B")
if defined DISK_TOTAL (call :log "Диск C: всего !DISK_TOTAL! ГБ, свободно !DISK_FREE! ГБ") else (call :log "Диск C: данные получить не удалось")

call :log ""
call :log "Идет поиск установленных программ..."
> "%APPS%" (
  reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr /i "DisplayName"
  reg query "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /v DisplayName 2^>nul ^| findstr /i "DisplayName"
)
for /f "tokens=2,*" %%A in ('findstr /i "DisplayName" "%APPS%"') do echo %%B>> "%APPS%.names"
sort /unique "%APPS%.names" > "%APPS%"
del "%APPS%.names" 2>nul
call :log "Установленные программы:"
for /f "usebackq delims=" %%A in ("%APPS%") do call :log "  %%A"

call :log ""
call :log "Проверка базового ПО:"
call :check_required "Офисный пакет" "Office LibreOffice OpenOffice МойОфис"
call :check_required "Браузер" "Chrome Firefox Edge Яндекс"
call :check_required "PDF-просмотрщик" "Acrobat Foxit SumatraPDF"
call :check_required "Архиватор" "7-Zip WinRAR WinZip"
call :check_required "Антивирус" "Defender Kaspersky ESET Dr.Web"

call :log ""
call :log "ПО, не относящееся к базовым офисным задачам:"
call :check_optional "Игровое ПО" "Steam Epic GOG Origin Ubisoft Battle.net Riot game gaming"
call :check_optional "Торрент-клиенты" "torrent uTorrent BitTorrent qBittorrent Vuze"
call :check_optional "Личные мессенджеры" "Discord Telegram WhatsApp Viber Skype"
call :check_optional "Развлечения и оформление" "Wallpaper OBS Soundpad"
call :log "Все найденные элементы являются рекомендациями к проверке, а не указанием к удалению."
call :log ""
call :log "Итог: выдано рекомендаций: !RECOMMENDATIONS!. Отчет: %REPORT%"
del "%APPS%" 2>nul
pause
exit /b

:check_required
set "LABEL=%~1"
set "WORDS=%~2"
set "FOUND="
for %%W in (%WORDS%) do if not defined FOUND for /f "usebackq delims=" %%A in (`findstr /i /m /c:"%%W" "%APPS%"`) do set "FOUND=%%A"
if defined FOUND (call :log "[OK] !LABEL!: найдено !FOUND!") else (set /a RECOMMENDATIONS+=1 & call :log "[ПРОВЕРИТЬ] !LABEL!: не обнаружен; рекомендуется установить согласованный корпоративный инструмент.")
exit /b

:check_optional
set "LABEL=%~1"
set "WORDS=%~2"
set "FOUND="
for %%W in (%WORDS%) do for /f "usebackq delims=" %%A in (`findstr /i /c:"%%W" "%APPS%"`) do set "FOUND=%%A"
if defined FOUND (set /a RECOMMENDATIONS+=1 & call :log "[ПРОВЕРИТЬ] !LABEL!: !FOUND!") else (call :log "[OK] !LABEL!: не обнаружено")
exit /b

:log
if "%~1"=="" (echo(&>>"%REPORT%" echo() else (echo %~1&>>"%REPORT%" echo %~1)
exit /b
