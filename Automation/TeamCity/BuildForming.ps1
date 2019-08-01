# These are project build parameters in TeamCity
$majorVersion = "%MajorVersion%"
$minorVersion = "%MinorVersion%"
$patchVersion = "%PatchVersion%"

# TeamCity's auto-incrementing build counter, ensures each build is unique
$buildCounter = "%build.counter%" 

# This gets the name of the current Git branch.
$branch = "%teamcity.build.branch%"

if ($branch -like "rc/*") {
$patchVersion = ($branch.Split("/")[1]).Split(".")[2]
$buildNumber = "$majorVersion.$minorVersion.$patchVersion.$buildCounter"
}

elseif ($branch -eq "master") {
$patchVersion = [int]$patchVersion-1
$buildNumber = "$majorVersion.$minorVersion.$patchVersion.$buildCounter"
}

else {
$buildNumber = "$majorVersion.$minorVersion.$patchVersion.$buildCounter"
}

Write-Host "##teamcity[buildNumber '$buildNumber']"