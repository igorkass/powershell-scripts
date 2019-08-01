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
    $primaryCluster,

    [Parameter(Mandatory=$True)]
    [string]
    $secondaryCluster
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

# Stop primary Service Fabric
Write-Host "Stopping primary Service Fabric cluster..."
Get-AzVmss | Where-Object {$_.ResourceGroupName -match $primaryCluster} | Stop-AzVmss -Force -Confirm:$false

# Start secondary Service Fabric
Write-Host "Starting secondary Service Fabric cluster..."
Get-AzVmss | Where-Object {$_.ResourceGroupName -match $secondaryCluster} | Start-AzVmss -Confirm:$false

# Wait until Service Fabric is ready
while ((Get-AzServiceFabricCluster -ResourceGroupName $secondaryCluster).ClusterState -ne "Ready") {
    $clusterState = (Get-AzServiceFabricCluster -ResourceGroupName $secondaryCluster).ClusterState
    Write-Host "Cluster state is still $($clusterState)"
    Start-Sleep -Seconds 30
}