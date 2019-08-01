$rgs = Get-AzureRmResourceGroup

foreach ($rg in $rgs) {

    $rgName = $rg.ResourceGroupName

    Write-Host "Finding VMs in the resource group $rgName..."
    $vms = Get-AzureRmVM -ResourceGroup $($rg.ResourceGroupName)
        
        foreach ($vm in $vms) {
        
            $vmLicense = $vm.LicenseType
            $vmName = $vm.Name
            Write-Host "Found VM $vmName..."
            #$vmLicense = "Windows_Server"
            #Write-Host "Converting $vmName to Hybrid licensing..."
            Write-Host "The licensing model of the VM $vmName is $($vm.LicenseType)..."
            #Update-AzureRmVM -ResourceGroupName $rgName -VM $vmName
        }
}
