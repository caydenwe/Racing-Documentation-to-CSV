@echo off
setlocal enabledelayedexpansion

:: Set working directory
cd "%USERPROFILE%\OneDrive\South Coast Motor Racing\simulator stuff"

:: Download latest Python file and Icon
echo Downloading latest files from GitHub...
curl -L -o ini_to_csv_script.py https://raw.githubusercontent.com/caydenwe/Racing-Documentation-to-CSV/main/ini_to_csv.py
curl -L -o Icon.ico https://raw.githubusercontent.com/caydenwe/Racing-Documentation-to-CSV/main/Icon.ico

:: Extract Version from downloaded Python file
for /f "tokens=2 delims= " %%A in ('findstr /C:"Version:" ini_to_csv_script.py') do set "version=%%A"
set "version=%version: =%"
echo Detected Version: %version%

:: Rename downloaded Python script with version in name
rename ini_to_csv_script.py ini_to_csv_script_v%version%.py

:: Check if an existing EXE already exists
set existingExe=
for %%F in (ini_to_csv_script_v*.exe) do (
    set "existingExe=%%F"
)

if defined existingExe (
    echo Found existing executable: %existingExe%
    
    :: Extract existing version
    set "filename=%existingExe%"
    set "file_version=!filename:~19,-4!"
    echo Installed Version: !file_version!

    :: Compare versions
    call :CompareVersions !file_version! %version%
    if !errorlevel! equ 0 (
        echo You already have the latest version installed.
        goto Cleanup
    ) else (
        echo New version detected, building updated executable...
    )
) else (
    echo No existing executable found. Building fresh...
)

:: Build new executable
:BuildExe
echo Building executable with PyInstaller...
where pyinstaller >nul 2>&1
if errorlevel 1 (
    echo PyInstaller not found. Installing...
    python -m pip install pyinstaller
)

python -m PyInstaller --name=ini_to_csv_script_v%version% --onefile --icon=Icon.ico ini_to_csv_script_v%version%.py

:: Move the new executable
move /Y dist\ini_to_csv_script_v%version%.exe .

:: Cleanup temp build files
:Cleanup
echo Cleaning up...
del /f /q "ini_to_csv_script_v%version%.spec"
del /f /q "ini_to_csv_script_v%version%.py"
del /f /q "Icon.ico"
rmdir /s /q "dist"
rmdir /s /q "build"

:: Create desktop shortcut
echo Creating desktop shortcut...
powershell -Command ^
    "$WshShell = New-Object -ComObject WScript.Shell; ^
    $DesktopPath = [System.Environment]::GetFolderPath('Desktop'); ^
    $Shortcut = $WshShell.CreateShortcut($DesktopPath + '\INI to CSV Converter.lnk'); ^
    $Shortcut.TargetPath = '%USERPROFILE%\OneDrive\South Coast Motor Racing\simulator stuff\ini_to_csv_script_v%version%.exe'; ^
    $Shortcut.WorkingDirectory = '%USERPROFILE%\OneDrive\South Coast Motor Racing\simulator stuff'; ^
    $Shortcut.WindowStyle = 1; ^
    $Shortcut.Description = 'INI to CSV Converter'; ^
    $Shortcut.Save()"

echo Script finished.
endlocal
exit /b 0

:: --- Compare two versions ---
:CompareVersions
setlocal
set "ver1=%~1"
set "ver2=%~2"

for /f "tokens=1-3 delims=." %%a in ("%ver1%") do (
    set "maj1=%%a"
    set "min1=%%b"
    set "pat1=%%c"
)
for /f "tokens=1-3 delims=." %%a in ("%ver2%") do (
    set "maj2=%%a"
    set "min2=%%b"
    set "pat2=%%c"
)

:: Compare major
if %maj1% lss %maj2% exit /b 1
if %maj1% gtr %maj2% exit /b 0
:: Compare minor
if %min1% lss %min2% exit /b 1
if %min1% gtr %min2% exit /b 0
:: Compare patch
if %pat1% lss %pat2% exit /b 1
if %pat1% gtr %pat2% exit /b 0

:: Versions equal
exit /b 0