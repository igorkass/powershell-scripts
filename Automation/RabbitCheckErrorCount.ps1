$PSEmailServer = "mail.example.com"
$mailFrom = "alerts@example.com"
$mailUser = "postmaster@example.com"
$mailPassword = ConvertTo-SecureString 'password' -AsPlainText -Force
$mailCreds = New-Object System.Management.Automation.PSCredential ($mailUser, $mailPassword)
$mailRecipients = "admins@example.com"
$hostName = "rabbit.example.com"
$restUser = "admin"
$restPassword = "password"
$queueNames = @(@("vhost_0", "queue_0"), @("vhost_1", "queue_1"))

foreach ($queueName in $queueNames) {

    $params = @{
        Uri         = -join ('http://', $hostName, ':15672/api/queues/', $queueName[0], '/', $queueName[1])
        Headers     = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($restUser):$restPassword")) }
        Method      = 'GET'
        ContentType = 'application/json'
    }

    $queueSize = (Invoke-RestMethod @params | ConvertTo-Json | jq .messages) -as [int]

    if ($queueSize -gt 0) {

        $mailSubject = "[PROD] RabbitMQ $($queueName[1]) alert"
        $mailBody = "Message count in queue <b>$($queueName[1])</b> in <b>$($queueName[0])</b> is <b>$queueSize</b>"

        Write-Host $mailBody

        Send-MailMessage -From $mailFrom -Credential $mailCreds -UseSsl -Port 587 -To $mailRecipients -Subject $mailSubject -Body $mailBody -BodyAsHtml

    }
}