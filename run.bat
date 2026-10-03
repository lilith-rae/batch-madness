@echo off
setlocal enabledelayedexpansion
set "TARGET_DIR=%~dp0config"

:menu
cls
echo ===================================================
echo  Select %TARGET_DIR%: 
echo ===================================================
echo.

:: Initialize counter
set /a count=0

:: Loop through the directory and list files
for %%F in ("%TARGET_DIR%\*") do (
    :: Check to make sure it's a file, not a directory
    if not exist "%%~fF\" (
        set /a count+=1
        set "file[!count!]=%%~nxF"
        set "filepath[!count!]=%%~fF"
        echo  [!count!] %%~nxF
    )
)

:: If no files were found
if %count%==0 (
    echo No files found in "%TARGET_DIR%".
    echo.
    pause
    exit /b
)

if "%~1"=="" (
    set /p argument="Which to run?: "
) else (
    set argument=%~1
)

if "!argument!"=="" (
    echo Error: cannot be empty.
    exit /b 1
)

npm run cli !argument!

endlocal