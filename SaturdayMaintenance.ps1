# Script to automatically perform the Saturday Maintenance routine
[CmdletBinding()]
param (
    [Parameter()]
    [string[]]
    $DuplicacyUtilArgs,
    [Parameter()]
    [string]
    $DuplicacyUtilPath = "duplicacy-util",
    [Parameter()]
    [string[]]
    $RobocopySourceFolders,
    [Parameter()]
    [string[]]
    $RobocopyDestinationFolders
)

Write-Host "#####################"
Write-Host "Saturday maintenance Scrpt"
Write-Host "#####################"

UsbBackup.ps1 -DuplicacyUtilArgs $DuplicacyUtilArgs -RobocopySourceFolders $RobocopySourceFolders -RobocopyDestinationFolders $RobocopyDestinationFolders

if ($?) {
    scoop update *
}
else {
    exit 1;
}

if ($?) {
    InstallWindowsUpdates.ps1 
}
else {
    exit 1;
}


Write-Host "#####################"
Write-Host "Maintenance Complete!"
Write-Host "#####################"