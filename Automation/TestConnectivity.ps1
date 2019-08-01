$logFile = 'C:\Temp\TestingDNS.log'
$dnsName = 'websvc.example.com'
$port = '443'

function log() {
	#$now = [datetime]::Now
	$now = Get-Date -UFormat "[%a %m/%d/%Y %T]"
	$msg = [string]::Join(' ', $args)
	Write-Output ([string]::Format("{0} {1}", $now, $msg)) >> $logFile
}

log Checking that ($dnsName+':'+$port) is available...
if (-not (Test-NetConnection -ComputerName $dnsName -Port $port)) {
    log ($dnsName+':'+$port) is not available!
}
else {
    log ($dnsName+':'+$port) is available!
}
log Running IP address check...
log IP of $dnsName is (Resolve-DnsName -Name $dnsName).IPAddress
log Done!