$sourceFilePath = "$env:USERPROFILE\OneDrive\Documents\Assetto Corsa\aim\telemetry_dump.act" # Path to the file you want to monitor
$backupDir = "$env:USERPROFILE\OneDrive\South Coast Motor Racing\simulator stuff\Race Studio Files"  # Backup directory

# Create FileSystemWatcher
$fsWatcher = New-Object System.IO.FileSystemWatcher
$fsWatcher.Path = (Get-Item $sourceFilePath).DirectoryName
$fsWatcher.Filter = (Get-Item $sourceFilePath).Name
$fsWatcher.NotifyFilter = [System.IO.NotifyFilters]'LastWrite, FileName, DirectoryName'
$fsWatcher.InternalBufferSize = 8192  # Increase buffer size to 8 KB


# Debug: Print directory and file to ensure it's correct
Write-Host "Monitoring directory: $($fsWatcher.Path)"
Write-Host "Monitoring file: $($fsWatcher.Filter)"
Write-Host "NotifyFilter: $($fsWatcher.NotifyFilter)"

# Action to take when a change is detected
$action = {
    Write-Host "File change event triggered."
    
    # Access the passed data from the MessageData
    $sourceFilePath = $Event.MessageData.SourceFilePath
    $backupDir = $Event.MessageData.BackupDir

    Write-Host "Source file path: $sourceFilePath"
    Write-Host "Backup directory: $backupDir"
    
    # Action to take when a change is detected
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    Write-Host "Timestamp for backup: $timestamp"

    # Use Split-Path to get the base name of the file
    $newFileName = "$($backupDir)\$(Split-Path $sourceFilePath -Leaf)_$timestamp.txt"
    Write-Host "Creating backup: $newFileName"

    try {
        # Attempt to copy the file and check if there were any issues
        Copy-Item $sourceFilePath -Destination $newFileName -ErrorAction Stop
        Write-Host "Backup saved to $newFileName"
    } catch {
        Write-Host "Error during file copy: $_"  # Print out any errors that occur during Copy-Item
    }
}

# Register the event handler and pass the sourceFilePath and backupDir via MessageData
Write-Host "Registering event handlers for all file events..."
$onChanged = Register-ObjectEvent $fsWatcher "Changed" -Action $action -MessageData @{ 
    SourceFilePath = $sourceFilePath
    BackupDir = $backupDir
} -SourceIdentifier FileChanged

# Start monitoring the file
$fsWatcher.EnableRaisingEvents = $true
Write-Host "Event handler registered. Monitoring file for changes."

# Wait for events to trigger (this keeps the script running indefinitely)
Wait-Event -SourceIdentifier FileChanged

Pause
# Clean up the event job
$onChanged | Remove-Job -Force