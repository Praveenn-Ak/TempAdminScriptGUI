## Temporary Admin Rights Script

### Overview
This **Temp Admin script** grants temporary local administrative rights to the currently logged-in user (explorer owner). It ensures the user is removed from the administrator group after a set timer, with an option to extend the timer up to **6 hours**. Additionally, the script checks the operating system's language, adding the user to the appropriate admin group for either English or French systems.

### Features:
- Adds the **explorer owner** (current user) to the **local administrator** group.
- Checks OS language (English or French) to assign the correct group: `Administrators` (EN) or `Administrateur` (FR).
- Automatically removes the user from the admin group after the timer expires.
- The user can extend the timer, with a maximum time of **6 hours**.
- Handles disconnected sessions by logging off inactive users.
- Integrates well into **SCCM deployments**.

### Script Breakdown:
1. **Session Management**: The script logs off disconnected sessions.
2. **User Detection**: Identifies the current logged-in user using the explorer process.
3. **Language Check**: Dynamically adds the user to the correct admin group based on system language (English or French).
4. **Timer and GUI**: Displays a countdown timer, allows cancellation, and extends the timer for admin rights.

### Converting the Script to an EXE

For ease of deployment, we use the **ps2exe module** to convert the PowerShell script into an executable (.exe). This simplifies the integration with SCCM or other deployment tools.

#### Steps to Convert the Script:
1. Install the `ps2exe` module in PowerShell:
   ```powershell
   Install-Module -Name ps2exe -Scope CurrentUser
   ```
2. Convert the script to an executable:
   ```powershell
   ps2exe -inputFile "TempAdmin.ps1" -outputFile "TempAdmin.exe"
   ```
   This will create the `TempAdmin.exe` file from the PowerShell script.

### Deploying via SCCM

When deploying the EXE via **SCCM**, you want SCCM to trigger the EXE but **not wait** for it to complete. This can be done by adding the following command to the SCCM program’s command line:

```cmd
cmd.exe /c start "" "TempAdmin.exe"
```

- `cmd.exe /c start` ensures that SCCM launches the EXE and exits immediately without waiting for the process to finish.
  
### Conclusion

This **Temp Admin script** is an efficient solution for managing temporary admin rights, especially in environments where elevated permissions are needed for a limited time. By converting the script to an EXE and integrating it with SCCM, you can automate the deployment and management of temporary administrative privileges seamlessly.
