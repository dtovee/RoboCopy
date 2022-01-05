rem -- Run robocopy
robocopy L:\doclinks\ \\<<your destination server>>\L$\doclinks\ /MIR /Z /LOG:C:\robocopy_script\robocopy_last_log.txt

rem -- report on exit status
if %ERRORLEVEL% EQU 16 echo ***FATAL ERROR*** & goto end
if %ERRORLEVEL% EQU 15 echo OKCOPY + FAIL + MISMATCHES + XTRA & goto end
if %ERRORLEVEL% EQU 14 echo FAIL + MISMATCHES + XTRA & goto end
if %ERRORLEVEL% EQU 13 echo OKCOPY + FAIL + MISMATCHES & goto end
if %ERRORLEVEL% EQU 12 echo FAIL + MISMATCHES& goto end
if %ERRORLEVEL% EQU 11 echo OKCOPY + FAIL + XTRA & goto end
if %ERRORLEVEL% EQU 10 echo FAIL + XTRA & goto end
if %ERRORLEVEL% EQU 9 echo OKCOPY + FAIL & goto end
if %ERRORLEVEL% EQU 8 echo FAIL & goto end
if %ERRORLEVEL% EQU 7 echo OKCOPY + MISMATCHES + XTRA & goto end
if %ERRORLEVEL% EQU 6 echo MISMATCHES + XTRA & goto end
if %ERRORLEVEL% EQU 5 echo OKCOPY + MISMATCHES & goto end
if %ERRORLEVEL% EQU 4 echo MISMATCHES & goto end
if %ERRORLEVEL% EQU 3 echo OKCOPY + XTRA & goto end
if %ERRORLEVEL% EQU 2 echo XTRA & goto end
if %ERRORLEVEL% EQU 1 echo OKCOPY & goto end
if %ERRORLEVEL% EQU 0 echo No Change & goto end
:end

if %ERRORLEVEL% EQU 1 exit 0
exit %ERRORLEVEL%


REM https://social.technet.microsoft.com/wiki/contents/articles/1073.robocopy-and-a-few-examples.asp
REM The following command will mirror the directories using Robocopy:

Rem Robocopy F:\inetpub\wwwroot \\nrwcf30.uk.perenco.com\d$\inetpub\wwwroot /MIR /FFT /Z /XA:H /W:5

REM Robocopy \\SourceServer\Share \\DestinationServer\Share /MIR /FFT /Z /XA:H /W:5
REM Explanation of the switches used:

REM /MIR specifies that Robocopy should mirror the source directory and the destination directory. Note that this will delete files at the destination if they were deleted at the source.
REM /FFT uses fat file timing instead of NTFS. This means the granularity is a bit less precise. For across-network share operations this seems to be much more reliable - just don't rely on the file timings to be completely precise to the second.
REM /Z ensures Robocopy can resume the transfer of a large file in mid-file instead of restarting.
REM /XA:H makes Robocopy ignore hidden files, usually these will be system files that we're not interested in.
REM /W:5 reduces the wait time between failures to 5 seconds instead of the 30 second default.
