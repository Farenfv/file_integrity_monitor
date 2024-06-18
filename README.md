# File Integrity Monitor

This PowerShell script monitors a specified directory for file changes, including creations, deletions, and modifications. It logs these changes and generates SHA256 hashes to track file integrity.

## Features

- Monitors for file changes in real-time.
- Logs all changes to a log file.
- Generates and updates baseline SHA256 hashes for files.
- Detects file creations, deletions, and modifications.

## Prerequisites

- Windows operating system.
- PowerShell 5.0 or later.

## Installation

1. Clone the repository or download the script file.
2. Place the script in a directory of your choice.

## Usage

1. Open PowerShell.
2. Navigate to the directory where the script is located.
3. Run the script using the following command:
    ```powershell
    .\file_integrity_monitor.ps1
    ```
4. Enter the directory you want to monitor when prompted.

### Example

```powershell
PS C:\Users\YourUsername\Documents> .\file_integrity_monitor.ps1
Enter the directory to monitor: C:\ImportantFolder
