@echo off
setlocal enabledelayedexpansion

REM Change to a different directory
cd "C:\Users\timwe\OneDrive\South Coast Motor Racing\simulator stuff"

REM Download file from GitHub
curl -L -o ini_to_csv_script.py https://raw.githubusercontent.com/caydenwe/Racing-Documentation-to-CSV/refs/heads/main/ini_to_csv.py
curl -L -o Icon.ico https://raw.githubusercontent.com/caydenwe/Racing-Documentation-to-CSV/refs/heads/main/Icon.ico

REM Extract version from Python file
for /f "tokens=2 delims= " %%A in ('findstr /C:"Version:" ini_to_csv_script.py') do set "version=%%A"
set "version=%version: =%"

REM Copy the Python file with a versioned name
rename ini_to_csv_script.py ini_to_csv_script_v%version%.py

REM Initialize a counter
set count=0

REM Loop through matching files
for %%F in (ini_to_csv_script_v*.*.*.exe) do (
    echo Processing: %%F
    REM Increment the counter
    set /a count+=1
    
    REM If more than one file is found, exit with an error
    if !count! gtr 1 (
        echo ERROR: More than one file matches the pattern. Exiting.
        exit /b 1
    )
    
    REM Extract the version number
    set "filename=%%~nF"
    set "filepart="
    
    REM Remove the prefix "ini_to_csv_script_v"
    set "filepart=!filename:~18!"

    REM Remove the suffix ".exe"
    set "filepart=!filepart:.exe=!"
)

REM Compare the versions
if %count%==1 (
    if "!filepart!" gtr "%version%" (
        echo The version from the file is newer than the Python version.
        call :Function1
    ) else (
        echo You have the latest version available.
        del /f /q "Icon.ico"
        del /f /q "ini_to_csv_script.py"
    )
) else (
    echo You have not installed this program before, installing from scratch.
    call :Function1
)

REM Function 1
:Function1

REM Run PyInstaller to create executable with version number in name
python -m PyInstaller --name=ini_to_csv_script_v!version! --onefile --icon=Icon.ico ini_to_csv_script_v!version!.py

REM Move selected files to the main folder
move dist\ini_to_csv_script_v!version!.exe .\

REM Delete intermediary files for exe creation
del /f /q "ini_to_csv_script_v!version!.spec"
del /f /q "ini_to_csv_script_v!version!.py"
del /f /q "Icon.ico"
rmdir /s /q "dist"
rmdir /s /q "build"

REM Create a desktop shortcut for the exe
echo Creating desktop shortcut...
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $DesktopPath = [System.Environment]::GetFolderPath('Desktop'); $Shortcut = $WshShell.CreateShortcut($DesktopPath + '\INI to CSV Converter.lnk'); $Shortcut.TargetPath = 'C:\Users\timwe\OneDrive\South Coast Motor Racing\simulator stuff\ini_to_csv_script_v!version!.exe'; $Shortcut.WorkingDirectory = 'C:\Users\timwe\OneDrive\South Coast Motor Racing\simulator stuff'; $Shortcut.WindowStyle = 1; $Shortcut.Description = 'INI to CSV Converter'; $Shortcut.Save()"
goto :eof

endlocal
echo Script finished.