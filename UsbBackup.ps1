# One stop script to backup to/from USB
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

function DuplicacyBackup {
    param (
        [string[]]
        $cmd_args,
        [string]
        $duplicacy_util_path
    )
    Write-Output "###############################"
    Write-Output "Start duplicacy backups"
    Write-Output "###############################"
    Write-Output ""
    foreach ($cmd_arg in $cmd_args) {
        Write-Output "Start backup for with command $cmd_arg"
        $cmd = "$duplicacy_util_path $cmd_arg";
        Invoke-Expression $cmd
        if ($?) {
            Write-Output "Great Success!";
        }
        else {
            Write-Error "Backup failed please see console output";
            exit 1;
        }
    }
    
    Write-Output "###############################"
    Write-Output "End duplicacy backups"
    Write-Output "###############################"
    Write-Output ""
}

function RobocopyBackup {
    param (
        [string[]]
        $arSourceFolders,
        [string[]]
        $arDestinationFolders
    )
    # Section taken from https://gist.github.com/frndlyy/e7e51d3acddee51c4e42d0ee9bbe0dc0#file-filefolder_robocopy_withpowershell-ps1 and modified
    Write-Output "###############################"
    Write-Output "Start robocopy backup"
    Write-Output "###############################"
    Write-Output ""

    for ($i = 0; $i -lt $arSourceFolders.Length; $i++) {
        $src = $arSourceFolders[$i]
        $dst = $arDestinationFolders[$i]
        Write-Output "Copy $src to $dst" ;
        robocopy $src $dst /COPYALL /E /R:0 /xo
        Write-Output "Great Success!";
    }

    Write-Output "###############################"
    Write-Output "End robocopy backup"
    Write-Output "###############################"
    Write-Output ""
}

if ($DuplicacyUtilArgs.Length -gt 0) {
    DuplicacyBackup -cmd_args $DuplicacyUtilArgs -duplicacy_util_path $DuplicacyUtilPath 
}
else {
    Write-Output "Duplicacy backup commands were empty, skipping"
}

if ($RobocopySourceFolders.Length -ne $RobocopyDestinationFolders.Length) {
    Write-Error "Source robocopy folders length does not match Destination robocopy folders length"
    exit 1;
}
elseif ($RobocopySourceFolders.Length -gt 0) {
    RobocopyBackup -arSourceFolders $RobocopySourceFolders -arDestinationFolders $RobocopyDestinationFolders
}
else {
    Write-Output "Robocopy folders are empty, skipping robocopy backup"
}
