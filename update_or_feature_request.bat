@echo off

@REM :: Launch a PowerShell GUI with two options
@REM powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $form = New-Object System.Windows.Forms.Form; $form.Text = 'Select an Option'; $form.Size = New-Object System.Drawing.Size(300,150); $form.StartPosition = 'CenterScreen'; $button1 = New-Object System.Windows.Forms.Button; $button1.Location = New-Object System.Drawing.Point(50,30); $button1.Size = New-Object System.Drawing.Size(200,30); $button1.Text = 'Report a Bug / Request Feature'; $button1.Add_Click({ $form.Tag = 'report'; $form.Close() }); $form.Controls.Add($button1); $button2 = New-Object System.Windows.Forms.Button; $button2.Location = New-Object System.Drawing.Point(50,70); $button2.Size = New-Object System.Drawing.Size(200,30); $button2.Text = 'Check for Updates'; $button2.Add_Click({ $form.Tag = 'update'; $form.Close() }); $form.Controls.Add($button2); $form.ShowDialog() | Out-Null; switch ($form.Tag) { 'report' { exit 1 } 'update' { exit 2 } }"

@REM :: Check what was chosen
@REM set "choice=%errorlevel%"
@REM if "%choice%"=="1" (
@REM     echo You chose to report a bug or request a feature!
@REM     :: Put your commands here for reporting a bug
@REM ) else if "%choice%"=="2" (
    echo You chose to check for updates!
    curl -L -o setup_or_check_for_update.bat https://raw.githubusercontent.com/caydenwe/Racing-Documentation-to-CSV/refs/heads/main/setup_or_check_for_update.bat
    call setup_or_check_for_update.bat
    del "setup_or_check_for_update.bat"
@REM )
pause
exit /b