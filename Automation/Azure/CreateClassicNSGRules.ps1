Param(
    [Parameter(Mandatory=$True)]
    [string]$securityGroup,

    [Parameter(Mandatory=$False)]
    [int]$initialPriorityInt,

    [Parameter(Mandatory=$False)]
    [int]$initialPriorityExt,

    [Parameter(Mandatory=$False)]
    [int]$initialPriorityNet,

    [Parameter(Mandatory=$False)]
    [switch]$External,

    [Parameter(Mandatory=$False)]
    [switch]$Internal,

    [Parameter(Mandatory=$False)]
    [switch]$Offices
)

if ($Internal) {

# Cloud services
$whitelistInt = Import-Csv -Path "C:\Repos\devops\Whitelist\reserved_ip.csv" -Delimiter ";"

foreach ($row in $whitelistInt) {

    Get-AzureNetworkSecurityGroup -Name $securityGroup | Set-AzureNetworkSecurityRule -Name $($row.Description) -Action Allow `
    -Protocol TCP -Type Inbound -Priority ($initialPriorityInt+=1) -SourceAddressPrefix $($row.RemoteAddress) -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*'

    }
}

if ($External) {

# External clients
$whitelistExt = Import-Csv -Path "C:\Repos\devops\Whitelist\external_ip.csv" -Delimiter ";"

foreach ($row in $whitelistExt) {

    Get-AzureNetworkSecurityGroup -Name $securityGroup | Set-AzureNetworkSecurityRule -Name $($row.Description) -Action Allow `
    -Protocol TCP -Type Inbound -Priority ($initialPriorityInt+=1) -SourceAddressPrefix $($row.RemoteAddress) -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange $($row.Port)

    }
}

if ($Offices) {

# Office networks
$whitelistDA = Import-Csv -Path "C:\Repos\devops\Whitelist\office_networks.csv" -Delimiter ";"

foreach ($row in $whitelistDA) {

    $remoteAccess = $row.Description + "RemoteAccess"
    $remoteForwarder = $row.Description + "RemoteForwarder"

    Get-AzureNetworkSecurityGroup -Name $securityGroup | Set-AzureNetworkSecurityRule -Name $remoteAccess -Action Allow `
    -Protocol TCP -Type Inbound -Priority ($initialPriorityNet+=1) -SourceAddressPrefix $($row.RemoteAddress) -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '3389'

    Get-AzureNetworkSecurityGroup -Name $securityGroup | Set-AzureNetworkSecurityRule -Name $remoteForwarder -Action Allow `
    -Protocol TCP -Type Inbound -Priority ($initialPriorityNet+=1) -SourceAddressPrefix $($row.RemoteAddress) -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '20000'

    }
}
