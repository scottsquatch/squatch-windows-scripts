# Script to run multiple duplicacy util backups at once
[CmdletBinding()]
param (
    [Parameter()]
    [string[]]
    $DuplicacyUtilArgs,
    [Parameter()]
    [string]
    $DuplicacyUtilPath = "duplicacy-util"
)

Write-Output "###############################"
Write-Output "Start duplicacy backups"
Write-Output "###############################"
Write-Output ""
foreach ($cmd_arg in $DuplicacyUtilArgs) {
    Write-Output "Start backup for with command $cmd_arg"
    $cmd = "$DuplicacyUtilPath $cmd_arg";
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