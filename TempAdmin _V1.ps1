# Load the required assemblies for Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define variables
$timerInterval = 30 # Minutes for the timer
$username = $null
$maxTime = 360 # 6 hours in minutes

# Function to remove disconnected sessions
function Remove-DisconnectedSessions {
    # Get all user sessions on the machine
    $sessions = query user

    foreach ($session in $sessions) {
        # Split the session details into an array
        $sessionDetails = $session -split '\s+'

        # Check if the session state is 'Disc' (Disconnected)
        if ($sessionDetails[3] -eq 'Disc') {
            $sessionId = $sessionDetails[2]

            # Log off the disconnected session
            logoff $sessionId
            Write-Host "Disconnected session with ID $sessionId has been logged off."
        }
    }
}

Remove-DisconnectedSessions

# Function to get the currently logged-in username
function Get-CurrentUser {
    $explorerProcess = Get-WmiObject Win32_Process -Filter "Name='explorer.exe'"
    $loggedOnUser = $explorerProcess.GetOwner().User
    $loggedOnUser
}

# Function to add user to local administrators group
function Add-UserToAdmins {
    param (
        [string]$username
    )

    if ((Get-Service -Name GroupMgmtSvc -ErrorAction SilentlyContinue).status -eq "Running" ) {  
    Set-Service -Name GroupMgmtSvc -StartupType Disabled -Status Stopped
    Get-Service -Name GroupMgmtSvc | Stop-Service -Force -ErrorAction SilentlyContinue}

    Add-LocalGroupMember -Group "Administrators" -Member $username
}

# Function to remove user from local administrators group
function Remove-UserFromAdmins {
    param (
        [string]$username
    )
    if ((Get-Service -Name GroupMgmtSvc -ErrorAction SilentlyContinue).status -eq "Stopped"){  
    Set-Service -Name GroupMgmtSvc -StartupType Automatic -Status Running
    Get-Service -Name GroupMgmtSvc | Start-Service -ErrorAction SilentlyContinue}

    Remove-LocalGroupMember -Group "Administrators" -Member $username
    Remove-LocalGroupMember -Group "Administrators" -Member "Domain Users"


}

# Create the Windows form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Temporary Administrator"
$form.Width = 400
$form.Height = 250
$form.StartPosition = "CenterScreen"
$form.Opacity = 0.9
$form.AllowTransparency = $true

# Create a label to display the countdown title
$labelTitle = New-Object System.Windows.Forms.Label
$labelTitle.AutoSize = $true
$labelTitle.Location = New-Object System.Drawing.Point(125, 50)
$labelTitle.Width = 400
$labelTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$labelTitle.Text = "Time Remaining"
$labelTitle.ForeColor = [System.Drawing.Color]::DarkBlue
$form.Controls.Add($labelTitle)

# Create a label to display the countdown
$label = New-Object System.Windows.Forms.Label
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(170, 80)
$label.Width = 260
$form.Controls.Add($label)

# Create a Timer for countdown logic
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000 # 1 second interval
$remainingTime = $timerInterval * 60 # Convert minutes to seconds

# Create a Cancel button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Text = "Cancel"
$cancelButton.Location = New-Object System.Drawing.Point(150, 120)
$cancelButton.Width = 100
$cancelButton.add_Click({
    $result = [System.Windows.Forms.MessageBox]::Show("Remove user from administrators group?", "Confirm", [System.Windows.Forms.MessageBoxButtons]::YesNo)
    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        $timer.Stop()
        Remove-UserFromAdmins -username $username
        $form.Close()
    }
    else {
        $timer.Start() # Restart the timer
    }
})
$form.Controls.Add($cancelButton)

# Create an Add 30 Minutes button
$addButton = New-Object System.Windows.Forms.Button
$addButton.Text = "Add 30 Minutes"
$addButton.Location = New-Object System.Drawing.Point(150, 150)
$addButton.Width = 100
$addButton.add_Click({
    $script:remainingTime += 30 * 60
    if ($script:remainingTime -gt $maxTime * 60) {
        $script:remainingTime = $maxTime * 60
    }
})
$form.Controls.Add($addButton)

# Timer Tick event
$timer.add_Tick({
    $script:remainingTime--
    if ($script:remainingTime -ge 0) {
        $hoursRemaining = [math]::Floor($script:remainingTime / 3600)
        $minutesRemaining = [math]::Floor(($script:remainingTime % 3600) / 60)
        $secondsRemaining = $script:remainingTime % 60
        $label.Text = "{0:00}:{1:00}:{2:00}" -f $hoursRemaining, $minutesRemaining, $secondsRemaining
    }
    if ($script:remainingTime -le 0) {
        $timer.Stop()
        Remove-UserFromAdmins -username $username
        $form.Close()
    }
})


# Form Closing event
$form.add_Closing({
    param($sender, $e)
    if ($timer.Enabled) {
        $result = [System.Windows.Forms.MessageBox]::Show("Remove user from administrators group?", "Confirm", [System.Windows.Forms.MessageBoxButtons]::YesNo)
        if ($result -eq [System.Windows.Forms.DialogResult]::No) {
            $e.Cancel = $true # Prevent form from closing
            $timer.Start() # Restart the timer
        }
        else {
            Remove-UserFromAdmins -username $username
        }
    }
})



# Main script logic
$username = Get-CurrentUser
Add-UserToAdmins -username $username

# Start the timer 
$timer.Start()

# Show the form
$form.ShowDialog()
