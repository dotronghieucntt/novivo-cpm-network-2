@echo off
setlocal EnableExtensions

REM Khong bat buoc Administrator: app + tunnel chay bang user hien tai.
REM Chi nut "Stop Windows service" trong GUI moi can mo lai bang Administrator.

REM NOVIVO CPM Network launcher
REM Chi mo Watchdog GUI cua dung project nay.
REM Watchdog GUI tu start FE/BE Next.js tren port 3016 va tunnel network.novivo.net sau 3 giay.

set "PROJECT_DIR=%~dp0cpm-network-platform"
set "WATCHDOG_SCRIPT=%PROJECT_DIR%\tools\watchdog_manager.py"

REM Config tunnel nam trong project (khong dung %TEMP%): may nay chay nhieu
REM project qua cloudflared nen moi project phai co file config rieng, co dinh.
set "WATCHDOG_CONFIG=%PROJECT_DIR%\.cloudflared\cpm-network.yml"

REM Ten hien tren tray icon + title cua so. May nay chay NHIEU watchdog song song
REM nen moi project phai dat mot label rieng de khong bi nhin lan nhau.
set "WATCHDOG_LABEL=CPM Network"

if not exist "%WATCHDOG_SCRIPT%" (
  echo Watchdog script not found: %WATCHDOG_SCRIPT%
  pause
  exit /b 1
)

cd /d "%PROJECT_DIR%"

REM Mark process environment so this launcher belongs to NOVIVO Network only.
set "NOVIVO_PROJECT_DIR=%PROJECT_DIR%"
set "NOVIVO_WATCHDOG_CONFIG=%WATCHDOG_CONFIG%"
set "NOVIVO_WATCHDOG_LABEL=%WATCHDOG_LABEL%"
set "NOVIVO_DOMAIN=network.novivo.net"
set "NOVIVO_PORT=3016"

REM ---------------------------------------------------------------------------
REM AN CONSOLE: uu tien wscript + run_hidden.vbs.
REM Truoc day cho nay goi powershell -Command "Start-Process ...". PowerShell mat
REM ~1 giay de khoi dong nen cua so CMD den cua run.bat nhap nhay ro rang.
REM wscript.exe chay gan nhu tuc thi -> gan nhu khong kip thay gi.
REM Muon KHONG nhap nhay MOT CHUT NAO: double-click thang
REM   cpm-network-platform\tools\run_hidden.vbs
REM (file .bat bat buoc phai co console, .vbs thi khong.)
REM ---------------------------------------------------------------------------
set "WATCHDOG_VBS=%PROJECT_DIR%\tools\run_hidden.vbs"
set "WATCHDOG_ERROR_LOG=%PROJECT_DIR%\.cloudflared\watchdog-launch-error.log"
if not exist "%PROJECT_DIR%\.cloudflared" mkdir "%PROJECT_DIR%\.cloudflared"

if exist "%WATCHDOG_VBS%" (
  start "" /b wscript.exe //nologo "%WATCHDOG_VBS%"
  exit /b 0
)

REM Fallback 1: pythonw truc tiep (van khong co console vi pythonw khong tao console).
where pythonw >nul 2>nul
if %errorlevel%==0 (
  start "" /b pythonw.exe "%WATCHDOG_SCRIPT%"
  exit /b 0
)

REM Fallback 2: python qua PowerShell an cua so.
where python >nul 2>nul
if %errorlevel%==0 (
  start "" /b powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command "Set-Location -LiteralPath '%PROJECT_DIR%'; $env:NOVIVO_PROJECT_DIR='%PROJECT_DIR%'; $env:NOVIVO_WATCHDOG_CONFIG='%WATCHDOG_CONFIG%'; $env:NOVIVO_WATCHDOG_LABEL='%WATCHDOG_LABEL%'; $env:NOVIVO_DOMAIN='network.novivo.net'; $env:NOVIVO_PORT='3016'; python 'tools/watchdog_manager.py'"
  exit /b 0
)

echo Python/pythonw not found. Install Python or add it to PATH.
pause
exit /b 1
