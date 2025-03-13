@echo off
REM Change to a different directory
echo Changing directory...
cd "C:\Users\timwe\OneDrive\South Coast Motor Racing\simulator stuff"

REM Download file from GitHub
echo Downloading file from GitHub...
curl -L -o ini_to_csv_script.py https://raw.githubusercontent.com/caydenwe/Racing-Documentation-to-CSV/refs/heads/main/ini_to_csv.py
curl -L -o icon.ico https://raw.githubusercontent.com/caydenwe/Racing-Documentation-to-CSV/refs/heads/main/icon.ico

REM Run a terminal command
echo Running terminal command...
python -m PyInstaller --name=ini_to_csv_script --onefile --icon=icon.ico ini_to_csv_script.py

REM Move selected files to the new folder
echo Moving selected files to the new folder...
move dist\ini_to_csv_script.exe .\

REM Delete intermediary files for exe creation
echo Deleting intermediary files for exe creation...
del /f /q "ini_to_csv_script.spec"
del /f /q "ini_to_csv.py"
del /f /q "icon.ico"
rmdir /s /q "dist"
rmdir /s /q "build"

REM Create a desktop shortcut for the exe
echo Creating desktop shortcut...
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $DesktopPath = [System.Environment]::GetFolderPath('Desktop'); $Shortcut = $WshShell.CreateShortcut($DesktopPath + '\INI to CSV Converter.lnk'); $Shortcut.TargetPath = 'C:\Users\timwe\OneDrive\South Coast Motor Racing\simulator stuff\ini_to_csv_script.exe'; $Shortcut.WorkingDirectory = 'C:\Users\timwe\OneDrive\South Coast Motor Racing\simulator stuff'; $Shortcut.WindowStyle = 1; $Shortcut.Description = 'INI to CSV Converter'; $Shortcut.Save()"

echo Script finished.
pause