Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$groupName,

    [Parameter(Mandatory=$False,Position=2)]
    [string]$userName,

    [Parameter(Mandatory=$True,Position=3)]
    [string]$outputDir

)

if (!($userName)) {

    $outputFile = Join-Path $outputDir "$groupName.temp.csv"

    Write-Host "Fetching all users from the specified group..."

    Get-ADGroup -Filter 'Name -like $groupName' | Get-ADGroupMember | Get-ADUser -Properties * | `
    Select-Object DisplayName, GivenName, Surname, EmailAddress, Title, SamAccountName, Company, City, Office, Department | `
    Sort-Object -Property DisplayName | Export-Csv -NoTypeInformation -Path $outputFile -Delimiter ";"

}

else {

    $outputFile = Join-Path $outputDir "$groupName.user.csv"

    Write-Host "Fetching the user $userName from the specified group..."

    Get-ADGroup -Filter 'Name -like $groupName' | Get-ADGroupMember | Where-Object {$_.name -match $userName} | Get-ADUser -Properties * | `
    Select-Object DisplayName, GivenName, Surname, EmailAddress, Title, SamAccountName, Company, City, Office, Department | `
    Sort-Object -Property DisplayName | Export-Csv -NoTypeInformation -Path $outputFile -Delimiter ";"

}
