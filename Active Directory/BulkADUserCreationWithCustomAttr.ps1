# This script creates AD users from the CSV file
# A random password is generated using the New-RandomComplexPassword function
# All login details will be sent to a user's email address

Import-Module ActiveDirectory
Add-Type -AssemblyName System.Web

Function New-RandomComplexPassword ($Length=12) {
    $ComplexPassword = [System.Web.Security.Membership]::GeneratePassword($Length,2)
    return $ComplexPassword
}

$Domain = "example.com"
$Group = "ExampleUsers"
$OU = "OU=Users,DC=example,DC=com"
$PSEmailServer = "mail.example.com"
$EmailUser = "postmaster@example.com"
$EmailPassword = ConvertTo-SecureString 'password' -AsPlainText -Force
$EmailCreds = New-Object System.Management.Automation.PSCredential ($EmailUser, $EmailPassword)
$UsersFile = "C:\Temp\example.com.csv"

# Create AD users
Write-Host "`nChecking users...`n"

$Users = Import-Csv -Path $UsersFile -Delimiter ";"

foreach ($User in $Users) {

    $DisplayName =  $User.DisplayName
    $GivenName = $User.GivenName
    $Surname = $User.Surname
    $Title = $User.Title
    $EmailAddress = $User.EmailAddress.ToLower()
    $Company = $User.Company
    $Office = $User.Office
    $City = $User.City
    $Department = $User.Department
    $SAM = $User.SamAccountName.ToLower()
    $UPN = ($User.GivenName + "." + $User.Surname).ToLower() + "@" + $Domain
    $UserPassword = New-RandomComplexPassword

    # Email message body
    $Line1 = "NetBIOS login: <b>$SAM</b>"
    $Line2 = "Password: <b>$UserPassword</b>"
    $Line3 = "You can set your password here: https://enroll.example.com/enroll1.asp"
    $Line4 = "Please refer to the guide: "
    $MessageBody = "$Line1<br>$Line2<br>$Line3<br>$Line4"
    $Recipients = $EmailAddress

    if (!(Get-ADUser -Filter 'SamAccountName -like $SAM')) {

        New-ADUser -Name "$DisplayName" -DisplayName "$DisplayName" `
        -SamAccountName $SAM -UserPrincipalName $UPN -GivenName "$GivenName" -Surname "$Surname" `
        -AccountPassword (ConvertTo-SecureString $UserPassword -AsPlainText -Force) -Enabled $true -Path "$OU" -ChangePasswordAtLogon $true –PasswordNeverExpires $false `
        -Company $Company -Title $Title -Department $Department -EmailAddress $EmailAddress -Office $Office -City $City `
        -Server localhost

        Set-ADUser -Identity $SAM -Replace @{jiraAccountName="$SAM";confAccountName="$SAM";vcsAccountName="$SAM"}

        Add-ADGroupMember -Identity $Group -Members $SAM

        Write-Host "User " -NoNewline
        Write-Host "$Displayname " -ForegroundColor Green -NoNewline
        Write-Host "has been created with the password " -NoNewline
        Write-host "$UserPassword" -ForegroundColor Yellow

        Send-MailMessage -From "postmaster@example.com" -Credential $EmailCreds -UseSsl -Port 587 -To $Recipients -Subject "Domain account details" -Body $MessageBody -BodyAsHtml

    }

    else {

        Write-Host "User " -NoNewline
        Write-Host "$Displayname " -ForegroundColor Green -NoNewline
        Write-Host "is already exist. Updating attributes..."
        Set-ADUser -Identity $SAM -Replace @{sAMAccountName="$SAM";title="$Title"}
    }
}

# Find inactive users
Write-Host "`nSearching for inactive users...`n"

$activeUsers = Import-Csv -Path $UsersFile -Delimiter ";" | Select-Object -Expand SamAccountName
$inactiveUsers = Get-ADUser -SearchBase $OU -Filter 'SamAccountName -like "*"' | Where-Object {$_.SamAccountName -notin $activeUsers}

if ($inactiveUsers) {

    foreach ($inactiveUser in $inactiveUsers) {

        Write-Host "User " -NoNewline
        Write-Host "$($inactiveUser.Name) " -ForegroundColor Red -NoNewline
        Write-Host "is inactive and will be disabled"
        Get-ADUser -Identity $($inactiveUser.DistinguishedName) -Properties MemberOf | ForEach-Object { $_.MemberOf | Remove-ADGroupMember -Members $_.DistinguishedName -Confirm:$false }
        Get-ADUser -Identity $($inactiveUser.DistinguishedName) | Disable-ADAccount
        Move-ADObject -Identity $($inactiveUser.DistinguishedName) -TargetPath "OU=Inactive,DC=example,DC=com"
    }
}

else {
    Write-Host "There are no inactive users..."
}