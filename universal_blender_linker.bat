@echo off
:: Automatically check and request Admin Rights
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:",=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
pushd "%CD%"
CD /D "%~dp0"

cls
echo =============================================================
echo               UNIVERSAL BLENDER CONFIG MOVER                  
echo =============================================================
echo.
echo Please enter the full path where you want the Blender Config 
echo folder to live (e.g., G:\G Apps\Blender Builds\configs)
echo.
set /p "TARGET_DIR=Target Path: "

:: Remove quotes if the user accidentally included them in their paste
set "TARGET_DIR=%TARGET_DIR:"=%"

:: Validate that the user didn't just press enter
if "%TARGET_DIR%"=="" (
    echo [ERROR] No path entered. Script aborted.
    pause
    exit
)

echo.
echo Closing Blender if it is currently running...
taskkill /f /im blender.exe >nul 2>&1
taskkill /f /im "Blender Launcher.exe" >nul 2>&1

echo.
echo Step 1: Checking original AppData folder...
if not exist "%appdata%\Blender Foundation" (
    echo [WARNING] Could not find an existing Blender folder in AppData.
    echo Creating an empty target directory to link to anyway...
)

echo.
echo Step 2: Creating target folder if it doesn't exist...
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%"
)

echo.
echo Step 3: Moving existing data to new location...
:: If there is data in AppData, copy it over. If not, skip safely.
if exist "%appdata%\Blender Foundation" (
    xcopy "%appdata%\Blender Foundation" "%TARGET_DIR%" /E /I /H /Y >nul
)

echo.
echo Step 4: Removing old folder to clear path for link...
if exist "%appdata%\Blender Foundation" (
    rmdir /S /Q "%appdata%\Blender Foundation"
)

echo.
echo Step 5: Creating Symbolic Link...
mklink /d "%appdata%\Blender Foundation" "%TARGET_DIR%"

echo.
echo =============================================================
echo [SUCCESS] Blender AppData path successfully linked to:
echo %TARGET_DIR%
echo =============================================================
echo.
pause
