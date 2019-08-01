$cloudServices = Get-AzureService | Where-Object {$_.ServiceName -match "api"}
$certPath = "C:\Repos\Certificates\apns.p12"
$certPwd = "password"

foreach ($cloudService in $cloudServices) {

    $cloudServiceName = $cloudService.ServiceName
    # For PFX
    Add-AzureCertificate -ServiceName $cloudServiceName -CertToDeploy $certPath -Password $certPwd | Out-Null
    # For CER
    #Add-AzureCertificate -ServiceName $cloudServiceName -CertToDeploy $certPath | Out-Null
    Write-Host "Certificate has been uploaded to the cloud service $cloudServiceName..."

}
