#
# The script creates SSL bindings on a cloud service instance
#

$IPAddress = (Get-NetIPAddress | Where-Object {$_.InterfaceAlias -match "Ethernet" -and $_.AddressFamily -eq "IPv4"}).IPAddress
$TempFolder = [Environment]::GetEnvironmentVariable("TEMP", "Machine")
$LogFile = Join-Path $TempFolder "SSLBindings.log"
$Environment = "#{EnvironmentName}"
$MainThumbprint = "#{thumbprint}"
$SiteAlias = "example.com"

# Logging function
function Log-Message {

	param (
		[string] $message
	)

	Add-Content $LogFile ("{0} {1}" -f (Get-Date -UFormat "[%m/%d/%Y %T]"), $message)
}

Log-Message "Waiting until IIS site is created..."
# Wait in background for IIS initialization
while (-not (Get-Website | Where-Object {$_.Name -match $SiteAlias})) {
	Log-Message "Site is not created yet..."
	Start-Sleep -Seconds 30
}

# Get site name
$SiteName = (Get-Website | Where-Object {$_.Name -match $SiteAlias}).Name

Log-Message "Site $SiteName is found..."
# Additional delay for safety
Start-Sleep -Seconds 30

# Array of hostnames and corresponding certificates thumbprints, must be defined in Octopus
$Endpoints = @(#{BindingHosts})

Log-Message "Removing existing SSL and IIS bindings..."
# Remove all existing bindings, e.g. leftovers after promoting from another environment
Remove-Item -Path IIS:\SslBindings\*
Get-WebBinding -Name $SiteName | Remove-WebBinding

# The variable Endpoints must contain an array of hostnames and corresponding thumbprints when deploying to production
if ($Environment -eq "Production") {

    # Create bindings for each hostname in array
    foreach ($Endpoint in $Endpoints) {

        Log-Message "Creating IIS binding for $($Endpoint[0])..."
        # Create bindings for 80/443 ports
        New-WebBinding -Name $SiteName -IPAddress $IPAddress -Port 80 -Protocol http -HostHeader $($Endpoint[0]) -SslFlags 0
        New-WebBinding -Name $SiteName -IPAddress $IPAddress -Port 443 -Protocol https -HostHeader $($Endpoint[0]) -SslFlags 1

        Log-Message "Binding $($Endpoint[0]) to the certificate $($Endpoint[1])..."
        # Enable SNI for each binding
        (Get-WebBinding -Name $SiteName -IPAddress $IPAddress -Port 443 -Protocol https -HostHeader $($Endpoint[0])).AddSslCertificate($($Endpoint[1]), "My")
    }
}

# The variable Endpoints must contain a flat array of hostnames when deploying to other environments
else {

    Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Thumbprint -eq $MainThumbprint} | New-Item -Path IIS:\SslBindings\$IPAddress!443

    # Create bindings for each hostname in array
    foreach ($Endpoint in $Endpoints) {

        Log-Message "Creating IIS binding for $($Endpoint)..."
	    # Create bindings for 80/443 ports
	    New-WebBinding -Name $SiteName -IPAddress $IPAddress -Port 80 -Protocol http -HostHeader $($Endpoint) -SslFlags 0
	    New-WebBinding -Name $SiteName -IPAddress $IPAddress -Port 443 -Protocol https -HostHeader $($Endpoint) -SslFlags 0
    }
}

Log-Message "Completed creating bindings..."

Log-Message "Restarting IIS site..."
Stop-Website -Name $SiteName
Start-Website -Name $SiteName