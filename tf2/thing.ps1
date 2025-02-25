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

# Normalize path separator for regex compatibility
$escapedBasePath = [regex]::Escape($basePath + "\")

# Find all files in /models or /materials
$files = Get-ChildItem -Path "$basePath\models", "$basePath\materials" -Recurse -File |
         ForEach-Object { $_.FullName -replace "^$escapedBasePath", "" -replace "\\", "/" }

# Write to file
$header | Set-Content -Path $outputFile
$files | Add-Content -Path $outputFile

# Git operations in the current directory
git add .
git commit -m "Updated downloads.ini with new files"
git push
