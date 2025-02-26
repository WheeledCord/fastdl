$basePath = "C:\tf2server\Servers\mannpower64\Server\tf"
$outputFile = "$basePath\addons\sourcemod\configs\downloads.ini"

# Header for the file
$header = @"
//Don't modify or remove the Comment Lines ( // )
//Files (Download Only No Precache)

//Decal Files (Download and Precache)

//Sound Files (Download and Precache)

//Model Files (Download and Precache)
"@

# Force deletion of .ztmp files to prevent ghost files
Get-ChildItem -Path "$basePath\models", "$basePath\materials" -Recurse -File -Filter "*.ztmp" | Remove-Item -Force -ErrorAction SilentlyContinue

# Wait a moment to ensure deletions are processed
Start-Sleep -Seconds 1

# Refresh file list and exclude deleted files
$escapedBasePath = [regex]::Escape($basePath + "\")

$files = Get-ChildItem -Path "$basePath\models", "$basePath\materials" -Recurse -File |
         Where-Object { Test-Path $_.FullName } |  # Ensures files still exist
         ForEach-Object { $_.FullName -replace "^$escapedBasePath", "" -replace "\\", "/" }

# Write fresh file list
$header | Set-Content -Path $outputFile
$files | Add-Content -Path $outputFile

# Git operations in the current directory
git add .
git commit -m "Updated downloads.ini with new files"
git push
