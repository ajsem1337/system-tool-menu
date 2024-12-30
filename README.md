## Overview
This PowerShell script provides a simple terminal-based menu for managing your Windows system. It allows you to perform common system maintenance tasks

## Features

1. **Windows Update**

   - Install the latest Windows updates using the PSWindowsUpdate module.
2. **Package Managers**

   - **Chocolatey**: Update all Chocolatey-installed packages. Install Chocolatey if missing.
   - **Winget**: Update all Winget-installed packages. Install Winget if missing.
   - **Scoop**: Update all Scoop-installed packages. Install Scoop if missing.
3. **System Diagnostics**

   - **DISM**: Repair system image.
   - **SFC Scannow**: Check system file integrity.
   - **CheckDisk**: Scan and repair disk errors.
4. **Backup and Recovery**

   - Create a registry backup.
   - Create a system restore point.
   - Run Disk Cleanup.
5. **Reinstall Microsoft Store**

   - Re-register Microsoft Store if it is missing or broken.
6. **Additional Installations**

   - **DirectX**: Install DirectX runtime.
   - **.NET Runtime 6**: Install .NET Runtime version 6.
   - **.NET Runtime 8**: Install .NET Runtime version 8.
   - **.NET Runtime 9**: Install .NET Runtime version 9.

## Requirements

- Windows 10/11
- PowerShell 5.1 or newer (PowerShell 7 recommended)
- Administrator privileges

## Installation and Usage

1. Download the script from latest release:
2. Run the script:

   ```powershell
   .\system-tool-menu.ps1
   ```
3. Ensure PowerShell is running as administrator.
