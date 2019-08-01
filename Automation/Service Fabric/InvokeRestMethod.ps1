$serviceName = "fabric:/Example.Services/Api"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("X-CallOrigin", 'Web')

Connect-ServiceFabricCluster | Out-Null

$partition = Get-ServiceFabricPartition -ServiceName $serviceName
$replica = Get-ServiceFabricReplica -PartitionId $($partition.PartitionId)
$replicaDetails = Get-ServiceFabricDeployedReplicaDetail -NodeName $($replica.NodeName) -PartitionId $partition.PartitionId -ReplicaOrInstanceId $replica.ReplicaOrInstanceId
$endpoint = ($replicaDetails.DeployedServiceReplicaInstance.Address | Select-String -Pattern "(([0-1](\d\d?)?|2([0-4]\d?|5[0-5]?|[6-9])?|[3-9]\d?)\.){3}([0-1](\d\d?)?|2([0-4]\d?|5[0-5]?|[6-9])?|[3-9]\d?)(:([0-5](\d(\d(\d\d?)?)?)?|6([0-4](\d(\d\d?)?)?|5([0-4](\d\d?)?|5([0-2]\d?|3[0-5]?|[4-9])?|[6-9]\d?)?|[6-9](\d\d?)?)?|[7-9](\d(\d\d?)?)?))?" -AllMatches).Matches.Value
$requestUrl = -join("http://", "$endpoint", "/api/v1/check/startchecking")
Invoke-RestMethod -Uri $requestUrl -Headers $headers -Method POST