$azureAppId = "%AzureAppId%"
$azureAppSecret = ConvertTo-SecureString "%AzureAppSecret%" -AsPlainText -Force
$azureTenantId = "%AzureTenantId%"
$azureSubscriptionId = "%AzureSubscriptionId%"
$standbyEnvironments = @("exp", "test", "uat1", "uat2", "uat3")
$currentEnvironment = "%PublishProfile%"

if ($currentEnvironment -in $standbyEnvironments) {
    Write-Host "Deploying to a standby environment, checking its state..."

    $resourceGroupName = "fabric-" + $currentEnvironment
    $vmssName = (Get-AzVmss -ResourceGroupName $resourceGroupName).Name
    $clusterName = (Get-AzServiceFabricCluster -ResourceGroupName $resourceGroupName).Name

    # Login to Azure
    $psCred = New-Object System.Management.Automation.PSCredential($azureAppId, $azureAppSecret)
    Connect-AzAccount -Credential $psCred -ServicePrincipal -TenantId $azureTenantId
    Select-AzSubscription -SubscriptionId $azureSubscriptionId

    # Check if Service Fabric cluster is running
    $powerState = (Get-AzVmssVM -VMScaleSetName $vmssName -ResourceGroupName $resourceGroupName -InstanceView -InstanceId 0).Statuses[1].Code

    if ($powerState -match "deallocated") {
        Write-Host "Scale set is currently deallocated, powering on..."
        Start-AzVmss -VMScaleSetName $vmssName -ResourceGroupName $resourceGroupName -Confirm:$false
    }

    else { Write-Host "Scale set is already running..." }

    Write-Host "Checking cluster state..."

    # Wait until Service Fabric is ready
    while ((Get-AzServiceFabricCluster -Name $clusterName -ResourceGroupName $resourceGroupName).ClusterState -ne "Ready") {
        $clusterState = (Get-AzServiceFabricCluster -Name $clusterName -ResourceGroupName $resourceGroupName).ClusterState
        Write-Host "Cluster state is $($clusterState), waiting for 30 seconds..."
        Start-Sleep -Seconds 30
    }

    Write-Host "Cluster is ready for deployments..."
}