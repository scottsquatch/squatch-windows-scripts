# Script to display backups 
[CmdletBinding()]
param (
    [string[]]
    $Directories,
    [Parameter()]
    [string[]]
    $Storages
)

for ($i = 0; $i -lt $Directories.Length; $i++) {
    pushd $Directories[$i]
    duplicacy list -storage $Storages[$i]
    popd
}