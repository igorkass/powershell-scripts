$roleNamesArray = @(
            @("CloudServiceWeb", "WebVM"),
            @("CloudServiceApi", "ApiVM"),
            @("CloudServiceEsb", "EsbVM")
)

$ServiceConfigFiles = Get-ChildItem -Path "C:\Repos\repo" -Recurse | ? {$_.PSParentPath -match "CloudService" -and $_.PSParentPath -notmatch "(Example.AzureCloudService|Release)" -and $_.Name -match "ServiceConfiguration" -and $_.Name -notmatch "(Local|Production)"}

foreach ($ServiceConfigFile in $ServiceConfigFiles) {

# Update Service Configuration File
$ServiceConfigFileName = $ServiceConfigFile.FullName
Write-Host "Updating Service Configuration File $ServiceConfigFileName"
$CscfgFile = Get-Item $ServiceConfigFileName
[xml]$CscfgContent = Get-Content $CscfgFile

$roleNames = $CscfgContent.ServiceConfiguration.Role.name

foreach ($roleName in $roleNames) {

    foreach ($role in $roleNamesArray) {
        if ($roleName -match $($role[0])) {

            if (!($roleName.vmName)) {
                $currentRole = $CscfgContent.ServiceConfiguration.Role | Where-Object {$_.name -match $($role[0])}
                $currentRole.SetAttribute("vmName", $($role[1]))
            }

            else {
                $roleName.vmName = $($role[1])
            }
        }
    }
}

$CscfgContent.Save($ServiceConfigFileName)
Write-Output "Applied config changes to config $ServiceConfigFileName"
}
