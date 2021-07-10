# Script to check duplicacy backups
# tests a restore and uses sha256 hashes to compare files
[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $test_file,
    [Parameter()]
    [string[]]
    $ids,
    [Parameter()]
    [string[]]
    $storages
)

function dup_restore {
    param (
        [string]
        $file,
        [string]
        $revision,
        [string]
        $storage

    )

    Write-Host "Restoring file $file from backup with revision $revision on storage $storage and id $id"
    duplicacy restore -r $revision -storage $storage $file
    return $?;
}

function dup_latest_revision {
    param (
        [string]
        $storage,
        [string]
        $id
    )

    Write-Host "Getting latest backup revision for storage $storage and id $id";
    $backups = duplicacy list -id $id -storage $storage;
    if ((-not ($backups.StartsWith("Setting storage to "))) -or
        ($backups.Count -eq 1)) {
        Write-Error "Could not find any backup revisions for storage $storage and id $id";
        return "";
    }
    # As of 05/29/2021, the fourth column has the revision. There is no header to determine the column number so need to use hard-coded value
    $rev = $backups[$backups.Count - 1].Split()[3];
    Write-Host "Latest revision is $rev";
    return $rev;
}


function backup {
    param (
        [string]
        $path
    )

    $bk_path = "$path.bak";
    Write-Host "Backup up $path"
    if (-not (Test-Path $path)) {
        Write-Error "file $path does not exist";
        exit 1;
    } elseif (Test-Path $bk_path) {
        Write-Error "file $bk_path already exists";
        exit 2;
    }

    mv $path $bk_path;
    Write-Output "Backup successful";
}

function restore {
    param (
        [string]
        $path
    )

    $bk_path = "$path.bak";
    Write-Host "Restoring $path"
    if (-not (Test-Path $bk_path)) {
        Write-Error "file $path does not exist";
        exit 3;
    } 
    
    rm $path;
    mv $bk_path $path;
    Write-Output "Restore succesful";
}

function verify {
    param (
        [string]
        $path
    )

    $bak_path = "$path.bak";
    $path_hash = get-hash $path;
    $bak_hash = get-hash $bak_path;

    
    if ([string]::IsNullOrEmpty($path_hash)) {
        Write-Error "Unable to get hash for $path";
        return $false;
    } elseif ([string]::IsNullOrEmpty($bak_hash)) {
        Write-Error "Unable to get hash for $bak_path";
        return $false;
    }

    Write-Host "Hash for $path => $path_hash";
    Write-Host "Hash for $bak_path => $bak_hash";

    return $path_hash -eq $bak_hash;
}

function get-hash {
    param (
        [string]
        $path
    )

    return Get-FileHash -Path $path -Algorithm SHA256 | Select -ExpandProperty "Hash";
}

# First validat inputs
if ([string]::IsNullOrEmpty($test_file)) {
    Write-Error "No value for paramter test_file";
    exit 8;
} elseif ($ids.Count -ne $storages.Count) {
    Write-Error "number of ids must match number of storages";
    exit 9;
}

Write-Host "Starting duplicacy backup check";
Write-Host "";

for ($i = 0; $i -lt $storages.Length; $i++) {
        $stg = $storages[$i]
        $id = $ids[$i]
        backup $test_file
        $rev = dup_latest_revision $stg $id
        if ($rev -eq "") {
            restore $test_file;
            exit 5;
        }
        if (-not (dup_restore $test_file $rev $stg $id)) {
            Write-Error "Problem restoring $file version $rev from $stg with id $id";
            restore $test_file;
            exit 6;
        }
        if (-not (verify $test_file)) {
            Write-Error "Hash is not matching between files";
            exit 7; # no restore so that we can investigate
        }
        restore $test_file
        Write-Output "Great Success!";
}

Write-Host "Check Finished";