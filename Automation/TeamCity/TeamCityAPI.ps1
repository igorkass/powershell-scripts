function Get-TeamCityBuildStatus {

    <#
    .SYNOPSIS
    get status of build from Teamcity server

    .EXAMPLE
    Get-TeamcityBuildStatus -server servername -buildID 12 -user timmy -password time

#>

    param(
        [Parameter(Mandatory = $true)]
        [string]$server,
        [Parameter(Mandatory = $true)]
        [string]$buildID,
        [Parameter(Mandatory = $true)]
        [string]$user,
        [Parameter(Mandatory = $true)]
        [string]$password)

    $headers = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($user):$password")) }
    $url = "https://$($Server)/httpAuth/app/rest/builds/id:$buildid" 

    try {
        invoke-restmethod -uri $url -Headers $headers
    }
    Catch {
        throw "Failed to get build status for $buildID"
        exit 1
    }
}

function Wait-TeamCityBuild {
    <#
    .SYNOPSIS
    waits for build from Teamcity server to finish and resports state

    .EXAMPLE
    wait-Teamcitybuild -server servername -port 81 -buildID 6177 -user timmy -password time

#>

    param(
        [Parameter(Mandatory = $true)]
        [string]$server,
        [Parameter(Mandatory = $true)]
        [string]$buildID,
        [Parameter(Mandatory = $true)]
        [string]$user,
        [Parameter(Mandatory = $true)]
        [string]$password,
        [int]$delay = 1)


    do {
        write-host "$(Get-date) - waiting for buildid: $buildID "
        sleep $delay
        $result = Get-TeamcityBuildStatus -server $server -buildID $buildID -user $user -password $password
    }
    while ($result.build.state -ne "finished")

    Write-Host "$(Get-date) - buildTypeId: $($result.build.buildTypeId) is finished"

    switch ($result.build.status) {
        "SUCCESS" {
            write-host "$(Get-date) - buildTypeId: $($result.build.buildTypeId) is Successful"
        }
        default {
            write-error "buildTypeId: $($result.build.buildTypeId) is failed"
            exit 1
        }

    }
}

function Invoke-TeamСityBuild {
    param(
        [Parameter(Mandatory = $true)]
        [string]$server,
        [Parameter(Mandatory = $true)]
        [string]$user,
        [Parameter(Mandatory = $true)]
        [string]$password,
        [Parameter(Mandatory = $true)]
        [string]$buildTypeID,
        [Parameter(Mandatory = $true)]
        [string]$publishProfile
    )

    $build = [xml] @"
<build>
   <buildType id="$buildTypeID" />
   <properties>
        <property name="PublishProfile" value="$publishProfile" inherited="false" />
    </properties>
</build>
"@

    $url = "https://$($server)/app/rest/buildQueue"
    $headers = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($user):$password")) }
    Write-Host "$(Get-date) -  Invoke-teamcitybuild on $server with ID $buildTypeID" -ForegroundColor Yellow
    $result = invoke-restmethod $url -method POST -body $build -Headers $headers -ContentType application/xml
}
