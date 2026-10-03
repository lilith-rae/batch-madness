@echo off
setlocal enabledelayedexpansion

:: Only use the "configs" subfolder inside the current working directory
set "TARGET_DIR=%CD%\config"

if not exist "%TARGET_DIR%\" (
    echo Directory "%TARGET_DIR%" not found.
    echo Ensure a "config" subfolder exists in the folder where you run this script.
    echo.
    pause
    exit /b 1
)

:menu
cls
echo ===================================================
echo  Select config to run
echo ===================================================
echo.

:: Initialize counter
set /a count=0

:: Loop through the directory and list files (not directories) and hide extensions
:: Skip any file whose base name is "default" (case-insensitive)
for %%F in ("%TARGET_DIR%\*") do (
    if not exist "%%~fF\" (
        if /I not "%%~nF"=="default" (
            set /a count+=1
            set "file[!count!]=%%~nF"
            echo  [!count!] %%~nF
        )
    )
)

:: If no files were found
if %count%==0 (
    echo No files found in "%TARGET_DIR%".
    echo.
    pause
    exit /b
)

echo.
echo ===================================================
echo.

:: Prompt for numeric selection only. Filename typing is disabled.
:ask
set /p choice="Enter the number of the config to run: "

if "!choice!"=="" (
    echo Error: selection cannot be empty.
    goto ask
)
n:: Validate numeric (no non-digits)
for /f "delims=0123456789" %%x in ("!choice!") do set "notnum=1"
if defined notnum (
    echo Invalid selection. Please enter a number between 1 and %count%.
    set "notnum="
    goto ask
)
n:: Validate range
if !choice! lss 1 (
    echo Invalid selection. Please enter a number between 1 and %count%.
    goto ask
)
if !choice! gtr %count% (
    echo Invalid selection. Please enter a number between 1 and %count%.
    goto ask
)

set "selected=!file[%choice%]!"

echo Running with: !selected!

npm run cli !selected!

endlocal
