function New-RandomPassword {
    param(
        [Parameter()]
        [int]$MinimumPasswordLength = 5,
        [Parameter()]
        [int]$MaximumPasswordLength = 14,
        [Parameter()]
        [int]$NumberOfAlphaNumericCharacters = 5,
        [Parameter()]
        [switch]$ConvertToSecureString
    )
    
    Add-Type -AssemblyName 'System.Web'
    $length = Get-Random -Minimum $MinimumPasswordLength -Maximum $MaximumPasswordLength
    $password = [System.Web.Security.Membership]::GeneratePassword($length,$NumberOfAlphaNumericCharacters)
    if ($ConvertToSecureString.IsPresent) {
        ConvertTo-SecureString -String $password -AsPlainText -Force
    } else {
        $password
    }
}
$pass = New-RandomPassword -MinimumPasswordLength 15 -MaximumPasswordLength 20 -NumberOfAlphaNumericCharacters 0 #-ConvertToSecureString
Write-Host $pass