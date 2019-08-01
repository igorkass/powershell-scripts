param(
    [Parameter(Mandatory=$True)]
    [string]
    $accountName,

    [Parameter(Mandatory=$True)]
    [string]
    $accountSecret,

    [Parameter(Mandatory=$True)]
    [string]
    $subscriptionId,

    [Parameter(Mandatory=$True)]
    [string]
    $tenantId,

    [Parameter(Mandatory=$True)]
    [string]
    $primaryServices,

    [Parameter(Mandatory=$True)]
    [string]
    $secondaryServices
)

# Variables
$azureAccountName = $accountName
$azureAccountSecret = ConvertTo-SecureString $accountSecret -AsPlainText -Force
$azureTenantId = $tenantId
$azureSubscriptionId = $subscriptionId

# Login to Azure
$psCred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azureAccountSecret)

# Classic model
Add-AzureAccount -Credential $psCred -Tenant $azureTenantId
Get-AzureSubscription -SubscriptionId $azureSubscriptionId | Select-AzureSubscription

# Stop primary Cloud Services
Get-AzureService | Where-Object {$_.ServiceName -in $primaryServices} | ForEach-Object { Stop-AzureService -ServiceName $_.ServiceName -Slot Production -ErrorAction Continue }

# Start secondary Cloud Services
Get-AzureService | Where-Object {$_.ServiceName -in $secondaryServices} | ForEach-Object { Start-AzureService -ServiceName $_.ServiceName -Slot Production -ErrorAction Continue }

# Wait until Cloud Services are ready
$serviceDeployments = Get-AzureService | Where-Object {$_.ServiceName -match $secondaryServices} | ForEach-Object { Get-AzureDeployment -ServiceName $_.ServiceName -Slot Production }

foreach ($serviceDeployment in $serviceDeployments) {
    while ((Get-AzureDeployment -ServiceName $serviceDeployment.ServiceName -Slot Production).Status -ne "Running") {
        $deploymentStatus = (Get-AzureDeployment -ServiceName $serviceDeployment.ServiceName -Slot Production).Status
        Write-Host "Deployment status is still $($deploymentStatus)"
        Start-Sleep -Seconds 30
    }
    Write-Host "Deployment of $($serviceDeployment.ServiceName) is $($serviceDeployment.Status)"
}