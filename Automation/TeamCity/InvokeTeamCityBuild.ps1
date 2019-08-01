function Invoke-TeamСityBuild

{
param(
[Parameter(Mandatory=$true)]
[string]$User,
[Parameter(Mandatory=$true)]
[string]$Password,
[Parameter(Mandatory=$true)]
[string]$BuildTypeID,
[Parameter(Mandatory=$true)]
[string]$PublishProfile
)

$BuildXml=[xml] @"
<build>
<buildType id="$BuildTypeID" />
<properties>
<property name="PublishProfile" value="$PublishProfile" />
</properties>
</build>
"@

$RestUrl="https://build.example.com/app/rest/buildQueue"
$Headers=@{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($User):$Password"))}

Write-Host "Invoking build with ID $BuildTypeID"
Invoke-RestMethod $RestUrl -method POST -body $BuildXml -Headers $Headers -ContentType application/xml

}

Invoke-TeamСityBuild -User %restapi.user% -Password %restapi.password% -BuildTypeID %buildTypeID% -PublishProfile %CloudService.Configuration%