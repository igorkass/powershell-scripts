# Get the name of the build configuration
$buildConfName = "%system.teamcity.buildConfName%"

# Extract the name of the environment
$buildEnvironment = $buildConfName.Substring(0, $buildConfName.IndexOf(" ")).ToLower()

# Auto-incrementing build counter
$buildCounter = "%build.counter%"

# Get the name of the default VCS branch
$defaultBranch = "%vcsroot.branch%"

# Get the name of the current branch
$currentBranch = "%teamcity.build.branch%"

# Extract the number of the current iteration
$currentIteration = $defaultBranch.Substring($defaultBranch.LastIndexOf("_")+1)

if ($currentBranch -like "*/from") {
    # Pull requests have a full path like '5930/from', so we'll use only the first part
    $currentBranch = $currentBranch.Substring(0, $currentBranch.IndexOf("/"))
    $buildNumber = "$currentIteration.$buildCounter-$buildEnvironment-pr$currentBranch"
}

else {
    $buildNumber = "$currentBranch.$buildCounter-$buildEnvironment"
}

Write-Host "##teamcity[buildNumber '$buildNumber']"
