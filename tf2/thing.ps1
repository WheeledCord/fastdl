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

# **Step 1: Force Remove .ztmp and Old Files**
Get-ChildItem -Path "$basePath\models", "$basePath\materials" -Recurse -File -Filter "*.ztmp" | Remove-Item -Force -ErrorAction SilentlyContinue

# **Step 2: Ensure No Old Git-Tracked Files**
git rm --cached -r "$basePath\models" "$basePath\materials" --ignore-unmatch

# **Step 3: Clear PowerShell Cache (Force Refresh File List)**
Clear-Variable -Name files -ErrorAction SilentlyContinue
[System.GC]::Collect()

# **Step 4: Rebuild File List Without Deleted Files**
$escapedBasePath = [regex]::Escape($basePath + "\")

$files = Get-ChildItem -Path "$basePath\models", "$basePath\materials" -Recurse -File |
         Where-Object { Test-Path $_.FullName } |  # Ensures files still exist
         ForEach-Object { $_.FullName -replace "^$escapedBasePath", "" -replace "\\", "/" }

# **Step 5: Overwrite downloads.ini with Correct File List**
$header | Set-Content -Path $outputFile
$files | Add-Content -Path $outputFile

# **Step 6: Stage & Commit New Changes**
git add .
git commit -m "Updated downloads.ini with new file list (removed old entries)"
git push
