@echo off
setlocal
title NeutraScan Launcher
color 0B

set "SCRIPT=%~dp0NeutraScan.ps1"

if not exist "%SCRIPT%" (
    echo.
    echo  [X] NeutraScan.ps1 not found next to this .bat file.
    echo      Expected at: %SCRIPT%
    echo.
    pause
    exit /b 1
)

where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo  [X] powershell.exe not found on PATH.
    pause
    exit /b 1
)

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo  [*] Requesting Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo  =====================================================
echo   NeutraScan v1.0  -  Scan. Identify. Control.
echo   by littlleprince
echo  =====================================================
echo.
echo  [*] Launching NeutraScan...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -STA -File "%SCRIPT%"

set "RC=%errorlevel%"
if not "%RC%"=="0" (
    echo.
    echo  [X] NeutraScan exited with code %RC%.
    echo      Check %%TEMP%%\NeutraScan-error.log for details.
    echo.
    pause
)

endlocal