$today = get-date -Hour 0 -Minute 0
$now = Get-date
$workspace = "D:\Scripts\logs\"
$yearNum = [string](Get-Date).Year
$monthNum = [string](Get-Date).Month
$dayNum = [string](Get-Date).Day
$logPath = $workspace+$yearNum+"\"+$monthNum+"\"+$dayNum
if (!(Test-Path -Path $logPath)) {
    New-Item $logPath -ItemType Directory
}
Try 
{
    $events = Get-WinEvent -FilterHashtable @{Logname="Security";ID=4624;StartTime=$today;EndTime=$now} -ErrorAction Stop
}
Catch 
{
    Write-Output “No any event 4624 exists!” > $f1\No-RDPlogon.txt
    exit
}
$auditEvents = [System.Collections.ArrayList]@()
foreach ($event in $events) {
    if (($($event.Properties[8].Value) -eq 10) -or ($($event.Properties[8].Value) -eq 7)) {
        $event2=new-object psobject -Property @{
        TimeCreated = ""
        User = ""
        Domain = ""
        Source = ""
        hostname = ""
        }

        $event2.TimeCreated = $event.TimeCreated
        $event2.User = $event.Properties[5].Value
        $event2.Domain = $event.Properties[6].Value
        $event2.Source = $event.Properties[18].Value
        try {
            $srcDNS = nslookup.exe "$($event.Properties[18].Value)"
            $srcDNS = ($srcDNS[3].Split(":")[1]).replace(' ','')
        }
        catch [System.Management.Automation.RuntimeException]{
            $srcDNS = "Can't resolve DNS Name"
        }
        
        $event2.hostname = $srcDNS
        $auditEvents += $event2

    }
    $timestamp = Get-Date -Format "MM_dd_yyyy_HH_mm"
    $auditEvents | ConvertTo-Csv -NoTypeInformation -Delimiter ";" | Out-File "$logpath\audit_$($timestamp).csv"
    $logHash = (Get-FileHash "$logpath\audit_$($timestamp).csv" -Algorithm SHA384).Hash
    $logHash | Out-File "$logpath\audit_$($timestamp).sha"
}