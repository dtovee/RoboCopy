# PowerShell Robocopy
# Author: David Tovee
# 07-June-2022
# Version: 1.00

# https://social.technet.microsoft.com/wiki/contents/articles/1073.robocopy-and-a-few-examples.asp
# The following command will mirror the directories using Robocopy:

# Robocopy \\SourceServer\Share \\DestinationServer\Share /MIR /FFT /Z /XA:H /W:5
# Explanation of the switches used:

# /MIR specifies that Robocopy should mirror the source directory and the destination directory. Note that this will delete files at the destination if they were deleted at the source.
# /FFT uses fat file timing instead of NTFS. This means the granularity is a bit less precise. For across-network share operations this seems to be much more reliable - just don't rely on the file timings to be completely precise to the second.
# /Z ensures Robocopy can resume the transfer of a large file in mid-file instead of restarting.
# /XA:H makes Robocopy ignore hidden files, usually these will be system files that we're not interested in.
# /W:5 reduces the wait time between failures to 5 seconds instead of the 30 second default.
# /UniLog:$($Log) Unicode log
# /v verbose.
# /L for testing list only

# inspiration from https://ss64.com/nt/errorlevel.html batch script
# and  Liron Ben-David powershell script https://stackoverflow.com/questions/35727736/robocopy-script-w-powershell-mail-report-for-failure

# Variables
$Debug = 0; # Set 0 off, 1 on
$Testing = 0; # Set 0 off, 1 on
$Source = "L:\doclinks\";
$Destination = "\\<your server>\L$\doclinks\";
# this probably isn't good practice to have on the boot drive...
$Log = "C:\robocopy_script\RobocopyLog.txt"
$Args = "*.* /MIR /FFT /Z /XA:H /W:5 /UniLog:$($Log)";
#$ToEmail = "helpdesksns@<your domain>";
$ToEmail = "dtovee@<your domain>";
$FromEmail = "servicedesk@<your domain>";
$SmptServer = "<your DAG>.<your domain>";
# for testing
if ( $Testing ) {$Args = -join($Args, " /v /L");}
#set default vars
$ExitCodeString = "not set";
$ExitCodeInt = "not set";

# run Robocopy
Robocopy $Source $Destination $Args.Split(" ");

# collect the exit status
$ExitCodeInt = $LASTEXITCODE
# for testinglog
#$ExitCodeInt = 4;

# set the exit code string
if( $ExitCodeInt -eq 16 ) { $ExitCodeString = "***FATAL ERROR***"}
elseif( $ExitCodeInt -eq 15 ) { $ExitCodeString = "OKCOPY + FAIL + MISMATCHES + XTRA"}
elseif( $ExitCodeInt -eq 14 ) { $ExitCodeString = "FAIL + MISMATCHES + XTRA"}
elseif( $ExitCodeInt -eq 13 ) { $ExitCodeString = "OKCOPY + FAIL + MISMATCHES"}
elseif( $ExitCodeInt -eq 12 ) { $ExitCodeString = "FAIL + MISMATCHES"}
elseif( $ExitCodeInt -eq 11 ) { $ExitCodeString = "OKCOPY + FAIL + XTRA"}
elseif( $ExitCodeInt -eq 10 ) { $ExitCodeString = "FAIL + XTRA"}
elseif( $ExitCodeInt -eq 9 ) { $ExitCodeString = "OKCOPY + FAIL"}
elseif( $ExitCodeInt -eq 8 ) { $ExitCodeString = "FAIL"}
elseif( $ExitCodeInt -eq 7 ) { $ExitCodeString = "OKCOPY + MISMATCHES + XTRA"}
elseif( $ExitCodeInt -eq 6 ) { $ExitCodeString = "MISMATCHES + XTRA"}
elseif( $ExitCodeInt -eq 5 ) { $ExitCodeString = "OKCOPY + MISMATCHES"}
elseif( $ExitCodeInt -eq 4 ) { $ExitCodeString = "MISMATCHES"}
elseif( $ExitCodeInt -eq 3 ) { $ExitCodeString = "OKCOPY + XTRA"}
elseif( $ExitCodeInt -eq 2 ) { $ExitCodeString = "XTRA"}
elseif( $ExitCodeInt -eq 1 ) { $ExitCodeString = "OKCOPY"}
elseif( $ExitCodeInt -eq 0 ) { $ExitCodeString = "No Change"}

# Debug Section
if( $Debug ){
	Write-Host "Did the script completed successfully [$($?)]";
	Write-Host "Script Args [$($Source) $($destination) $($Args)]";
	Write-Host "Script Exit Code Int [$($ExitCodeInt)]";
	Write-Host "Script Exit Code String [$($ExitCodeString)]"
	Write-Host "Script Error [$($Error)]";
    #Start-Sleep -s 4
    #$Error = 1;
}

## Failure Report
# if ($Error){
if ($ExitCodeInt > 3 ){
	Write-Host "Send-MailMessage -to $($ToEmail) -From $($env:COMPUTERNAME) -Subject $($env:COMPUTERNAME) - Exit Reason [$($ExitCodeString)] Code [$($ExitCodeInt)] -SmtpServer $($SmptServer) –Attachments $($Log)";
	Send-MailMessage -to $ToEmail -From $FromEmail -Subject "$($env:COMPUTERNAME) - Exit Reason [$($ExitCodeString)] Code [$($ExitCodeInt)]" -SmtpServer $SmptServer –Attachments $Log;
	}
else {
	# The script completed successfully
	if ( $Debug ) { Write-Host 'The script completed successfully';}
	}

# exit with Robocopy's exit code
exit $ExitCodeInt;