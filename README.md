# RoboCopy
How I've used RoboCopy to synchronise Windows Servers

Due to the windows scheduler depricating emails I use a Powershell script to send out an email on failure.

This information has been lifted from https://ss64.com/nt/robocopy-exit.html which would appear to be owned by Simon Sheppard
The text below is not mine but I found it very helpful

ROBOCOPY Exit Codes
The return code from Robocopy is a bitmap, defined as follows:

    Hex   Decimal  Meaning if set

    0×00   0       No errors occurred, and no copying was done.
                   The source and destination directory trees are completely synchronized. 

    0×01   1       One or more files were copied successfully (that is, new files have arrived).

    0×02   2       Some Extra files or directories were detected. No files were copied
                   Examine the output log for details. 

    0×04   4       Some Mismatched files or directories were detected.
                   Examine the output log. Housekeeping might be required.

    0×08   8       Some files or directories could not be copied
                   (copy errors occurred and the retry limit was exceeded).
                   Check these errors further.

    0×10  16       Serious error. Robocopy did not copy any files.
                   Either a usage error or an error due to insufficient access privileges
                   on the source or destination directories.
These can be combined, giving a few extra exit codes:

    0×03   3       (2+1) Some files were copied. Additional files were present. No failure was encountered.

    0×05   5       (4+1) Some files were copied. Some files were mismatched. No failure was encountered.

    0×06   6       (4+2) Additional files and mismatched files exist. No files were copied and no failures were encountered.
                   This means that the files already exist in the destination directory

    0×07   7       (4+1+2) Files were copied, a file mismatch was present, and additional files were present.
An Exit Code of 0-7 is success and any value >= 8 indicates that there was at least one failure during the copy operation.
Many deployment tools like SCCM will default to assuming any Exit Code greater than 0 is an error.

You can use this in a batch file to report anomalies, as follows:

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
In PowerShell, use $lastexitcode

Error 0x800700DF: The file size exceeds the limit allowed and cannot be saved.
This error may appear when copying from a WEBdav drive, WEBdav ignores the robocopy/MAX setting.
See Q2668751 for WebDAV size/time limits (default=50 MB/30 minutes).

Example:

Copy files from one server to another

ROBOCOPY \\Server1\reports \\Server2\backup *.*
IF %ERRORLEVEL% LSS 8 goto finish

Echo Something failed & goto :eof

:finish
Echo All done, no fatal errors.
Bugs
Version XP026 returns a success errorlevel even when it fails.

“Few men of action have been able to make a graceful exit at the appropriate time” ~ Malcolm Muggeridge
