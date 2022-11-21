if (!$vpcs) {
    $vpcs = aws ec2 describe-vpcs
}
$vpcsObject = ConvertFrom-Json ($vpcs -join "")
$vpcsObject.Vpcs.Count

foreach ($vpcid in $vpcsObject.Vpcs) {
    Write-Host $vpcid.CidrBlock
}