function log {
    param (
        [string]
        $msg
    )

    Write-Host ""
    Write-Host -ForegroundColor "green" "$msg";
    Write-Host ""
}

function installUpdateScriptIfNeeded {
    if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        log -msg "PSWindowsUpdate is not installed, starting install"
        Install-Module -Name PSWindowsUpdate
        log -msg "PSWindowsUpdate has been installed"
    }
}

Write-Host "#####################"
Write-Host "Windows Update Script"
Write-Host "#####################"

installUpdateScriptIfNeeded 

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
