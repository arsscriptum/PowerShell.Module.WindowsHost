<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.WindowsHosts
  ║   𝑊𝑖𝑛𝑑𝑜𝑤𝑠 𝐻𝑂𝑆𝑇𝑆 𝑓𝑖𝑙𝑒 𝑚𝑎𝑛𝑎𝑔𝑒𝑚𝑒𝑛𝑡              
  ║   
  ║   online_host_url.ps1: Predefined Online Resources for Hosts
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>

 #Requires -Version 7.0


function Get-OnlineFile 
{
     param (
     [Parameter(Mandatory=$True,Position=0)]
        [string]$Url,
        [Parameter(Mandatory=$True,Position=1)]
        [string]$Path
    ) 
  try{

    $Script:ProgressTitle = 'STATE: DOWNLOAD'
    #Write-Host "Downloading " -f Gray -NoNewLine
    # Write-Host "$Url" -f Cyan
    $uri = New-Object "System.Uri" "$Url"
    $request = [System.Net.HttpWebRequest]::Create($Url)
    $request.set_Timeout(15000) #15 second timeout
    $response = $request.GetResponse()
    $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
    $responseStream = $response.GetResponseStream()
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $Path, Create
    $buffer = new-object byte[] 10KB
    $count = $responseStream.Read($buffer,0,$buffer.length)
    $stepCounter = 0
    $downloadedBytes = $count
    $script:steps = $totalLength
    while ($count -gt 0){
       $targetStream.Write($buffer, 0, $count)
       $count = $responseStream.Read($buffer,0,$buffer.length)
       $downloadedBytes = $downloadedBytes + $count
       $stepCounter = $([System.Math]::Floor($downloadedBytes/1024))
       Write-ProgressHelper -Message "Downloaded $stepCounter K of $Script:Steps K" -StepNumber ($stepCounter++)
       #Write-Progress -activity "Downloading file '$($url.split('/') | Select -Last 1)'" -status  -PercentComplete ((([System.Math]::Floor($downloadedBytes/1024)) / $totalLength)  * 100)
    }

    $targetStream.Flush()
    $targetStream.Close()
    $targetStream.Dispose()
    $responseStream.Dispose()
  }catch{
    Write-Error $_
    return $false
  }finally{
    Write-Progress -Activity $Script:ProgressTitle -Completed
    Write-Host "[OK]`t" -f DarkGreen -NoNewLine
    Write-Host "Downloaded $Url" -f Gray
  }
  return $true
}
