Param(
    [Parameter(Mandatory=$True)]
    [string]$securityGroups,

    [Parameter(Mandatory=$True)]
    [string]$ruleName,

    [Parameter(Mandatory=$True)]
    [string]$ipAddress,

    [Parameter(Mandatory=$True)]
    [string]$portRange,

    [Parameter(Mandatory=$True)]
    [int]$initialPriority

)


foreach ($securityGroup in $securityGroups) {

    Get-AzureNetworkSecurityGroup -Name $securityGroup | Set-AzureNetworkSecurityRule -Name $ruleName -Action Allow `
    -Protocol TCP -Type Inbound -Priority ($initialPriority+=1) -SourceAddressPrefix $ipAddress -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange $portRange

}
