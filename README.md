### Granting Temporary Administrative Rights with a PowerShell Script

**Overview:**
Managing administrative privileges on Windows machines can be a challenge, especially when users require temporary elevated access. To address this, I developed a PowerShell script that grants temporary admin rights to the currently logged-in user, with a built-in timer to automatically revoke these rights after a set period. This solution was deployed using SCCM as an application in the user context and has been tested to work flawlessly.

**How It Works:**
1. **Identifying the Logged-In User:**
   The script identifies the logged-in user by checking the owner of the `explorer.exe` process. Since `explorer.exe` typically runs under the user's account, this method reliably identifies the active user session.

2. **Granting Admin Rights:**
   Once the user is identified, the script adds the user to the local "Administrators" group using the `net localgroup administrators /add` command. This grants the necessary administrative privileges.

3. **Timer and Automatic Removal:**
   A GUI is presented to the user, showing the remaining time until their admin rights are revoked. The script starts a 30-minute countdown timer, which can be extended by clicking the "Add 30 Minutes" button. The timer can be extended up to a maximum of 6 hours. Once the timer expires, the user is automatically removed from the "Administrators" group, and the script exits.

4. **User Interaction:**
   The GUI allows the user to monitor the time remaining and add more time if needed. This interaction ensures that users are aware of their temporary privileges and can request additional time without needing to re-run the script.

**Deployment via SCCM:**
The script was packaged as an SCCM application, with the installation behavior set to run in the user context. This ensures that the script interacts directly with the logged-in user, providing a seamless experience. The application deployment method in SCCM was chosen over the package method due to its superior user interaction capabilities and better management options.

**Testing and Results:**
After thorough testing, the script and its deployment method were confirmed to work as expected. Users were able to obtain temporary admin rights, extend the timer as needed, and the rights were correctly revoked once the timer ran out. This solution provides a controlled way to grant temporary admin access without compromising security or requiring manual intervention.

**Conclusion:**
This PowerShell-based solution is a practical and secure way to manage temporary administrative rights on Windows machines. By deploying it via SCCM, it integrates seamlessly into existing IT management processes, ensuring that users have the access they need without exposing the system to unnecessary risks.

