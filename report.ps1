# Set variables
$repoOwner = "caydenwe"
$repoName = "Racing-Documentation-to-CSV"
$filePathInRepo = "feedback.txt"  # Path in GitHub repo

# Get input from user
$feedback = Read-Host "Please enter your bug report or feature request"

# Get current datetime
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Format feedback
$entry = "`n[$timestamp] $feedback"

# Download existing file from GitHub
$apiUrl = "https://api.github.com/repos/$repoOwner/$repoName/contents/$filePathInRepo"
$response = Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization = "token $token"}

# Decode the content
$content = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($response.content))

# Append new entry
$newContent = $content + $entry

# Re-encode the content
$encodedContent = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($newContent))

# Prepare commit message
$commitMessage = "Add user feedback: $timestamp"

# Prepare body for PUT request
$body = @{
  message = $commitMessage
  content = $encodedContent
  sha = $response.sha  # Needed for updating existing file
} | ConvertTo-Json -Depth 10

# Update the file on GitHub
Invoke-RestMethod -Method Put -Uri $apiUrl -Headers @{Authorization = "token $token"} -Body $body

Write-Host "Thank you! Your feedback has been submitted." -ForegroundColor Green
Pause
