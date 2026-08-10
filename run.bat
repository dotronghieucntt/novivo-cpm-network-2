@echo off
setlocal EnableExtensions

REM NOVIVO CPM Network launcher
REM Chi mo Watchdog GUI cua dung project nay.
REM Watchdog GUI tu start FE/BE Next.js tren port 3016 va tunnel network.novivo.net sau 3 giay.

set "PROJECT_DIR=%~dp0cpm-network-platform"
set "WATCHDOG_SCRIPT=%PROJECT_DIR%\tools\watchdog_manager.py"
set "WATCHDOG_CONFIG=%TEMP%\cloudflared-network-watchdog.yml"

if not exist "%WATCHDOG_SCRIPT%" (
  echo Watchdog script not found: %WATCHDOG_SCRIPT%
  pause
  exit /b 1
)

cd /d "%PROJECT_DIR%"

REM Mark process environment so this launcher belongs to NOVIVO Network only.
set "NOVIVO_PROJECT_DIR=%PROJECT_DIR%"
set "NOVIVO_WATCHDOG_CONFIG=%WATCHDOG_CONFIG%"
set "NOVIVO_DOMAIN=network.novivo.net"
set "NOVIVO_PORT=3016"

REM Prefer pythonw so the black CMD console closes while the Tkinter Watchdog GUI stays visible.
where pythonw >nul 2>nul
if %errorlevel%==0 (
  start "NOVIVO Network Watchdog GUI" /D "%PROJECT_DIR%" pythonw "%WATCHDOG_SCRIPT%"
  exit /b 0
)

REM Fallback: if pythonw is unavailable, run python through hidden PowerShell.
where python >nul 2>nul
if %errorlevel%==0 (
  start "NOVIVO Network Watchdog GUI" /min powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command "Set-Location -LiteralPath '%PROJECT_DIR%'; $env:NOVIVO_PROJECT_DIR='%PROJECT_DIR%'; $env:NOVIVO_DOMAIN='network.novivo.net'; $env:NOVIVO_PORT='3016'; python 'tools/watchdog_manager.py'"
  exit /b 0
)

echo Python/pythonw not found. Install Python or add it to PATH.
pause
exit /b 1
