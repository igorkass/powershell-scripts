# Source NSG
$nsgOrigin = "SG1"
# Target NSG
$nsgDestination = "SG2"
# Resource Group of source NSG
$rgName = "Default-Networking"
# Resource Group of target NSG
$rgNameDest = "Default-Networking"

$nsg = Get-AzureRmNetworkSecurityGroup -Name $nsgOrigin -ResourceGroupName $rgName
$nsgRules = Get-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg
$newNsg = Get-AzureRmNetworkSecurityGroup -name $nsgDestination -ResourceGroupName $rgNameDest

foreach ($nsgRule in $nsgRules) {
    Add-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $newNsg `
    -Name $nsgRule.Name `
    -Protocol $nsgRule.Protocol `
    -SourcePortRange $nsgRule.SourcePortRange `
    -DestinationPortRange $nsgRule.DestinationPortRange `
    -SourceAddressPrefix $nsgRule.SourceAddressPrefix `
    -DestinationAddressPrefix $nsgRule.DestinationAddressPrefix `
    -Priority $nsgRule.Priority `
    -Direction $nsgRule.Direction `
    -Access $nsgRule.Access
}

Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $newNsg