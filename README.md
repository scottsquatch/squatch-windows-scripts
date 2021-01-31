)# Windows Scripts
Helpful Windows scripts, mainly pertaining towards backup utilities. Typically these will be split into smaller scripts so they can be reused.

# Installing
Either download the zip file of the branch or get latest and copy to scripts directory.

# Utilities
## Saturday Maintenance
Every Saturday I have a routine to make sure machines are backed up and updates are downloaded/installed. Decided to create a script to automate the process.
This will perform the following steps:
1. Run Backups
    1. Duplicacy-Util backups.
    2. Robocopy from source to destination folders. Note that script uses parameters `/COPYALL /E /R:0 /xo` for robocopy.
2. Update scoop applications
3. Install Windows Updates and prompt for reboot if necessary.

Script name is `SaturdayMaintenance`, parameters are:
* DuplicacyUtilArgs - Array of arguments to pass to [duplicacy-util](https://github.com/jeffaco/duplicacy-util). It is done this way for greater customability, as I like to have multiple duplicacy-util profiles for each user to backup (I know that it could be done with symlinks but I like to keep them separate). Example value could be `-f backup-profile -a`. See [here](https://github.com/jeffaco/duplicacy-util) for more info on duplicacy-util arguments.
* DuplicacyUtilPath - Path of duplicacy-util executable file. By default this is `duplicacy-util`, but you can provide a value if exe is in a directory which is not in PATH.
* RobocopySourceFolders - Array of source folders for robocopy backup, if left out no robocopy backup will be performed. Note that the value of this parameter must match the length of the RobocopyDestinationFolders parameter.
* RobocopyDestinationFolders - Array of destination folders for robocopy backup. Will be used in conjunction with RobocopySourceFolders to determine where to copy the files from/to, which is determined from index. For example, ` -RobocopySourceFolders ("C:\Backup1", "C:\Backup2")` and `-RobocopyDestinationFolders ("D:\Dest1", "D:\Dest2")` will copy files from folder `C:\Backup1` to `D:\Dest1` and from `C:\Backup2` to `D:\Dest2`.

Example Usage: `SaturdayMaintenance.ps1 -DuplicacyUtilArgs ("-f home -a") -DuplicacyUtilPath "C:\utils\duplicacy-util" -RobocopySourceFolders ("C:\Users\Tom") -RobocopyDestinationFolders ("D:\Backups\Tom\Home")`

This would first run `C:\utils\duplicacy-util -f home -a`, then perform a robocopy from `C:\Users\Tom` to `D:\Backups\Tom\Home`

Note: Powershell script for robocopy taken from [here](https://gist.github.com/frndlyy/e7e51d3acddee51c4e42d0ee9bbe0dc0#file-filefolder_robocopy_withpowershell-ps1).