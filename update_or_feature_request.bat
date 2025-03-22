@echo off

:: Launch a PowerShell GUI with two options
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $form = New-Object System.Windows.Forms.Form; $form.Text = 'Select an Option'; $form.Size = New-Object System.Drawing.Size(300,150); $form.StartPosition = 'CenterScreen'; $button1 = New-Object System.Windows.Forms.Button; $button1.Location = New-Object System.Drawing.Point(50,30); $button1.Size = New-Object System.Drawing.Size(200,30); $button1.Text = 'Report a Bug / Request Feature'; $button1.Add_Click({ $form.Tag = 'report'; $form.Close() }); $form.Controls.Add($button1); $button2 = New-Object System.Windows.Forms.Button; $button2.Location = New-Object System.Drawing.Point(50,70); $button2.Size = New-Object System.Drawing.Size(200,30); $button2.Text = 'Check for Updates'; $button2.Add_Click({ $form.Tag = 'update'; $form.Close() }); $form.Controls.Add($button2); $form.ShowDialog() | Out-Null; switch ($form.Tag) { 'report' { exit 1 } 'update' { exit 2 } }"

set "choice=%errorlevel%"

python -c "import PIL" >nul 2>&1
if %errorlevel% neq 0 (
    echo Pillow is not installed. Installing...
    pip install pillow
) else (
    echo Pillow is already installed.
)

:: Check what was chosen
if "%choice%"=="1" (
    echo You chose to report a bug or request a feature!
    if not exist "%~dp0report.ps1" (
        echo report.ps1 does not exist. Downloading now...
        curl -L -o "%~dp0report.ps1" https://raw.githubusercontent.com/caydenwe/Racing-Documentation-to-CSV/refs/heads/main/report.ps1
    ) else (
        echo report.ps1 already exists.
    )
    powershell -ExecutionPolicy Bypass -File "%~dp0report.ps1"
    del "report.ps1"
) else if "%choice%"=="2" (
    echo You chose to check for updates!
    if not exist "setup_or_check_for_update.bat" (
        echo report.ps1 does not exist. Downloading now...
        curl -L -o setup_or_check_for_update.bat https://raw.githubusercontent.com/caydenwe/Racing-Documentation-to-CSV/refs/heads/main/setup_or_check_for_update.bat
    ) else (
        echo report.ps1 already exists.
    )
    call setup_or_check_for_update.bat
    del "setup_or_check_for_update.bat"
    pause
)
exit /b