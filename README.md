**TempAdmin Script for Granting Temporary Admin Rights**

The TempAdmin script has been enhanced to grant temporary administrative rights to the currently logged-in user. The script identifies the user by determining the owner of the `explorer.exe` process and adds them to the local administrators' group with a set timer. Once the timer expires, the user is automatically removed from the admin group. Additionally, the script includes a GUI with a button that allows the user to extend the admin rights by 30-minute increments, up to a maximum of 6 hours.

**Key Features:**
1. **User Identification:** The script identifies the currently logged-in user by finding the owner of the `explorer.exe` process.
2. **Admin Rights Management:** Admin rights are granted using the PowerShell `Add-LocalGroupMember` cmdlet, and they are removed using the `Remove-LocalGroupMember` cmdlet. The use of PowerShell avoids the appearance of a command prompt window on the desktop.
3. **Timer Functionality:** A timer counts down the time remaining for the admin rights. Once the timer runs out, the user is removed from the admin group.
4. **GUI Interface:** The script includes a graphical interface that displays the time remaining in hours, minutes, and seconds. It also provides an "Add 30 minutes" button to extend the timer.
5. **Session Management:** Before adding the user to the admin group, the tool will identify and terminate any disconnected sessions on the machine. This ensures that only active sessions receive the temporary admin rights.

**Deployment in SCCM:**
The script was packaged as an SCCM application and configured to run in the user context. Extensive testing confirmed that the script works as intended, providing a seamless experience for users requiring temporary administrative privileges.
