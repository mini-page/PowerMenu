# Advanced-PowerMenu.ps1
# An enhanced PowerShell menu system with extensive features
# Version: 2.0

# ===================================
# Configuration and Global Variables
# ===================================
$script:configFile = "$HOME\.powermenu_config.json"
$script:usageLogFile = "$HOME\.powermenu_usage.log"
$script:customCommandsFile = "$HOME\.powermenu_custom.json"

# Default Configuration
$script:config = @{
    ProjectsPath = "$HOME\Documents\Projects"
    RepoPath = "$HOME\Documents\Projects\MyRepo"
    WebSitePath = "$HOME\Documents\Projects\MySite"
    GitHubUsername = "yourusername"
    ColorScheme = @{
        Title = "Cyan"
        Category = "Blue"
        Success = "Green"
        Error = "Red"
        Warning = "Yellow"
        Prompt = "Magenta"
    }
    ConfirmDestructiveActions = $true
    LogCommandUsage = $true
}

# ===================================
# Function Definitions
# ===================================

function Initialize-PowerMenu {
    # Load configuration if exists
    if (Test-Path $script:configFile) {
        try {
            $loadedConfig = Get-Content $script:configFile | ConvertFrom-Json
            # Merge loaded config with default config
            foreach ($key in $loadedConfig.PSObject.Properties.Name) {
                if ($loadedConfig.$key -is [System.Management.Automation.PSCustomObject]) {
                    foreach ($subKey in $loadedConfig.$key.PSObject.Properties.Name) {
                        $script:config[$key][$subKey] = $loadedConfig.$key.$subKey
                    }
                } else {
                    $script:config[$key] = $loadedConfig.$key
                }
            }
        } catch {
            Write-Host "Error loading configuration. Using defaults." -ForegroundColor $script:config.ColorScheme.Error
        }
    } else {
        # Save default configuration
        Save-PowerMenuSettings
    }

    # Load custom commands if they exist
    $script:customCommands = @()
    if (Test-Path $script:customCommandsFile) {
        try {
            $script:customCommands = Get-Content $script:customCommandsFile | ConvertFrom-Json
        } catch {
            Write-Host "Error loading custom commands." -ForegroundColor $script:config.ColorScheme.Error
        }
    }
}

function Save-PowerMenuSettings {
    try {
        $script:config | ConvertTo-Json -Depth 3 | Out-File $script:configFile
        Write-Host "Settings saved successfully!" -ForegroundColor $script:config.ColorScheme.Success
    } catch {
        Write-Host "Failed to save settings: $_" -ForegroundColor $script:config.ColorScheme.Error
    }
}

function Show-MainMenu {
    param(
        [switch]$ClearScreen = $true
    )
    
    if ($ClearScreen) {
        Clear-Host
    }
    
    Write-Host "=== ⚡ Advanced Power Menu ===" -ForegroundColor $script:config.ColorScheme.Title
    Write-Host ""

    # Display menu categories and items
    Show-MenuCategory "Developer Tools" @(
        "Launch VSCode",
        "Start Web Server",
        "Pull Latest Git Repo",
        "Generate SSH Key",
        "Run NPM/Yarn Script",
        "Launch Python",
        "Launch MongoDB Compass",
        "Open Postman"
    ) 1
    
    Show-MenuCategory "System & Utilities" @(
        "Run System Cleanup",
        "Start Docker Container",
        "Open Docker Desktop",
        "Clear Recycle Bin",
        "Clear DNS Cache",
        "View Disk Usage",
        "View Installed Software",
        "Show System Uptime",
        "Display System Info",
        "Edit PowerShell Profile",
        "View Environment Variables"
    ) 9
    
    Show-MenuCategory "File & Directory Tools" @(
        "Open Projects Folder",
        "Backup Important Files",
        "Use fzf File Search",
        "Use zoxide for Directory Jump",
        "Open Recent Projects (fzf)"
    ) 20
    
    Show-MenuCategory "Networking" @(
        "View WiFi Profiles (with Passwords)",
        "View Firewall Status",
        "Trace Route",
        "Ping a Host",
        "Show IP Configuration",
        "Toggle WiFi Adapter"
    ) 25
    
    Show-MenuCategory "Process Management" @(
        "List Running Processes",
        "Open Task Manager",
        "Check Port Usage",
        "View Scheduled Tasks"
    ) 31
    
    Show-MenuCategory "Package Managers" @(
        "Run Winget Upgrade",
        "Install App via Winget",
        "Search App via Winget",
        "Update Scoop Packages",
        "Uninstall App by Name"
    ) 35
    
    Show-MenuCategory "Apps & Web" @(
        "Open GitHub",
        "Open Google Chrome",
        "Open YouTube",
        "Open Spotify",
        "Open Discord",
        "Open Steam"
    ) 40
    
    Show-MenuCategory "Productivity & Fun" @(
        "Use TLDR",
        "Open Notepad for Quick Notes",
        "Schedule Shutdown/Restart",
        "Download File from URL",
        "Random Quote Generator",
        "Play a Sound"
    ) 46
    
    Show-MenuCategory "Admin Tools" @(
        "Launch Admin PowerShell",
        "Open WSL (Ubuntu)"
    ) 52

    Show-MenuCategory "Custom Commands" $script:customCommands.Name 100

    # Settings and exit options
    Write-Host "=== Settings & System ===" -ForegroundColor $script:config.ColorScheme.Category
    Write-Host "95. Add Custom Command"
    Write-Host "96. Edit PowerMenu Settings"
    Write-Host "97. View Command Usage Log"
    Write-Host "98. Clear Screen"
    Write-Host "99. Show Help"
    Write-Host "54. Exit" -ForegroundColor $script:config.ColorScheme.Warning
    Write-Host ""
    
    $choice = Read-Host "Choose an option (1-54, 95-99)"
    return $choice
}

