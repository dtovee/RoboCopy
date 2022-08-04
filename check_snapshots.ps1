$client="Perenco"
$viserver="192.168.1.80"
$viuser="root"
$vipass="Perenco123!"

$from="dtovee@dtovee.plus.net"
$to="dtovee@email.com"
$smtp_host="mysmtp.relay.com"

# DO NOT EDIT ANYTHING BELOW THIS LINE

# Add-PSSnapin VMware.VimAutomation.Core
connect-viserver -server $viserver -protocol https -user $viuser -password $vipass

$found_error=0
$error_count=0
$body="The following Virtual Machine(s) contain a Snapshot:`n"
$body2="Entire Log:`n"

$virtual_machines=Get-VM
foreach ($virtual_machine in $virtual_machines) {
	$snapshot=Get-Snapshot -VM $virtual_machine
	
	if ($snapshot) {
		$found_error=1
	        $error_count++

		Write-Host $virtual_machine.Name ": Snapshot found!"
		$body+="`t"+ $virtual_machine.Name +": Snapshot found! Snapshot name: "+ $snapshot.Name +"`n"
		$body2+="`t"+ $virtual_machine.Name +": Snapshot found! Snapshot name: "+ $snapshot.Name +"`n"
	} else {
		Write-Host $virtual_machine.Name ": Snapshot not found."
	        $body2+="`t"+ $virtual_machine.Name +": Snapshot not found.`n"
	}
}

# if ($found_error) {
#     $subject=$client +": "+ $error_count +" Snapshot(s) found!"
#     $smtp = new-object System.Net.Mail.SmtpClient($smtp_host)
#     $message = New-Object System.Net.Mail.MailMessage "${from}", "${to}", "${subject}", "${body}`n${body2}"
#     $smtp.Send($message)
# }