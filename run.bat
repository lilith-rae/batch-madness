@echo off
setlocal enabledelayedexpansion
:: Determine target directory
:: If first argument is provided and is a directory, use it. Otherwise try to auto-detect or prompt.
set "INPUT_DIR=%~1"
if defined INPUT_DIR (
    if exist "%CD%\%INPUT_DIR%\" (
        set "TARGET_DIR=%CD%\%INPUT_DIR%"
    ) else if exist "%INPUT_DIR%\" (
        set "TARGET_DIR=%INPUT_DIR%"
    ) else (
        echo Directory "%INPUT_DIR%" not found.
        pause
        exit /b 1
    )
) else (
    :: Find directories in current folder
    set /a dirCount=0
    for /d %%D in ("%CD%\*") do (
        set /a dirCount+=1
        set "dir[!dirCount!]=%%~nxD"
        set "dirpath[!dirCount!]=%%~fD"
    )

    if %dirCount%==0 (
        :: No subdirectories, use current directory
        set "TARGET_DIR=%CD%"
    ) else if %dirCount%==1 (
        set "TARGET_DIR=!dirpath[1]!"
    ) else (
        :dirmenu
        cls
        echo ===================================================
        echo  Select a directory in %CD%:
        echo ===================================================
        echo.
        for /l %%i in (1,1,%dirCount%) do echo  [%%i] !dir[%%i!]
        echo.
        set /p dirchoice="Choose directory number (or press Enter to use current dir): "
        if "!dirchoice!"=="" (
            set "TARGET_DIR=%CD%"
        ) else (
            rem Validate numeric choice and range
            for /f "delims=0123456789" %%x in ("!dirchoice!") do set "notnum=1"
            if defined notnum (
                echo Invalid selection. Please enter a number.
                set "notnum="
                pause
                goto dirmenu
            )
            if !dirchoice! gtr 0 if !dirchoice! leq %dirCount% (
                set "TARGET_DIR=!dirpath[%dirchoice%]!"
            ) else (
                echo Invalid selection.
                pause
                goto dirmenu
            )
        )
    )
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

:: Determine argument (file selection). The second script argument (%2) may be used as the selection if present.
if "%~2"=="" (
    set /p argument="Which to run? (enter number or filename): "
) else (
    set "argument=%~2"
)

if "!argument!"=="" (
    echo Error: selection cannot be empty.
    exit /b 1
)

:: Resolve the selection: if it's a number that matches an index, or a filename that matches, or an existing path
set "selected="
:: If argument corresponds to an index
for /f "tokens=*" %%A in ("!argument!") do set "arg=%%A"
if defined filepath[%arg%] (
    set "selected=!filepath[%arg%]!"
) else (
    :: try match filename (case-insensitive)
    for /l %%i in (1,1,%count%) do (
        if /i "!file[%%i]!"=="!arg!" set "selected=!filepath[%%i]!"
    )
    :: if still not found, check if argument is an existing path
    if not defined selected (
        if exist "!arg!" set "selected=!arg!"
    )
)

if not defined selected (
    echo Could not resolve selection: "%argument%"
    echo You may enter the number shown or the exact filename, or provide the directory as the first script argument and the file as the second.
    exit /b 1
)

echo Running with: "!selected!"

npm run cli "!selected!"

endlocal
