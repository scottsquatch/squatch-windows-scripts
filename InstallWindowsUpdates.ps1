[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $moduleDir = "$HOME\Documents\WindowsPowerShell\Modules"
)

function log {
    param (
        [string]
        $msg
    )

    Write-Host ""
    Write-Host -ForegroundColor "green" "$msg";
    Write-Host ""
}

function ensureModuleDirExists {
    if (!(Test-Path "$moduleDir")) {
        log -msg "Module Directory does not exist, creating"
        New-Item -Path "$moduleDir" -ItemType Directory
        log -msg "Module Directory created"
    }
}

function installUpdateScriptIfNeeded {
    param (
        [string]
        $path
    )
    if (!(Test-Path "$path\PSWindowsUpdate")) {
        log -msg "PSWindowsUpdate is not installed, starting install"
        $zipPath = "$path\PSWindowsUpdate.zip";
        Invoke-WebRequest -Uri "https://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc/file/41459/47/PSWindowsUpdate.zip" -OutFile $zipPath 
        Expand-Archive -LiteralPath $zipPath -DestinationPath $path
        Remove-Item -Path $zipPath
        Import-Module PSWindowsUpdate
        log -msg "PSWindowsUpdate has been installed"
    }
}

Write-Host "#####################"
Write-Host "Windows Update Script"
Write-Host "#####################"

ensureModuleDirExists
installUpdateScriptIfNeeded -path "$moduleDir"

log -msg "Checking for Updates"
$updates = Start-WUScan -SearchCriteria "Type='Software' AND IsInstalled=0" # Scan for updates
log -msg "Finished Checking for updates"
if ($updates) {
    log -msg "Downloading Updates"
    Install-WUUpdates -Updates $upadates -DownloadOnly $true
    log -msg "Finished Downloading Updates"

    log -msg "Installing Updates"
    Install-WUUpdates -Updates $updates
    log -msg "Finished Installing Updates"

    $reboot = Get-WUIsPendingReboot
    if ($reboot) {
        $confirmation = Read-Host -Prompt "Windows Requires a restart, would you like to restart the computer now? [Y to continue]"
        if ($confirmation -eq "y" -or $confirmation -eq "Y") {
            log -msg "Restarting computer in 5 seconds"
            Start-Sleep -s 5
            Restart-Computer
        }
    }
    log -msg "Updates installed"
}
else {
    log -msg "System is up to date!"
}
