$rgs = Get-AzureRmResourceGroup;

    if(!$rgs){
        Write-Output "No resource groups in your subscription";
    }

    else{

        Write-Output "You have $($(Get-AzureRmResourceGroup).Count) resource groups in your subscription";

        foreach($resourceGroup in $rgs){
            $name=  $resourceGroup.ResourceGroupName;
            $count = (Get-AzureRmResource | where { $_.ResourceGroupName -match $name }).Count;
            if($count -eq 0){
                Write-Output "The resource group $name has $count resources. Deleting it...";
                #Remove-AzureRmResourceGroup -Name $name -Force;
            }
            else{
                #Write-Output "The resource group $name has $count resources";
            }
        }

        Write-Output "Now you have $((Get-AzureRmResourceGroup).Count) resource group(s) in your subscription";
    }