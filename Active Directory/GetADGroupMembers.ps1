# This scripts retrieves the members of a specific AD group and exports the list into the CSV file

Import-Module ActiveDirectory

$Group = "project.group"
$OutCSV = "C:\Temp\$Group.csv"

Get-ADGroup -Filter { Name -eq $Group } | Get-ADGroupMember | Get-ADUser -Properties * | `
Select-Object DisplayName, GivenName, Surname, EmailAddress, Title, SamAccountName, Company, City, Office, Department | `
Sort-Object -Property DisplayName | Export-Csv -NoTypeInformation -Path $OutCSV -Delimiter ";"