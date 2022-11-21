$dirlist = @(
    "c:\NivaDB\backup\",
    "d:\Backup\1C8\sql\",
    "f:\vmbackup\"
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
        'Niva' {$dirMapObject.s3bucket = "s3://2233-elevator/niva"; $dirMapObject.path = $dirlist[$i]; $dirMapping += $dirMapObject}
        '1C8' {$dirMapObject.s3bucket = "s3://2233-elevator/1C"; $dirMapObject.path = $dirlist[$i]; $dirMapping += $dirMapObject}
        'vmbackup' {$dirMapObject.s3bucket = "s3://2233-elevator/VM"; $dirMapObject.path = $dirlist[$i]; $dirMapping += $dirMapObject}
    }
}
# start retention cleanup
for ($i = 0;$i -lt $dirlist.Count;$i++) {
    Write-Host "Backup path is:"$dirlist[$i] "Retention is $retDays"
    Get-ChildItem -Path $dirlist[$i] -Recurse -File | Where-Object {$_.CreationTime -lt $delPeriod} | Remove-Item -Recurse -Force
    # remove empty directories
    # Get-ChildItem -Path $dirlist[$i] -Recurse | Where-Object {$_.PSIsContainer -and @(Get-ChildItem -Path $_.Fullname -Recurse | Where { -not $_.PSIsContainer }).Count -eq 0 } | Remove-Item -Recurse

}

<# Determine s3cmd path
$currentPath = gci ENV:\Path
$currentPath = $currentPath.Value.Split(";")
for ($i = 0; $i -lt $currentPath.Count;$i++) {
    if ($currentPath[$i] -like "*s3*") {
        $s3Path = $currentPath[$i]
        Write-Host "S3cmd path is:" $s3Path
    }
}
Set-Location $s3Path #>

# upload to s3
for ($i = 0;$i -lt $dirMapping.Count;$i++) {
    $args = "s3 sync $($dirMapping[$i].path) $($dirMapping[$i].s3bucket)"
    Start-Process "aws" -ArgumentList $args -Wait
}