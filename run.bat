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

:: Loop through the directory and list files (not directories)
for %%F in ("%TARGET_DIR%\*") do (
    if not exist "%%~fF\" (
        set /a count+=1
        set "file[!count!]=%%~nxF"
        set "filepath[!count!]=%%~fF"
        echo  [!count!] %%~nxF
    )
)

:: If no files found
if %count%==0 (
    echo No files found in "%TARGET_DIR%".
    echo.
    pause
    exit /b
)

:: Prompt for selection (number or filename). Manual directory override removed.
set /p argument="Which to run? (enter number or filename): "

if "!argument!"=="" (
    echo Error: selection cannot be empty.
    exit /b 1
)

:: Resolve the selection: support numeric index or exact filename (case-insensitive)
set "selected="
for /f "tokens=*" %%A in ("!argument!") do set "arg=%%A"
if defined filepath[%arg%] (
    set "selected=!filepath[%arg%]!"
) else (
    for /l %%i in (1,1,%count%) do (
        if /i "!file[%%i]!"=="!arg!" set "selected=!filepath[%%i]!"
    )
)

if not defined selected (
    echo Could not resolve selection: "!argument!"
    echo Please enter the number shown or the exact filename from the list.
    exit /b 1
)

echo Running with: "!selected!"

npm run cli "!selected!"

endlocal
