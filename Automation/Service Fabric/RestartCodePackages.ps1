$applicationName = (Read-Host -Prompt "Select the application: 1. Api, 2. UI, 3. Core, 4. Proxies")
$specificPackage = (Read-Host -Prompt "Restart all services or a specific package? 1. All, 2. Specific")

switch ($applicationName) {

    1 { $applicationName = "fabric:/Api" }
    2 { $applicationName = "fabric:/UI" }
    3 { $applicationName = "fabric:/Core" }
    4 { $applicationName = "fabric:/Proxies" }
}

switch ($specificPackage) {

    1 { $packageName = ".*" }
    2 { $packageName = (Read-Host -Prompt "Type package name without quotes, e.g. Brokering") }
}

$nodes = Get-ServiceFabricNode

foreach ($node in $nodes) {

    $nodeName = $node.NodeName

    if (Get-ServiceFabricDeployedApplication -NodeName $nodeName -ApplicationName $applicationName) {

        $codePackages = Get-ServiceFabricDeployedCodePackage -NodeName $nodeName -ApplicationName $applicationName -ErrorAction SilentlyContinue | Where-Object { $_.ServiceManifestName -match $packageName }

        foreach ($codePackage in $codePackages) {

            Write-Host "Restarting $($codePackage.ServiceManifestName) on node $nodeName"
            Restart-ServiceFabricDeployedCodePackage -NodeName $nodeName -ApplicationName $applicationName -CodePackageName "Code" -ServiceManifestName $($codePackage.ServiceManifestName) -CommandCompletionMode Verify | Out-Null
        }
    }
}
