$RGs = Get-AzureRmResourceGroup

foreach($RG in $RGs)
{
    $Resources = Find-AzureRmResource -ResourceGroupName $RG.ResourceGroupName
    $outputstr = $RG.ResourceGroupName + " - " + $Resources.Length | Out-Null
    Write-Output $outputstr
    if ($Resources.Length -eq "0") {
        Write-Host $RG.ResourceGroupName
    }
}
