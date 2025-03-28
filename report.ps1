Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form and controls
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Submit Feedback'
$form.Size = New-Object System.Drawing.Size(400, 250)
$form.StartPosition = 'CenterScreen'

# Feedback label
$label = New-Object System.Windows.Forms.Label
$label.Text = 'Please enter your bug report or feature request:'
$label.Location = New-Object System.Drawing.Point(10, 20)
$label.Size = New-Object System.Drawing.Size(380, 20)
$form.Controls.Add($label)

# TextBox for feedback
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Multiline = $true
$textBox.Location = New-Object System.Drawing.Point(10, 50)
$textBox.Size = New-Object System.Drawing.Size(360, 100)
$form.Controls.Add($textBox)

# Submit button
$submitButton = New-Object System.Windows.Forms.Button
$submitButton.Text = 'Submit Feedback'
$submitButton.Location = New-Object System.Drawing.Point(10, 160)
$submitButton.Size = New-Object System.Drawing.Size(360, 30)
$form.Controls.Add($submitButton)

# Function to submit feedback
$submitButton.Add_Click({
    $feedback = $textBox.Text
    if ($feedback -eq "") {
        [System.Windows.Forms.MessageBox]::Show("Please enter your feedback before submitting.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    # Load .env file
    $envFilePath = ".\.env"
    $envContent = Get-Content $envFilePath

    # Find the line with GITHUB_TOKEN and extract the token
    $tokenLine = $envContent | Where-Object { $_ -match "^GITHUB_TOKEN=" }
    $token = $tokenLine.Split('=')[1].Trim()

    # Set variables
    $repoOwner = "caydenwe"
    $repoName = "Racing-Documentation-to-CSV"
    $filePathInRepo = "feedback.txt"  # Path in GitHub repo

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

    # Show success message
    [System.Windows.Forms.MessageBox]::Show("Thank you! Your feedback has been submitted.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

    # Close the form after submitting
    $form.Close()
})

# Display the form
$form.ShowDialog()