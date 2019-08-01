$cloudServices = Get-AzureService

foreach ($cloudService in $cloudServices) {

    $cloudServiceName = $cloudService.ServiceName

    # Get all role instances
    $roleInstances = Get-AzureRole -ServiceName $cloudServiceName -InstanceDetails

    foreach ($roleInstance in $roleInstances) {

        $instanceName = $roleInstance.InstanceName
        $instanceSize = $roleInstance.InstanceSize

        $cloudServiceName,$instanceName,$instanceSize -join ";" | Out-File -FilePath C:\Temp\InstanceSizes.csv -Append
    }
}
