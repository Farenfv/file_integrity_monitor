# Function to generate baseline hashes
function Generate-BaselineHashes {
    param (
        [string]$directory,
        [string]$outputFile
    )

    # Get all files in the directory with specified extensions
    $files = Get-ChildItem -Path $directory -Recurse -File -Include *.png, *.txt, *.jpeg, *.jpg
    $fileHashes = @()

    foreach ($file in $files) {
        $hash = Get-FileHash -Path $file.FullName -Algorithm SHA256
        $fileHashes += [PSCustomObject]@{
            Path = $hash.Path
            Hash = $hash.Hash
        }
    }

    # Export hashes to CSV file in the script's directory
    $fileHashes | Export-Csv -Path $outputFile -NoTypeInformation

    # Return the count of files processed
    return $files.Count
}

# Function to create a new log file
function Initialize-LogFile {
    param (
        [string]$logFile
    )

    # Create a new log file in the script's directory if it doesn't exist
    if (-not (Test-Path -Path $logFile)) {
        New-Item -Path $logFile -ItemType File | Out-Null
        Write-Host "Log file created: $logFile" -ForegroundColor Yellow
    }
}

# Function to start monitoring
function Start-Monitoring {
    param (
        [string]$directory,
        [string]$baselineFile,
        [string]$logFile
    )

    # Initialize log file
    Initialize-LogFile -logFile $logFile

    # Initial check for baseline file and generation
    if (-not (Test-Path -Path $baselineFile)) {
        $filesProcessed = Generate-BaselineHashes -directory $directory -outputFile $baselineFile
        Write-Host "Baseline hashes generated and saved to $baselineFile for $filesProcessed files." -ForegroundColor Green
    } else {
        Write-Host "Baseline hashes found at $baselineFile" -ForegroundColor Cyan
    }

    Write-Host "Monitoring changes in $directory. Press [Ctrl+C] to exit." -ForegroundColor Cyan

    # Keep monitoring files for changes
    while ($true) {
        # Generate hashes for current files
        $currentFiles = Get-ChildItem -Path $directory -Recurse -File -Include *.png, *.txt, *.jpeg, *.jpg
        $currentHashes = @{}

        foreach ($file in $currentFiles) {
            $hash = Get-FileHash -Path $file.FullName -Algorithm SHA256
            $currentHashes[$file.FullName] = $hash.Hash
        }

        # Compare current hashes with baseline hashes
        $baselineHashes = Import-Csv -Path $baselineFile
        foreach ($baseline in $baselineHashes) {
            if ($currentHashes.ContainsKey($baseline.Path)) {
                $currentHash = $currentHashes[$baseline.Path]
                if ($currentHash -ne $baseline.Hash) {
                    # Log file change
                    $message = "Changed file detected: $($baseline.Path)"
                    Write-Host $message -ForegroundColor Red
                    Add-Content -Path $logFile -Value $message
                }
            } else {
                # Log file deletion
                $message = "Deleted file detected: $($baseline.Path)"
                Write-Host $message -ForegroundColor Red
                Add-Content -Path $logFile -Value $message
            }
        }

        # Check for new files
        foreach ($file in $currentFiles) {
            if (-not ($baselineHashes | Where-Object { $_.Path -eq $file.FullName })) {
                # Log new file
                $message = "Created file detected: $($file.FullName)"
                Write-Host $message -ForegroundColor Red
                Add-Content -Path $logFile -Value $message
            }
        }

        # Update baseline hashes
        Generate-BaselineHashes -directory $directory -outputFile $baselineFile | Out-Null

        # Sleep for 1 second before checking again
        Start-Sleep -Seconds 1
    }
}

# Main script flow
# Prompt user to enter the directory to monitor
$directoryToMonitor = Read-Host "Enter the directory to monitor"

# Define paths for the script's log and baseline files
$baselineFilePath = Join-Path -Path $PSScriptRoot -ChildPath "baseline_hashes.csv"
$logFilePath = Join-Path -Path $PSScriptRoot -ChildPath "file_changes.log"

# Start monitoring with specified parameters
Start-Monitoring -directory $directoryToMonitor -baselineFile $baselineFilePath -logFile $logFilePath
