param(
[Parameter(Mandatory=$true)][String]$csvfile
)

if (!(Test-Path($csvfile))) {
	Exit
}
	
Import-Module .\modules\log.psm1

$logfile = getLOGFILE FTP_UPandDownload "" $true

Start-Transcript -path $logfile -append | out-null

Add-Type -Path ".\lib\WinSCPnet.dll"
$transferOptions = New-Object WinSCP.TransferOptions
$transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
$session = New-Object WinSCP.Session

$CSV = import-csv $csvfile -Delimiter ";" -Encoding UTF8  | sort ftpserver,ftpusername,filepath

foreach ($entry in $CSV) {
	if (!$entry.direction.StartsWith("#")) {
		if ($session.Opened -and (!($sessionOptions.HostName -eq $entry.ftpserver -and $sessionOptions.UserName -eq $entry.ftpusername))){
			"Disconnecting" | out-default
			"---" | out-default
			$session.Close()
		} 
					
		if (!($session.Opened)){
			if ($entry.ftpserver -and $entry.ftpusername -and $entry.ftppassword) {
				$sessionOptions = New-Object WinSCP.SessionOptions -Property @{Protocol = [WinSCP.Protocol]::ftp; HostName = $entry.ftpserver ; UserName = $entry.ftpusername; Password = $entry.ftppassword}
				"Connecting to " + $entry.ftpserver + " with username " + $entry.ftpusername | out-default
				Try {
					$session.Open($sessionOptions)
				} catch {
					"Connection failed" | out-default
					continue
				}
			} else {
				"Error: Missing or wrong arguments in CSV-File" | out-default
				$entry.direction = $null
			}
		}
		
		if ($session.Opened) {
			if ($entry.direction -eq "UPLOAD") {
				$fullfilename = Join-Path -Path $entry.filepath -ChildPath $entry.filename
				if (Test-Path ($fullfilename)) {							
					if (!$entry.remotepath) {
						$remotepath = "/"
					}				
					if ($entry.remotepath -like "*%*") {
						$remotepath = $entry.remotepath -replace("%filename%",[System.IO.Path]::GetFileNameWithoutExtension($entry.filename)) 
						$remotepath = $remotepath -replace("%yyyy%",(get-date -f yyyy))
						$remotepath = $remotepath -replace("%MM%",(get-date -f MM))
						$remotepath = $remotepath -replace("%dd%",(get-date -f dd))
					}
					
					"Uploading: " + $entry.filename + " to " + $remotepath | out-default
					
					$status = $session.PutFiles($fullfilename, $remotepath, $False, $transferOptions)
					if ($status.IsSuccess) {
						"Success" | out-default
					} else {
						"Error: " + $status.Transfers.Error + $status.Failures | out-default
					}
				} else {
					"Error: Local file not found: " + $fullfilename | out-default
				}
			} elseif($entry.direction -eq "DOWNLOAD") {
				"Downloading: " + $entry.filename | out-default
				if ($session.FileExists($entry.filename)) {
					$status = $session.GetFiles($entry.filename, $entry.filepath, $False, $transferOptions)

					if ($status.IsSuccess) {
						"Success" | out-default
					} else {
						"Error: " + $status.Transfers.Error + $status.Failures  | out-default
					}
				} else {
					"Error: Remote file not found: " + $entry.filename | out-default
				}
			}
		}
	}
}
if ($session.Opened) {
	"Disconnecting" | out-default
	$session.Close()
}
Stop-Transcript