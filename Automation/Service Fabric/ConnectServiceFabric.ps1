Clear-Host

$userCert = ''
$serverCert = ''
$endpoint = 'servicefabric.example.com:19000'

Connect-ServiceFabricCluster `
    -ConnectionEndpoint $endpoint `
    -X509Credential `
    -FindType FindByThumbprint `
    -FindValue $userCert `
    -StoreLocation CurrentUser `
    -StoreName My `
    -ServerCertThumbprint $serverCert