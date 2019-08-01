$cloudService = "WebRole"
$roleName = "Web"
# Get all role instances
$roleInstances = Get-AzureRole -ServiceName $cloudService -RoleName $roleName -InstanceDetails

foreach ($roleInstance in $roleInstances) {

    $instanceName = $roleInstance.InstanceName

    # Reboot all role instances
    #Reset-AzureRoleInstance -ServiceName $cloudService -Slot "Production" -InstanceName $instanceName -Reboot
    Write-Host $instanceName
    Write-Host "The instance $instanceName of the service $cloudService has been restarted..."
}
