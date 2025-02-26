$basePath = "C:\tf2server\Servers\mannpower64\Server\tf"
$outputFile = "$basePath\addons\sourcemod\configs\downloads.ini"
$gitRepoPath = "C:\Users\cassi\fastdl"  # Set this to the actual Git repository path!

# Header for the file
$header = @"
//Don't modify or remove the Comment Lines ( // )
//Files (Download Only No Precache)

//Decal Files (Download and Precache)

//Sound Files (Download and Precache)

//Model Files (Download and Precache)
"@

# **Step 1: Delete all .ztmp files to avoid ghost files**
Get-ChildItem -Path "$basePath\models", "$basePath\materials" -Recurse -File -Filter "*.ztmp" | Remove-Item -Force -ErrorAction SilentlyContinue

# **Step 2: Force Git to remove deleted files (run in correct repo)**
Set-Location $gitRepoPath  # Ensure Git is running in the correct repo
git rm --cached -r . --ignore-unmatch  # Remove deleted files from Git index

# **Step 3: Refresh PowerShell Cache**
Clear-Variable -Name files -ErrorAction SilentlyContinue
[System.GC]::Collect()

# **Step 4: Scan for existing files & rebuild downloads.ini**
$escapedBasePath = [regex]::Escape($basePath + "\")

$files = Get-ChildItem -Path "$basePath\models", "$basePath\materials" -Recurse -File |
         Where-Object { Test-Path $_.FullName } |  # Ensures files still exist
         ForEach-Object { $_.FullName -replace "^$escapedBasePath", "" -replace "\\", "/" }

# **Step 5: Write fresh file list**
$header | Set-Content -Path $outputFile
$files | Add-Content -Path $outputFile

# **Step 6: Git Stage & Commit in the Correct Directory**
git add .
git commit -m "Updated downloads.ini (removed old and added new files)"
git push

# **Step 7: Reset back to original working directory**
Set-Location $basePath
