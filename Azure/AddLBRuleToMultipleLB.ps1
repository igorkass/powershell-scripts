$lbNames = $('fabric-uat2-lb', 'fabric-uat3-lb')
$loadBalancers = Get-AzureRmLoadBalancer | ? {$_.Name -in $lbNames}
$probeName = "CpDemoGatewayProbe"
$frontendIPName = "LoadBalancerIPConfig"
$backendPoolName = "LoadBalancerBEAddressPool"
$port = "9026"

foreach ($loadBalancer in $loadBalancers) {

    #$loadBalancer | Add-AzureRmLoadBalancerProbeConfig -Name $probeName -Protocol "tcp" -Port $port -IntervalInSeconds 5 -ProbeCount 2
    #$loadBalancer | Set-AzureRmLoadBalancerProbeConfig -Name $probeName -Port $port -IntervalInSeconds 5 -ProbeCount 2
    $feconfig = $loadBalancer | Get-AzureRmLoadBalancerFrontendIpConfig -Name $frontendIPName
    $fec = $loadBalancer | Get-AzureRmLoadBalancerFrontendIpConfig -Name $feconfig.Name
    $bepool = $loadBalancer | Get-AzureRmLoadBalancerBackendAddressPoolConfig -Name $backendPoolName
    $bep = $loadBalancer | Get-AzureRmLoadBalancerBackendAddressPoolConfig -Name $bepool.Name
    $probe = $loadBalancer | Get-AzureRmLoadBalancerProbeConfig -Name $probeName
    $loadBalancerRule = New-AzureRmLoadBalancerRuleConfig -Name $probeName -FrontendIpConfigurationId $fec.Id -BackendAddressPoolId $bep.Id -ProbeId $probe.Id -Protocol Tcp -FrontendPort $port -BackendPort $port -EnableFloatingIP
    $loadBalancer.LoadBalancingRules.Add($loadBalancerRule)
    Set-AzureRmLoadBalancer -LoadBalancer $loadBalancer
}