# Define paths
$sourcePath = "C:\Users\cassi\fastdl\tf2"
$outputFile = "C:\tf2server\Servers\mannpower64\Server\tf\addons\sourcemod\configs\downloads.ini"
$repoPath   = "C:\Users\cassi\fastdl\tf2"

# Debugging: Ensure the source path exists
if (!(Test-Path $sourcePath)) {
    Write-Host "Error: Source path '$sourcePath' does not exist!" -ForegroundColor Red
    Write-Host "Exiting script."
    exit 1
}

# Ensure the output directory exists (create if needed)
$outputDir = Split-Path $outputFile
if (!(Test-Path $outputDir)) {
    Write-Host "Output directory '$outputDir' does not exist. Creating it..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Define header content
$header = @"
//Don't modify or remove the Comment Lines ( // )
//Files (Download Only No Precache)

//Decal Files (Download and Precache)

//Sound Files (Download and Precache)

//Model Files (Download and Precache)
"@

Write-Host "Scanning files under $sourcePath..."

# Get all files recursively, filtering for models/materials
try {
    $files = Get-ChildItem -Path $sourcePath -Recurse -File -ErrorAction Stop |
        Where-Object { $_.FullName -match "\\(models|materials)\\" }

    # If no files are found, warn the user
    if ($files.Count -eq 0) {
        Write-Host "Warning: No 'models' or 'materials' files found." -ForegroundColor Yellow
    }

    # Convert to relative paths with forward slashes
    $filePaths = $files | ForEach-Object {
        $_.FullName -replace [regex]::Escape($sourcePath + "\"), "" -replace "\\", "/"
    }

    Write-Host "Found $($filePaths.Count) files."

    # Combine header and file list
    $finalContent = $header + ($filePaths -join "`r`n")

    # Write to downloads.ini
    Set-Content -Path $outputFile -Value $finalContent -Encoding UTF8
    Write-Host "Successfully updated downloads.ini at $outputFile" -ForegroundColor Green
}
catch {
    Write-Host "Error while processing files: $_" -ForegroundColor Red
    exit 1
}

# Git operations (if repository path exists)
if (Test-Path $repoPath) {
    try {
        Set-Location -Path $repoPath
        Write-Host "Running Git commands..."

        # Run Git commands and capture output
        $gitAdd = git add .
        Write-Host $gitAdd
        $gitCommit = git commit -m "Updated downloads.ini (removed old and added new files)"
        Write-Host $gitCommit
        $gitPush = git push
        Write-Host $gitPush

        Write-Host "Git commit and push successful!" -ForegroundColor Green
    }
    catch {
        Write-Host "Git operation failed: $_" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "Warning: Git repository path '$repoPath' does not exist. Skipping Git operations." -ForegroundColor Yellow
}

Write-Host "Script completed successfully."

# Add this line to keep the script window open
Pause
