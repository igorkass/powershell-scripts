$zoneName = "example.com"
$resourceGroup = "DNSRG"
$envName = "uat3"
$dnsNames = @("api-$envName", "auth-$envName", "cp-$envName", "dp-$envName")

foreach ($dnsName in $dnsNames) {

    <# These can be used to modify the existing records
    $recordSet = Get-AzureRmDnsRecordSet -ResourceGroupName "$resourceGroup" -ZoneName "$zoneName" -RecordType A -Name $dnsName
    $recordSet.Records[0].Ipv4Address = ""
    Set-AzureRmDnsRecordSet -RecordSet $recordSet
    #>

    New-AzureRmDnsRecordSet -Name "$dnsName" -RecordType CNAME -ZoneName "$zoneName" -ResourceGroupName "$resourceGroup" -Ttl 3600 -DnsRecords (New-AzureRmDnsRecordConfig -Cname "example-reverseproxy.trafficmanager.net")
    #Remove-AzureRmDnsRecordSet -Name "$dnsName" -RecordType A -ZoneName "$zoneName" -ResourceGroupName "$resourceGroup"

}
