Param(
    [Parameter(Mandatory=$True)]
    [string]$securityGroup,

    [Parameter(Mandatory=$True)]
    [string]$resourceGroup

)

$addressRegex=‘(?<Address>((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))’

# Get allowed IP
$sourceAddresses = (Get-AzureRmNetworkSecurityGroup -Name $securityGroup -ResourceGroupName $resourceGroup | Select-Object SecurityRules -ExpandProperty SecurityRules `
    | Where-Object {$_.Access -eq "Allow"}).SourceAddressPrefix

# Get all public IP
$publicIP = Get-AzureRmPublicIpAddress | Get-AzureRmPublicIpAddress | Select-Object Name, IpAddress

# Get all reserved IP
# $reservedIP = Get-AzureReservedIP | Select-Object ReservedIPName, Address

foreach ($sourceAddress in $sourceAddresses) {

    # Check only valid IP addresses
    if ($sourceAddress -match $addressRegex) {

        # Compare with the public's IP array
        if ($sourceAddress -notin $publicIP) {Write-Host "$sourceAddress doesn't exist in Public IPs"}

        # Compare with the reserved's IP array
        # if ($sourceAddress -notin $reservedIP) {Write-Host "IP $sourceAddress doesn't exist in Reserved IPs"}
    }

}