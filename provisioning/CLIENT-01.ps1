#!/bin/pwsh

# Default vagrant share path
$VagrantDir = "C:\vagrant"
$VagrantScriptDir = "$VagrantDir\provisioning"

$LogFile          = "C:\Client-01-setup.log"

# ---------------------------------------------

# Log of the provisioning
Start-Transcript -Path $LogFile -Append

Write-Host "INFO: Starting Transcription in the log file: $LogFile" -BackgroundColor DarkCyan

# ---------------------------------------------

Write-Host "INFO: Starting Provisioning of this Windows Client" -BackgroundColor DarkCyan

Write-Host "INFO: Updating your system" -BackgroundColor DarkCyan


winget update --all --silent --accept-package-agreements --accept-source-agreements

Write-Host "INFO: Installing some very useful packages" -BackgroundColor DarkCyan

winget install -e --id Discord.Discord --Source winget --silent --accept-package-agreements --accept-source-agreements
winget install -e --id GOG.Galaxy --Source winget --silent --accept-package-agreements --accept-source-agreements
winget install -e --id RaspberryPiFoundation.RaspberryPiImager --Source winget --silent --accept-package-agreements --accept-source-agreements

# ---------------------------------------------


Write-Host "INFO: Finished provisioning your computer" -BackgroundColor DarkGreen
Write-Host "INFO: Thank you for using the script" -BackgroundColor DarkGreen

Stop-Transcript