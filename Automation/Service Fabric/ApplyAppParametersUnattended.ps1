Param(

    [Parameter(Mandatory = $true)]
    [string]$rootFolder,

    [Parameter(Mandatory = $true)]
    [string]$environmentName
)

$publishProfile = Join-Path $rootFolder "PublishProfiles\$environmentName.xml"
$parametersFile = Join-Path $rootFolder "ApplicationParameters\$environmentName.xml"

function Read-XmlElementAsHashtable {
    Param (
        [System.Xml.XmlElement]
        $Element
    )

    $hashtable = @{}
    if ($Element.Attributes) {
        $Element.Attributes |
            ForEach-Object {
            $boolVal = $null
            if ([bool]::TryParse($_.Value, [ref]$boolVal)) {
                $hashtable[$_.Name] = $boolVal
            }
            else {
                $hashtable[$_.Name] = $_.Value
            }
        }
    }

    return $hashtable
}

$publishProfileXml = [Xml](Get-Content -Raw $publishProfile)
$connectionParameters = Read-XmlElementAsHashtable $publishProfileXml.PublishProfile.Item("ClusterConnectionParameters")

try {
    [void](Connect-ServiceFabricCluster @connectionParameters )
}
catch [System.Fabric.FabricObjectClosedException] {
    Write-Warning "Service Fabric cluster may not be connected."
    throw
}

$configXml = [Xml](Get-Content -Raw $parametersFile)
# Get application name from config
$applicationName = $configXml.Application.Name
# Get application version from cluster
$applicationVersion = (Get-ServiceFabricApplication -ApplicationName $applicationName).ApplicationTypeVersion

# Initialize the hashtable
$applicationParameters = @{}

# Loop over all parameters and create corresponding hashtable entries.
$configXml.Application.Parameters.ChildNodes | ForEach-Object {$applicationParameters[$_.Name] = $_.Value}

# Apply new parameters
Start-ServiceFabricApplicationUpgrade -ApplicationName $applicationName -ApplicationTypeVersion $applicationVersion -ApplicationParameter $applicationParameters -UnmonitoredAuto