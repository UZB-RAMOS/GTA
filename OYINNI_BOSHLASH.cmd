@echo off
chcp 65001 >nul
cd /d "%~dp0"

set "OYIN_EXE=%~dp0builds\Toshkent_Sarguzashti_0.7.0.exe"
if not exist "%OYIN_EXE%" set "OYIN_EXE=%~dp0builds\Toshkent_Sarguzashti.exe"
if not exist "%OYIN_EXE%" set "OYIN_EXE=%~dp0Toshkent_Sarguzashti.exe"

if not exist "%OYIN_EXE%" (
    echo Xato: Toshkent_Sarguzashti.exe topilmadi.
    echo Toshkent_Sarguzashti_Windows.zip faylini ochib ko‘ring.
    pause
    exit /b 1
)

start "Toshkent Sarguzashti" "%OYIN_EXE%"
exit /b 0