function Show-MenuCategory {
    param(
        [string]$Category,
        [array]$Items,
        [int]$StartIndex
    )
    
    Write-Host "=== $Category ===" -ForegroundColor $script:config.ColorScheme.Category
    
    for ($i = 0; $i -lt $Items.Count; $i++) {
        $index = $StartIndex + $i
        Write-Host "$index. $($Items[$i])"
    }
    
    Write-Host ""
}

function Execute-Command {
    param(
        [string]$CommandId
    )
    
    # Log command usage if enabled
    if ($script:config.LogCommandUsage) {
        Log-CommandUsage $CommandId
    }

    # Execute the appropriate command based on the ID
    switch ($CommandId) {
        # === Developer Tools ===
        '1' { Start-DevTool "Visual Studio Code" "code ." }
        '2' { 
            try {
                $webServerPath = $script:config.WebSitePath
                Write-Host "Starting web server in $webServerPath..." -ForegroundColor $script:config.ColorScheme.Warning -NoNewline
                Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$webServerPath'; python -m http.server" -WindowStyle Normal -ErrorAction Stop
                Write-Host " Done!" -ForegroundColor $script:config.ColorScheme.Success
            } catch {
                Write-Host " Failed!" -ForegroundColor $script:config.ColorScheme.Error
                Write-Host "Error: $_" -ForegroundColor $script:config.ColorScheme.Error
            }
        }
        '3' { 
            try {
                $repoPath = $script:config.RepoPath
                Write-Host "Pulling latest changes in $repoPath..." -ForegroundColor $script:config.ColorScheme.Warning -NoNewline
                Set-Location $repoPath
                git pull 2>&1 | Out-String | Write-Host
                Write-Host "Git pull completed!" -ForegroundColor $script:config.ColorScheme.Success
            } catch {
                Write-Host "Failed to pull Git repository: $_" -ForegroundColor $script:config.ColorScheme.Error
            }
        }
        '4' { 
            try {
                $keyType = Read-Host "Enter key type (rsa, ed25519)"
                $keyBits = Read-Host "Enter key bits (e.g., 4096 for RSA)"
                $keyComment = Read-Host "Enter comment (email/identifier)"
                
                Write-Host "Generating SSH key..." -ForegroundColor $script:config.ColorScheme.Warning -NoNewline
                ssh-keygen -t $keyType -b $keyBits -C $keyComment
                Write-Host " Done!" -ForegroundColor $script:config.ColorScheme.Success
            } catch {
                Write-Host " Failed!" -ForegroundColor $script:config.ColorScheme.Error
                Write-Host "Error: $_" -ForegroundColor $script:config.ColorScheme.Error
            }
        }
        '5' { 
            try {
                if (Test-Path "package.json") {
                    $packageJson = Get-Content "package.json" | ConvertFrom-Json
                    Write-Host "Available scripts:" -ForegroundColor $script:config.ColorScheme.Prompt
                    $packageJson.scripts.PSObject.Properties | ForEach-Object {
                        Write-Host "  $($_.Name): $($_.Value)"
                    }
                    
                    $scriptName = Read-Host "Enter script name to run"
                    if ($packageJson.scripts.PSObject.Properties.Name -contains $scriptName) {
                        $packageManager = if (Test-Path "yarn.lock") { "yarn" } else { "npm" }
                        Write-Host "Running $scriptName using $packageManager..." -ForegroundColor $script:config.ColorScheme.Warning
                        & $packageManager $scriptName
                    } else {
                        Write-Host "Script not found in package.json" -ForegroundColor $script:config.ColorScheme.Error
                    }
                } else {
                    Write-Host "No package.json found in current directory" -ForegroundColor $script:config.ColorScheme.Error
                }
            } catch {
                Write-Host "Error: $_" -ForegroundColor $script:config.ColorScheme.Error
            }
        }
        '6' { Start-DevTool "Python" "python" }
        '7' { Start-DevTool "MongoDB Compass" "MongoDBCompass" }
        '8' { Start-DevTool "Postman" "Postman" }
        
        # === System & Utilities ===
        '9' { 
            Write-Host "Cleaning system temporary files..." -ForegroundColor $script:config.ColorScheme.Warning -NoNewline
            try {
                Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host " Done!" -ForegroundColor $script:config.ColorScheme.Success
            } catch {
                Write-Host " Error occurred!" -ForegroundColor $script:config.ColorScheme.Error
                Write-Host $_ -ForegroundColor $script:config.ColorScheme.Error
            }
        }
        '10' { 
            $containerName = Read-Host "Enter container name to start"
            if (Test-Command "docker") {
                Write-Host "Starting Docker container $containerName..." -ForegroundColor $script:config.ColorScheme.Warning -NoNewline
                try {
                    docker start $containerName
                    Write-Host " Done!" -ForegroundColor $script:config.ColorScheme.Success
                } catch {
                    Write-Host " Failed!" -ForegroundColor $script:config.ColorScheme.Error
                    Write-Host "Error: $_" -ForegroundColor $script:config.ColorScheme.Error
                }
            } else {
                Write-Host "Docker is not installed or not in PATH" -ForegroundColor $script:config.ColorScheme.Error
            }
        }
        '11' { Start-DevTool "Docker Desktop" "Docker Desktop" }
        '12' { 
            if ($script:config.ConfirmDestructiveActions) {
                $confirm = Read-Host "Are you sure you want to clear the Recycle Bin? (y/n)"
                if ($confirm -ne 'y') {
                    return
                }
            }
            
            Write-Host "Clearing Recycle Bin..." -ForegroundColor $script:config.ColorScheme.Warning -NoNewline
            try {
                Clear-RecycleBin -Force -ErrorAction Stop
                Write-Host " Done!" -ForegroundColor $script:config.ColorScheme.Success
            } catch {
                Write-Host " Failed!" -ForegroundColor $script:config.ColorScheme.Error
                Write-Host "Error: $_" -ForegroundColor $script:config.ColorScheme.Error
            }
        }
        '13' { 
            Write-Host "Flushing DNS cache..." -ForegroundColor $script:config.ColorScheme.Warning -NoNewline
            try {
                ipconfig /flushdns | Out-Null
                Write-Host " Done!" -ForegroundColor $script:config.ColorScheme.Success
            } catch {
                Write-Host " Failed!" -ForegroundColor $script:config.ColorScheme.Error
            }
        }
        '14' { Get-PSDrive | Where-Object { $_.Provider.Name -eq "FileSystem" } | Format-Table -AutoSize }
        '15' { 
            if (Test-Command "winget") {
                Write-Host "Fetching installed software (this may take a moment)..." -ForegroundColor $script:config.ColorScheme.Warning
                winget list
            } else {
                Write-Host "Winget is not installed or not in PATH" -ForegroundColor $script:config.ColorScheme.Error
            }
        }
        '16' { 
            $bootTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
            $uptime = (Get-Date) - $bootTime
            Write-Host "System has been running for:" -ForegroundColor $script:config.ColorScheme.Prompt
            Write-Host "$($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes" -ForegroundColor $script:config.ColorScheme.Success
        }
        '17' { systeminfo }
        '18' { 
            if (Test-Path $PROFILE) {
                notepad $PROFILE
            } else {
                Write-Host "PowerShell profile doesn't exist. Create it? (y/n)" -ForegroundColor $script:config.ColorScheme.Prompt
                $createProfile = Read-Host
                if ($createProfile -eq 'y') {
                    New-Item -Path $PROFILE -ItemType File -Force
                    notepad $PROFILE
                }
            }
        }
        '19' { Get-ChildItem Env: | Sort-Object Name | Format-Table -AutoSize }
        
        # === File & Directory Tools ===
        '20' { 
            $projectsPath = $script:config.ProjectsPath
            Write-Host "Opening $projectsPath..." -ForegroundColor $script:config.ColorScheme.Warning -NoNewline
            try {
                Set-Location $projectsPath
                explorer .
                Write-Host " Done!" -ForegroundColor $script:config.ColorScheme.Success
            } catch {
                Write-Host " Failed!" -ForegroundColor $script:config.ColorScheme.Error
                Write-Host "Error: $_" -ForegroundColor $script:config.ColorScheme.Error
            }
        }
        '21' { 
            $sourceDir = Read-Host "Enter source directory to backup"
            $destDir = Read-Host "Enter destination directory"
            
            if (-not (Test-Path $sourceDir)) {
                Write-Host "Source directory doesn't exist!" -ForegroundColor $script:config.ColorScheme.Error
                return
            }
            
            if (-not (Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            
            Write-Host "Backing up files from $sourceDir to $destDir..." -ForegroundColor $script:config.ColorScheme.Warning -NoNewline
            try {
                Copy-Item -Path "$sourceDir\*" -Destination $destDir -Recurse -Force
                Write-Host " Done!" -ForegroundColor $script:config.ColorScheme.Success
            } catch {
                Write-Host " Failed!" -ForegroundColor $script:config.ColorScheme.Error
                Write-Host "Error: $_" -ForegroundColor $script:config.ColorScheme.Error
            }
        }
        '22' { 
            if (Test-Command "fzf") {
                Write-Host "Starting fzf file search..." -ForegroundColor $script:config.ColorScheme.Warning
                try {
                    $selection = Get-ChildItem -Recurse | Where-Object { -not $_.PSIsContainer } | Select-Object -ExpandProperty FullName | fzf
                    if ($selection) {
                        Write-Host "Selected: $selection" -ForegroundColor $script:config.ColorScheme.Success
                        Start-Process $selection
                    }
                } catch {
                    Write-Host "Error: $_" -ForegroundColor $script:config.ColorScheme.Error
                }
            } else {
                Write-Host "fzf is not installed or not in PATH" -ForegroundColor $script:config.ColorScheme.Error
                Write-Host "Install it with: 'scoop install fzf' or 'winget install fzf'" -ForegroundColor $script:config.ColorScheme.Prompt
            }
        }
        '23' { 
            if (Test-Command "z") {
                Write-Host "Starting zoxide directory jump..." -ForegroundColor $script:config.ColorScheme.Warning
                z
            } else {
                Write-Host "zoxide is not installed or not in PATH" -ForegroundColor $script:config.ColorScheme.Error
                Write-Host "Install it with: 'scoop install zoxide' or 'winget install zoxide'" -ForegroundColor $script:config.ColorScheme.Prompt
            }
        }
        '24' { 
            $projectsPath = $script:config.ProjectsPath
            if (Test-Command "fzf") {
                Write-Host "Select a recent project:" -ForegroundColor $script:config.ColorScheme.Prompt
                try {
                    $selection = Get-ChildItem -Path $projectsPath -Directory | Sort-Object LastWriteTime -Descending | Select-Object -ExpandProperty FullName | fzf
                    if ($selection) {
                        Set-Location $selection
                        Write-Host "Changed to: $selection" -ForegroundColor $script:config.ColorScheme.Success
                        explorer .
                    }
                } catch {
                    Write-Host "Error: $_" -ForegroundColor $script:config.ColorScheme.Error
                }
            } else {
                Write-Host "fzf is not installed or not in PATH" -ForegroundColor $script:config.ColorScheme.Error
            }
        }
        
        # === Networking ===
        '25' { 
            Write-Host "Getting WiFi profiles..." -ForegroundColor $script:config.ColorScheme.Warning
            netsh wlan show profiles
            
            $profileName = Read-Host "Enter profile name to see password"
            if ($profileName) {
                Write-Host "Getting password for $profileName..." -ForegroundColor $script:config.ColorScheme.Warning
                netsh wlan show profile name="$profileName" key=clear
            }
        }
        '26' { 
            Write-Host "Getting firewall status..." -ForegroundColor $script:config.ColorScheme.Warning
            netsh advfirewall show allprofiles 
        }
        '27' { 
            $host = Read-Host "Enter host to trace"
            if ($host) {
                Write-Host "Tracing route to $host..." -ForegroundColor $script:config.ColorScheme.Warning
                tracert $host
            }
        }
        '28' { 
            $host = Read-Host "Enter host to ping"
            if ($host) {
                Write-Host "Pinging $host..." -ForegroundColor $script:config.ColorScheme.Warning
                ping $host
            }
        }
        '29' { 
            Write-Host "Getting IP configuration..." -ForegroundColor $script:config.ColorScheme.Warning
            ipconfig /all 
        }
        '30' { 
            Write-Host "Getting network adapters..." -ForegroundColor $script:config.ColorScheme.Warning
            $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
            $adapters | Format-Table -AutoSize
            
            if ($adapters.Count -gt 0) {
                if ($script:config.ConfirmDestructiveActions) {
                    $confirm = Read-Host "Are you sure you want to toggle WiFi adapter? (y/n)"
                    if ($confirm -ne 'y') {
                        return
                    }
                }
                
                $adapterIndex = Read-Host "Enter adapter index to toggle"
                $selectedAdapter = $adapters | Where-Object { $_.ifIndex -eq $adapterIndex }
                
                if ($selectedAdapter) {
                    Write-Host "Toggling adapter $($selectedAdapter.Name)..." -ForegroundColor $script:config.ColorScheme.Warning -NoNewline
                    try {
                        Disable-NetAdapter -Name $selectedAdapter.Name -Confirm:$false -ErrorAction Stop
                        Write-Host " Disabled!" -ForegroundColor $script:config.ColorScheme.Success
                        Start-Sleep -Seconds 1
                        Enable-NetAdapter -Name $selectedAdapter.Name -Confirm:$false -ErrorAction Stop
                        Write-Host "Adapter re-enabled!" -ForegroundColor $script:config.ColorScheme.Success
                    } catch {
                        Write-Host " Failed!" -ForegroundColor $script:config.ColorScheme.Error
                        Write-Host "Error: $_" -ForegroundColor $script:config.ColorScheme.Error
                    }
                } else {
                    Write-Host "Invalid adapter index" -ForegroundColor $script:config.ColorScheme.Error
                }
            } else {
                Write-Host "No active network adapters found" -ForegroundColor $script:config.ColorScheme.Error
            }
        }
        
        # === Process Management ===
        '31' { 
            Write-Host "Getting top processes by CPU usage..." -ForegroundColor $script:config.ColorScheme.Warning
            Get-Process | Sort-Object CPU -Descending | Select-Object -First 15 Name, ID, CPU, WorkingSet | Format-Table -AutoSize
            
            $filter = Read-Host "Enter process name filter (optional)"
            if ($filter) {
                Get-Process | Where-Object { $_.Name -like "*$filter*" } | Format-Table -AutoSize
            }
        }
        '32' { Start-Process taskmgr }
        '33' { 
            Write-Host "Getting port usage information..." -ForegroundColor $script:config.ColorScheme.Warning
            $portInfo = netstat -ano
            $portInfo | Out-Host
            
            $pid = Read-Host "Enter PID to get process info (optional)"
            if ($pid) {
                try {
                    $process = Get-Process -Id $pid -ErrorAction Stop
                    Write-Host "Process: $($process.Name) (ID: $($process.Id))" -ForegroundColor $script:config.ColorScheme.Success
                    Write-Host "Path: $($process.Path)" -ForegroundColor $script:config.ColorScheme.Success
                } catch {
                    Write-Host "Process not found or access denied" -ForegroundColor $script:config.ColorScheme.Error
                }
            }
        }
        '34' { 
            Write-Host "Getting scheduled tasks..." -ForegroundColor $script:config.ColorScheme.Warning
            schtasks /query /fo LIST /v 
        }
        
        # === Package Managers ===
        '35' { 
            if (Test-Command "winget") {
                Write-Host "Checking for application updates..." -ForegroundColor $script:config.ColorScheme.Warning
                winget upgrade
                
                if ($script:config.ConfirmDestructiveActions) {
                    $confirm = Read-Host "Do you want to upgrade all packages? (y/n)"
                    if ($confirm -eq 'y') {
                        Write-Host "Upgrading all packages..." -ForegroundColor $script:config.ColorScheme.Warning
                        winget upgrade --all
                    }
                } else {
                    Write-Host "Upgrading all packages..." -ForegroundColor $script:config.ColorScheme.Warning
                    winget upgrade --all
                }
            } else {
                Write-Host "Winget is not installed or not in PATH" -ForegroundColor $script:config.ColorScheme.Error
            }
        }
        '36' { 
            if (Test-Command "winget") {
                $app = Read-Host "Enter app name to install"
                if ($app) {
                    Write-Host "Searching for $app..." -ForegroundColor $script:config.ColorScheme.Warning
                    winget search $app
                    
                    $installId = Read-Host "Enter exact ID to install"
                    if ($installId) {
                        Write-Host "Installing $installId..." -ForegroundColor $script:config.ColorScheme.Warning
                        winget install --id $installId
                    }
                }
            } else {
                Write-Host "Winget is not installed or not in PATH" -ForegroundColor $script:config.ColorScheme.Error
            }
        }
        '37' { 
            if (Test-Command "winget") {
                $app = Read-Host "Enter app name to search"
                if ($app) {
                    Write-Host "Searching for $app..." -ForegroundColor $script:config.ColorScheme.Warning
                    winget search $app
                }
            } else {
                Write-Host "Winget is not installed or not in PATH" -ForegroundColor $script:config.ColorScheme.Error
            }
        }
        '38' { 
            if (Test-Command "scoop") {
                Write-Host "Updating Scoop and all packages..." -ForegroundColor $script:config.ColorScheme.Warning
                scoop update
                scoop update *
            } else {
                Write-Host "Scoop is not installed or not in PATH" -ForegroundColor $script:config.ColorScheme.Error
                Write-Host "Install it with: 'iwr -useb get.scoop.sh | iex'" -ForegroundColor $script:config.ColorScheme.Prompt
            }
        }
        '39' { 
            if (Test-Command "winget") {
                $app = Read-Host "Enter app name to uninstall"
                if ($app) {
                    Write-Host "Searching for installed apps matching '$app'..." -ForegroundColor $script:config.ColorScheme.Warning
                    winget list $app
                    
                    $uninstallId = Read-Host "Enter exact ID to uninstall"
                    if ($uninstallId) {
                        if ($script:config.ConfirmDestructiveActions) {
                            $confirm = Read-Host "Are you sure you want to uninstall $uninstallId? (y/n)"
                            if ($confirm -ne 'y') {
                                return
                            }
                        }
                        
                        Write-Host "Uninstalling $uninstallId..." -ForegroundColor $script:config.ColorScheme.Warning
                        winget uninstall --id $uninstallId
                    }
                }
            } else {
                Write-Host "Winget is not installed or not in PATH" -ForegroundColor $script:config.ColorScheme.Error
            }
        }
        
        # === Apps & Web ===
        '40' { 
            $url = "https://github.com/$($script:config.GitHubUsername)"
            Start-Process $url 
        }
        '41' { Start-DevTool "Google Chrome" "chrome" }
        '42' { Start-Process "https://youtube.com" }
        '43' { Start-DevTool "Spotify" "spotify" }
        '44' { Start-DevTool "Discord" "discord" }
        '45' { Start-DevTool "Steam" "steam" }
        
        # === Productivity & Fun ===
        '46' { 
            if (Test-Command "tldr") {
                $command = Read-Host "Enter command name (or blank for random)"
                if ($command) {
                    Write-Host "Getting TLDR for $command..." -ForegroundColor $script:config.ColorScheme.Warning
                    tldr $command
                } else {
                    Write-Host "Getting random TLDR..." -ForegroundColor $script:config.ColorScheme.Warning
                    tldr --random
                }
            } else {
                Write-Host "TLDR is not installed or not in PATH" -ForegroundColor $script:config.ColorScheme.Error
                Write-Host "Install it with: 'npm install -g tldr' or 'scoop install tldr'" -ForegroundColor $script:config.ColorScheme.Prompt
            }
        }
        '47' { Start-DevTool "Notepad" "notepad" }
        '48' { 
            $action = Read-Host "Choose action (s=shutdown, r=restart, c=cancel)"
            $timeInMinutes = Read-Host "Enter time in minutes"
            
            try {
                $timeInSeconds = [int]$timeInMinutes * 60
                
                switch ($action) {
                    's' { 
                        shutdown /s /t $timeInSeconds 
                        Write-Host "Shutdown scheduled in $timeInMinutes minutes" -ForegroundColor $script:config.ColorScheme.Success
                    }
                    'r' { 
                        shutdown /r /t $timeInSeconds 
                        Write-Host "Restart scheduled in $timeInMinutes minutes" -ForegroundColor $script:config.ColorScheme.Success
                    }
                    'c' { 
                        shutdown /a 
                        Write-Host "Scheduled shutdown/restart canceled" -ForegroundColor $script:config.ColorScheme.Success
                    }
                    default { Write-Host "Invalid action" -ForegroundColor $script:config.ColorScheme.Error }
                }
            } catch {
                Write-Host "Invalid time format" -ForegroundColor $script:config.ColorScheme.Error
            }
        }
        '49' { 
            $url = Read-Host "Enter URL to download file"
            $outPath = Read-Host "Enter output path (with filename)"
            
            if ($url -and $outPath) {
                Write-Host "Downloading from $url to $outPath..." -ForegroundColor $script:config.ColorScheme.Warning -NoNewline
                try {
                    Invoke-WebRequest -Uri $url -OutFile $outPath -ErrorAction Stop
                    Write-Host " Done!" -ForegroundColor $script:config.ColorScheme.Success
                } catch {
                    Write-Host " Failed!" -ForegroundColor $script:config.ColorScheme.Error
                    Write-Host "Error: $_" -ForegroundColor $script:config.ColorScheme.Error
                }
            }
        }
        '50' { 
            $quotes = @(
                "Be yourself; everyone else is already taken. - Oscar Wilde",
                "Two things are infinite: the universe and human stupidity; and I'm not sure about the universe. - Albert Einstein",
                "The best way to predict the future is to create it. - Abraham Lincoln",
                "The only way to do great work is to love what you do. - Steve Jobs",
                "Life is what happens when you're busy making other plans. - John Lennon",
                "The purpose of our lives is to be happy. - Dalai Lama",
                "Get busy living or get busy dying. - Stephen King",
                "You only live once, but if you do it right, once is enough. - Mae West",
                "Success is not final, failure is not fatal: It is the courage to continue that counts. - Winston Churchill",
                "The secret of getting ahead is getting started. - Mark Twain"
            )
            
            $randomIndex = Get-Random -Minimum 0 -Maximum $quotes.Count
            Write-Host $quotes[$randomIndex] -ForegroundColor $script:config.ColorScheme.Success
        }
        '51' { 
            [console]::beep(500, 300)
            [console]::beep(600, 200)
            [console]::beep(700, 300)
            [console]::beep(800, 500)
            Write-Host "Sound played!" -ForegroundColor $script:config.ColorScheme.Success
        }
        
        # === Admin Tools ===
        '52' { Start-Process powershell -Verb RunAs }
        '53' { 
            if (Get-Command wsl -ErrorAction SilentlyContinue) {
                Write-Host "Starting WSL (Ubuntu)..." -ForegroundColor $script:config.ColorScheme.Warning
                wsl -d Ubuntu
            } else {
                Write-Host "WSL is not installed or Ubuntu distribution is not available" -ForegroundColor $script:config.ColorScheme.Error
            }
        }
        
        # Exit
        '54' { return $false }
        
        # === Settings & System ===
        '95' { Add-CustomCommand }
        '96' { Edit-PowerMenuSettings }
        '97' { View-CommandUsageLog }
        '98' { return $true }  # Refresh/clear screen
        '99' { Show-Help }
        
        # Custom Commands (100+)
        default {
            $customCommandIndex = [int]$CommandId - 100
            if ($customCommandIndex -ge 0 -and $customCommandIndex -lt $script:customCommands.Count) {
                try {
                    $command = $script:customCommands[$customCommandIndex].Command
                    Write-Host "Executing custom command: $($script:customCommands[$customCommandIndex].Name)" -ForegroundColor $script:config.ColorScheme.Warning
                    Invoke-Expression $command
                } catch {
                    Write-Host "Error executing custom command: $_" -ForegroundColor $script:config.ColorScheme.Error
                }
            } else {
                Write-Host "Invalid option selected" -ForegroundColor $script:config.ColorScheme.Error
            }
        }
    }
    
    if ($CommandId -ne '98') {  # If not clearing screen
        Write-Host ""
        Read-Host "Press Enter to continue"
    }
    
    return $true
}

function Start-DevTool {
    param(
        [string]$Name,
        [string]$Command
    )
    
    Write-Host "Starting $Name..." -ForegroundColor $script:config.ColorScheme.Warning -NoNewline
    try {
        Start-Process $Command -ErrorAction Stop
        Write-Host " Done!" -ForegroundColor $script:config.ColorScheme.Success
    } catch {
        Write-Host " Failed!" -ForegroundColor $script:config.ColorScheme.Error
        Write-Host "Error: $Command may not be installed or not in PATH" -ForegroundColor $script:config.ColorScheme.Error
    }
}

function Test-Command {
    param(
        [string]$CommandName
    )
    
    if (Get-Command $CommandName -ErrorAction SilentlyContinue) {
        return $true
    } else {
        return $false
    }
}

function Log-CommandUsage {
    param(
        [string]$CommandId
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - Command ID: $CommandId"
    Add-Content -Path $script:usageLogFile -Value $logEntry
}

function Add-CustomCommand {
    $name = Read-Host "Enter a name for the custom command"
    if ([string]::IsNullOrWhiteSpace($name)) {
        Write-Host "Command name cannot be empty" -ForegroundColor $script:config.ColorScheme.Error
        return
    }
    
    $command = Read-Host "Enter the PowerShell command or script to execute"
    if ([string]::IsNullOrWhiteSpace($command)) {
        Write-Host "Command cannot be empty" -ForegroundColor $script:config.ColorScheme.Error
        return
    }
    
    $newCommand = @{
        Name = $name
        Command = $command
    }
    
    $script:customCommands += $newCommand
    
    try {
        $script:customCommands | ConvertTo-Json -Depth 3 | Out-File $script:customCommandsFile
        Write-Host "Custom command added successfully!" -ForegroundColor $script:config.ColorScheme.Success
    } catch {
        Write-Host "Failed to save custom command: $_" -ForegroundColor $script:config.ColorScheme.Error
    }
}

function Edit-PowerMenuSettings {
    Write-Host "=== PowerMenu Settings ===" -ForegroundColor $script:config.ColorScheme.Title
    Write-Host ""
    
    Write-Host "1. Paths" -ForegroundColor $script:config.ColorScheme.Category
    Write-Host "2. Color Scheme" -ForegroundColor $script:config.ColorScheme.Category
    Write-Host "3. Behavior Settings" -ForegroundColor $script:config.ColorScheme.Category
    Write-Host "4. GitHub Username" -ForegroundColor $script:config.ColorScheme.Category
    Write-Host "5. Return to Main Menu" -ForegroundColor $script:config.ColorScheme.Warning
    Write-Host ""
    
    $choice = Read-Host "Choose an option (1-5)"
    
    switch ($choice) {
        '1' {
            $script:config.ProjectsPath = Read-Host "Enter Projects Path (current: $($script:config.ProjectsPath))"
            $script:config.RepoPath = Read-Host "Enter Repository Path (current: $($script:config.RepoPath))"
            $script:config.WebSitePath = Read-Host "Enter Website Path (current: $($script:config.WebSitePath))"
            Save-PowerMenuSettings
        }
        '2' {
            Write-Host "Available colors: Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray, DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White" -ForegroundColor $script:config.ColorScheme.Prompt
            
            $script:config.ColorScheme.Title = Read-Host "Enter Title Color (current: $($script:config.ColorScheme.Title))"
            $script:config.ColorScheme.Category = Read-Host "Enter Category Color (current: $($script:config.ColorScheme.Category))"
            $script:config.ColorScheme.Success = Read-Host "Enter Success Color (current: $($script:config.ColorScheme.Success))"
            $script:config.ColorScheme.Error = Read-Host "Enter Error Color (current: $($script:config.ColorScheme.Error))"
            $script:config.ColorScheme.Warning = Read-Host "Enter Warning Color (current: $($script:config.ColorScheme.Warning))"
            $script:config.ColorScheme.Prompt = Read-Host "Enter Prompt Color (current: $($script:config.ColorScheme.Prompt))"
            Save-PowerMenuSettings
        }
        '3' {
            $confirmValue = Read-Host "Confirm Destructive Actions (current: $($script:config.ConfirmDestructiveActions)) (true/false)"
            if ($confirmValue -eq "true" -or $confirmValue -eq "false") {
                $script:config.ConfirmDestructiveActions = [System.Convert]::ToBoolean($confirmValue)
            }
            
            $logValue = Read-Host "Log Command Usage (current: $($script:config.LogCommandUsage)) (true/false)"
            if ($logValue -eq "true" -or $logValue -eq "false") {
                $script:config.LogCommandUsage = [System.Convert]::ToBoolean($logValue)
            }
            
            Save-PowerMenuSettings
        }
        '4' {
            $script:config.GitHubUsername = Read-Host "Enter GitHub Username (current: $($script:config.GitHubUsername))"
            Save-PowerMenuSettings
        }
        '5' { return }
    }
}

function View-CommandUsageLog {
    if (Test-Path $script:usageLogFile) {
        Write-Host "=== Command Usage Log ===" -ForegroundColor $script:config.ColorScheme.Title
        Get-Content $script:usageLogFile | Select-Object -Last 20 | ForEach-Object {
            Write-Host $_ -ForegroundColor $script:config.ColorScheme.Prompt
        }
        
        $clearOption = Read-Host "Clear log? (y/n)"
        if ($clearOption -eq 'y') {
            Remove-Item $script:usageLogFile -Force
            Write-Host "Log cleared!" -ForegroundColor $script:config.ColorScheme.Success
        }
    } else {
        Write-Host "No usage log found" -ForegroundColor $script:config.ColorScheme.Error
    }
}

function Show-Help {
    Write-Host "=== Advanced PowerMenu Help ===" -ForegroundColor $script:config.ColorScheme.Title
    Write-Host ""
    Write-Host "The Advanced PowerMenu is a comprehensive tool that provides quick access to common" -ForegroundColor $script:config.ColorScheme.Prompt
    Write-Host "developer tools, system utilities, networking commands, and more." -ForegroundColor $script:config.ColorScheme.Prompt
    Write-Host ""
    Write-Host "Main Features:" -ForegroundColor $script:config.ColorScheme.Category
    Write-Host "- Developer Tools: Quick access to development environments and tools"
    Write-Host "- System Utilities: System management and maintenance tools"
    Write-Host "- File & Directory Tools: File operations and directory navigation"
    Write-Host "- Networking: Network diagnostics and configuration"
    Write-Host "- Process Management: Monitor and manage running processes"
    Write-Host "- Package Managers: Software installation and updates"
    Write-Host "- Custom Commands: Create your own shortcuts for frequently used commands"
    Write-Host ""
    Write-Host "Configuration:" -ForegroundColor $script:config.ColorScheme.Category
    Write-Host "- All settings are stored in: $script:configFile"
    Write-Host "- Custom commands are stored in: $script:customCommandsFile"
    Write-Host "- Usage logs are stored in: $script:usageLogFile"
    Write-Host ""
    Write-Host "Tips:" -ForegroundColor $script:config.ColorScheme.Category
    Write-Host "- To add a custom command, select option 95 from the main menu"
    Write-Host "- To modify menu settings, select option 96 from the main menu"
    Write-Host "- Press Ctrl+C to exit at any time"
    Write-Host ""
}

# ===================================
# Main Script Entry Point
# ===================================

# Initialize settings and load configuration
Initialize-PowerMenu

# Main application loop
$continue = $true
while ($continue) {
    $choice = Show-MainMenu
    $continue = Execute-Command $choice
}

Write-Host "Exiting Advanced PowerMenu. Goodbye!" -ForegroundColor $script:config.ColorScheme.Title