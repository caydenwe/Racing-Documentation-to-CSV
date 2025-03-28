@echo off

REM Change to a different directory
cd "%USERPROFILE%\Documents"

REM Download file from GitHub
curl -L -o upload_file_when_changed.ps1 https://raw.githubusercontent.com/caydenwe/Racing-Documentation-to-CSV/refs/heads/main/upload_file_when_changed.ps1
curl -L -o run_file_upload_when_changed_hidden.vbs https://raw.githubusercontent.com/caydenwe/Racing-Documentation-to-CSV/refs/heads/main/run_file_upload_when_changed_hidden.vbs

wscript "%USERPROFILE%\Documents\run_file_upload_when_changed_hidden.vbs"

REM Exit batch script
exit