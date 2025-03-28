Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -WindowStyle Hidden -File ""%USERPROFILE%\Documents\upload_file_when_changed.ps1""", 0, False