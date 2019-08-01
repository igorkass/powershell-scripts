param(
    [Parameter(Mandatory=$True)]
    [string]
    $appId,

    [Parameter(Mandatory=$True)]
    [string]
    $appSecret,

    [Parameter(Mandatory=$True)]
    [string]
    $subscriptionId,

    [Parameter(Mandatory=$True)]
    [string]
    $tenantId,

    [Parameter(Mandatory=$True)]
    [string]
    $environment
)

# Variables
$azureApplicationId = $appId
$azureApplicationSecret = ConvertTo-SecureString $appSecret -AsPlainText -Force
$azureTenantId = $tenantId
$azureSubscriptionId = $subscriptionId

# Login to Azure
$psCred = New-Object System.Management.Automation.PSCredential($azureApplicationId, $azureApplicationSecret)

# Resource Manager model
Connect-AzAccount -Credential $psCred -ServicePrincipal -TenantId $azureTenantId
Select-AzSubscription -SubscriptionId $azureSubscriptionId

# Switch Traffic Manager profiles
$tmpProfiles = Get-AzTrafficManagerProfile | Where-Object { $_.Name -match $environment }

foreach ($tmpProfile in $tmpProfiles) {
    # Disable primary endpoint
    $primaryEndpoint = Get-AzTrafficManagerEndpoint -ProfileName $tmpProfile.Name -ResourceGroupName $resourceGroup -Name "primary" -Type AzureEndpoints
    $primaryEndpoint.EndpointStatus = "Disabled"
    Set-AzTrafficManagerEndpoint -TrafficManagerEndpoint $primaryEndpoint
}

foreach ($tmpProfile in $tmpProfiles) {
    # Enable secondary endpoint
    $secondaryEndpoint = Get-AzTrafficManagerEndpoint -ProfileName $tmpProfile.Name -ResourceGroupName $resourceGroup -Name "secondary" -Type AzureEndpoints
    $secondaryEndpoint.EndpointStatus = "Enabled"
    Set-AzTrafficManagerEndpoint -TrafficManagerEndpoint $secondaryEndpoint
}