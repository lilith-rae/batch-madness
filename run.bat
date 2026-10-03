@echo off
setlocal enabledelayedexpansion

:: Only use the "configs" subfolder inside the current working directory
set "TARGET_DIR=%CD%\configs"

if not exist "%TARGET_DIR%\" (
    echo Directory "%TARGET_DIR%" not found.
    echo Ensure a "configs" subfolder exists in the folder where you run this script.
    echo.
    pause
    exit /b 1
)

:menu
cls
echo ===================================================
echo  Select files in: %TARGET_DIR%
echo ===================================================
echo.

:: Initialize counter
set /a count=0

:: Loop through the directory and list files (not directories) and hide extensions
for %%F in ("%TARGET_DIR%\*") do (
    if not exist "%%~fF\" (
        set /a count+=1
        set "file[!count!]=%%~nF"
        echo  [!count!] %%~nF
    )
)

:: If no files were found
if %count%==0 (
    echo No files found in "%TARGET_DIR%".
    echo.
    pause
    exit /b
)

:: Prompt for selection (number or filename without extension)
set /p argument="Which to run? (enter number or filename without extension): "

if "!argument!"=="" (
    echo Error: selection cannot be empty.
    exit /b 1
)

:: Strip any extension from the user's entry if they typed one
for /f "tokens=*" %%A in ("!argument!") do set "arg=%%A"
for %%B in ("!arg!") do set "argbase=%%~nB"

:: Resolve the selection
set "selected="

:: Check numeric index first
if !arg! geq 1 if !arg! leq %count% (
    set "selected=!file[!arg!]!"
)

:: Then check exact filename match without extension
if not defined selected (
    for /l %%i in (1,1,%count%) do (
        if /i "!file[%%i]!"=="!argbase!" set "selected=!file[%%i]!"
    )
)

if not defined selected (
    echo Could not resolve selection: "!argument!"
    echo Please enter the number shown or the filename without extension.
    exit /b 1
)

echo Running with: "!selected!"

npm run cli "!selected!"

endlocal
