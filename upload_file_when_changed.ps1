$sourceFilePath = "C:\path\to\your\file.txt"  # Path to the file you want to monitor
$backupDir = "$env:USERPROFILE\OneDrive\South Coast Motor Racing\"  # OneDrive backup directory

# Create a new instance of FileSystemWatcher to monitor the file
$fsWatcher = New-Object System.IO.FileSystemWatcher
$fsWatcher.Path = (Get-Item $sourceFilePath).DirectoryName
$fsWatcher.Filter = (Get-Item $sourceFilePath).Name
$fsWatcher.NotifyFilter = [System.IO.NotifyFilters]'LastWrite'

# Define the action to take when a change is detected
$action = {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $newFileName = "$($backupDir)\$(basename $sourceFilePath)_$timestamp.txt"
    Copy-Item $using:sourceFilePath -Destination $newFileName
    Write-Host "File changed, backup saved to OneDrive as $newFileName"
}

# Attach the event handler
Register-ObjectEvent $fsWatcher "Changed" -Action $action

# Start monitoring the file
$fsWatcher.EnableRaisingEvents = $true

# Keep the script running indefinitely
Write-Host "Monitoring file for changes. Press [Ctrl+C] to stop."
while ($true) {
    Start-Sleep -Seconds 1
}
