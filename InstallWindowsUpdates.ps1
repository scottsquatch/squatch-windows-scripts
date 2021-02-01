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
$updates = Get-WindowsUpdate
log -msg "Finished Checking for updates"
if ($updates) {
    log -msg "Downloading Updates"
    Get-WindowsUpdate -Download -AcceptAll
    log -msg "Updates Downloaded"

    log -msg "Installing Updates"
    Install-WindowsUpdate -AcceptAll
    log -msg "Finished Installing Updates"
}
else {
    log -msg "System is up to date!"
}
