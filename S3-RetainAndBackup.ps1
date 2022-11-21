$dirlist = @(
    "f:\dir1\backup\",
    "f:\dir2\backup\",
    "f:\dir3\backup\"
)
$retDays = "-10"
$currentDay = Get-Date
$delPeriod = $CurrentDay.AddDays($retDays)

$dirMapping = [System.Collections.ArrayList]@()
for ($i = 0;$i -lt $dirlist.Count;$i++) {
    $dirMapObject = [PSCustomObject]@{
        path = ""
        s3bucket = ""
    }
    switch -regex ($dirlist[$i]) {
        'Niva' {$dirMapObject.s3bucket = "s3://first/backup/path"; $dirMapObject.path = $dirlist[$i]; $dirMapping += $dirMapObject}
        '1C8' {$dirMapObject.s3bucket = "s3://second/backup/path"; $dirMapObject.path = $dirlist[$i]; $dirMapping += $dirMapObject}
        'vmbackup' {$dirMapObject.s3bucket = "s3://third/backup/path"; $dirMapObject.path = $dirlist[$i]; $dirMapping += $dirMapObject}
    }
}
# start retention cleanup
for ($i = 0;$i -lt $dirlist.Count;$i++) {
    Write-Host "Backup path is:"$dirlist[$i] "Retention is $retDays"
    Get-ChildItem -Path $dirlist[$i] -Recurse -File | Where-Object {$_.CreationTime -lt $delPeriod} | Remove-Item -Recurse -Force
}

# upload to s3
for ($i = 0;$i -lt $dirMapping.Count;$i++) {
    $args = "s3 sync $($dirMapping[$i].path) $($dirMapping[$i].s3bucket)"
    Start-Process "aws" -ArgumentList $args -Wait
}