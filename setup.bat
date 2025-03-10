@echo off
REM Change to a different directory
echo Changing directory...
cd "C:\Users\timwe\OneDrive\South Coast Motor Racing\simulator stuff" :: Still need to check this

REM Download file from GitHub
echo Downloading file from GitHub...
curl -L -o ini_to_csv_script.py https://raw.githubusercontent.com/caydenwe/Racing-Documentation-to-CSV/refs/heads/main/ini_to_csv.py

REM Run a terminal command
echo Running terminal command...
python -m PyInstaller --name=ini_to_csv_script --onefile ini_to_csv_script.py

REM Move selected files to the new folder
echo Moving selected files to the new folder...
move dist\ini_to_csv_script.exe .\

REM Delete intermediary files for exe creation
echo Deleting intermediary files for exe creation...
del /f /q "ini_to_csv_script.spec"
rmdir /s /q "dist"
rmdir /s /q "build"

echo Script finished.
pause