@echo off
chcp 65001 >nul
cd /d "%~dp0"

if not exist "builds\Toshkent_Sarguzashti.exe" (
    echo Xato: builds\Toshkent_Sarguzashti.exe topilmadi.
    echo Toshkent_Sarguzashti_Windows.zip faylini ochib ko‘ring.
    pause
    exit /b 1
)

start "Toshkent Sarguzashti" "builds\Toshkent_Sarguzashti.exe"
exit /b 0
