# system-tool-menu
Simple System Management Menu

This PowerShell script provides a simple terminal-based menu for managing your Windows system. It allows you to perform common system maintenance tasks such as:
Features:

    System Updates:
        Install and update Windows components.
        Update package managers like Chocolatey, Winget, and Scoop.
        Option to install missing package managers if not detected.

    System Diagnostics:
        Check and repair system integrity using DISM and SFC.
        Scan and repair disk drives using chkdsk.

    Logging:
        Optional logging of all operations to a timestamped log file for future reference.

    Time Tracking:
        Displays the duration of each operation after completion.

How to Use:

    Open PowerShell as Administrator.
    Run the script using:

    .\system-tool-menu.ps1

    Follow the interactive menu to choose your desired operation.

Requirements:

    Windows PowerShell (Administrator access required)
    Internet connection for downloading updates or missing components.
