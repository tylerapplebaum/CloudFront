Function Process-AWSCloudFrontLogs {
param(
[CmdletBinding()]
    [Parameter(HelpMessage="Specify the path to the directory containing CloudFront log files in .txt format")]
    [ValidateScript({Test-Path $_ -PathType 'Container'})]$LogDir
)
$LogArr = New-Object System.Collections.ArrayList
$LogFilesRaw = Get-ChildItem -Path $LogDir -Filter *.txt
    ForEach ($LogFileRaw in $LogFilesRaw) {
        $LogContent = Get-Content $LogFileRaw.Fullname | Where-Object Length -gt 0 | Select-String -Pattern '#Version: 1.0|#Fields: ' -NotMatch #Filter out log file headers
        ForEach ($LogEntry in $LogContent){
            $LogData = $LogEntry.Line.Split("`t") 
            $LogProperties = [Ordered]@{ #Null LogData is marked with a '-'
                'date' = $LogData[0]
                'time' = $LogData[1]
                'x-edge-location' = $LogData[2]
                'sc-bytes' = $LogData[3]
                'c-ip' = $LogData[4]
                'cs-method' = $LogData[5]
                'cs(Host)' = $LogData[6]
                'cs-uri-stem' = $LogData[7]
                'sc-status' = $LogData[8]
                'cs(Referer)' = $LogData[9]
                'cs(User-Agent)' = [System.Uri]::UnescapeDataString([System.Uri]::UnescapeDataString($LogData[10])) #wack
                'cs-uri-query' = $LogData[11]
                'cs(Cookie)' = $LogData[12]
                'x-edge-result-type' = $LogData[13]
                'x-edge-request-id' = $LogData[14]
                'x-host-header' = $LogData[15]
                'cs-protocol' = $LogData[16]
                'cs-bytes' = $LogData[17]
                'time-taken' = $LogData[18]
                'x-forwarded-for' = $LogData[19]
                'ssl-protocol' = $LogData[20]
                'ssl-cipher' = $LogData[21]
                'x-edge-response-result-type' = $LogData[22]
                'cs-protocol-version' = $LogData[23]
                'fle-status' = $LogData[24]
                'fle-encrypted-fields' = $LogData[25]
                'c-port' = $LogData[26]
                'time-to-first-byte' = $LogData[27]
                'x-edge-detailed-result-type' = $LogData[28]
                'sc-content-type' = $LogData[29]
                'sc-content-len' = $LogData[30]
                'sc-range-start' = $LogData[31]
                'sc-range-end' = $LogData[32]
            }
            $LogObject = New-Object PSObject -Property $LogProperties
            $LogArr.Add($LogObject) | Out-Null
        }
        $LogArr | Export-CSV -Path $LogDir\CloudFront-Logs-$(Get-Date -Format yyyy-MM-dd).csv -NoTypeInformation -Append
    }
} #End Process-AWSCloudFrontLogs
