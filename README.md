# FTP_UPandDOWNLOAD

For automated download and upload to FTP i'm using Powershell with an .NET assembly from WinSCP https://winscp.net/eng/download.php and starting the script with windows task scheduler.

The script needs a CSV-File as parameter with the info what to do. The fields in the CSV-File are: direction;filepath;filename;ftpserver;ftpusername;ftppassword

direction: UPLOAD or DOWNLOAD (to FTP)
filepath: the folderpath in the filesystem (without filename)
filename: the filename only
ftpserver: the FTP server address without FTP://
ftpusername: the FTP username
ftppasswort: the FTP password

I use one CSV file for Upload and one file for Download.

With task scheduler i start

C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe C:\scripts\FTP_UPandDOWNLOAD.ps1 C:\scripts\FTPupload.csv

at a different time than

C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe C:\scripts\FTP_UPandDOWNLOAD.ps1 C:\scripts\FTPdownload.csv
