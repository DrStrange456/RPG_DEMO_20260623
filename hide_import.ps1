# Use the folder this script resides in
$projectPath = $PSScriptRoot

# Hide existing .import and .uid files
Get-ChildItem -Path $projectPath -Recurse -Include *.import, *.uid -File |
    ForEach-Object { $_.Attributes = 'Hidden' }

# Function to create a watcher
function New-HiddenWatcher($filter) {
    $watcher = New-Object IO.FileSystemWatcher
    $watcher.Path = $projectPath
    $watcher.Filter = $filter
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true

    Register-ObjectEvent $watcher Created -Action {
        attrib +h $Event.SourceEventArgs.FullPath
    }
}

# Create watchers for both file types
New-HiddenWatcher "*.import"
New-HiddenWatcher "*.uid"

#Write-Host "Watching for new .import files in $projectPath..."
#while ($true) { Start-Sleep 5 }