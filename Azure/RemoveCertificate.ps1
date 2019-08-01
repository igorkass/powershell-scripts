$cloudServices = Get-AzureService
$thumbprints = @("")

foreach ($cloudService in $cloudServices) {

    $cloudServiceName = $cloudService.ServiceName

    foreach ($thumbprint in $thumbprints) {

    Get-AzureCertificate -ServiceName $cloudServiceName | Where-Object {$_.Thumbprint -eq $thumbprint} | Remove-AzureCertificate | Out-Null
    Write-Host "Certificate $thumbprint has been removed from the cloud service $cloudServiceName..."
    }
}
