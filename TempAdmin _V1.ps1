Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$timerInterval = 30 
$username = $null
$maxTime = 360 

function Get-AdminGroupName {
    $language = (Get-WmiObject -Class Win32_OperatingSystem).MUILanguages[0]
    if ($language -like "en-*") {
        return "Administrators"
    } elseif ($language -like 'fr-*') {
        return "Administrateur"
    } else {
        return "Administrators"  # Default to English if the language is unknown
    }
}


function Remove-DisconnectedSessions {
    
    $sessions = query user

    foreach ($session in $sessions) {
      
        $sessionDetails = $session -split '\s+'
        
        if ($sessionDetails[3] -eq 'Disc') {
            $sessionId = $sessionDetails[2]

            logoff $sessionId
            Write-Host "Disconnected session with ID $sessionId has been logged off."
        }
    }
}

Remove-DisconnectedSessions

function Get-CurrentUser {
    $explorerProcess = Get-WmiObject Win32_Process -Filter "Name='explorer.exe'"
    $loggedOnUser = $explorerProcess.GetOwner().User
    $loggedOnUser
}

function Add-UserToAdmins {
    param (
        [string]$username,
        [string]$adminGroup
    )

    if ((Get-Service -Name GroupMgmtSvc -ErrorAction SilentlyContinue).status -eq "Running" ) {  
    Set-Service -Name GroupMgmtSvc -StartupType Disabled -Status Stopped
    Get-Service -Name GroupMgmtSvc | Stop-Service -Force -ErrorAction SilentlyContinue}

    Add-LocalGroupMember -Group $adminGroup -Member $username
}

function Remove-UserFromAdmins {
    param (
        [string]$username,
        [string]$adminGroup
    )
    if ((Get-Service -Name GroupMgmtSvc -ErrorAction SilentlyContinue).status -eq "Stopped"){  
    Set-Service -Name GroupMgmtSvc -StartupType Automatic -Status Running
    Get-Service -Name GroupMgmtSvc | Start-Service -ErrorAction SilentlyContinue}

    Remove-LocalGroupMember -Group $adminGroup -Member $username
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "Temporary Administrator"
$form.Width = 400
$form.Height = 250
$form.StartPosition = "CenterScreen"
$form.Opacity = 0.9
$form.AllowTransparency = $true

# Label  countdown title
$labelTitle = New-Object System.Windows.Forms.Label
$labelTitle.AutoSize = $true
$labelTitle.Location = New-Object System.Drawing.Point(125, 50)
$labelTitle.Width = 400
$labelTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$labelTitle.Text = "Time Remaining"
$labelTitle.ForeColor = [System.Drawing.Color]::DarkBlue
$form.Controls.Add($labelTitle)

# Label  countdown
$label = New-Object System.Windows.Forms.Label
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(170, 80)
$label.Width = 260
$form.Controls.Add($label)

# Timer 
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000 # 1 second interval
$remainingTime = $timerInterval * 60 # Convert minutes to seconds

# Cancel button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Text = "Cancel"
$cancelButton.Location = New-Object System.Drawing.Point(150, 120)
$cancelButton.Width = 100
$cancelButton.add_Click({
    $result = [System.Windows.Forms.MessageBox]::Show("Remove user from administrators group?", "Confirm", [System.Windows.Forms.MessageBoxButtons]::YesNo)
    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        $timer.Stop()
        Remove-UserFromAdmins -username $username -adminGroup $adminGroup
        $form.Close()
    }
    else {
        $timer.Start() # Restart the timer
    }
})
$form.Controls.Add($cancelButton)

# Add 30 Minutes button
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
        Remove-UserFromAdmins -username $username -adminGroup $adminGroup
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
            Remove-UserFromAdmins -username $username -adminGroup $adminGroup
        }
    }
})

# Main 
$username = Get-CurrentUser
$adminGroup = Get-AdminGroupName
Add-UserToAdmins -username $username -adminGroup $adminGroup

# Start the timer 
$timer.Start()

# Show the form
$form.ShowDialog()
