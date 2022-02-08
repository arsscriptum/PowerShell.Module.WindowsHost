<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.WindowsHosts
  ║   𝑊𝑖𝑛𝑑𝑜𝑤𝑠 𝐻𝑂𝑆𝑇𝑆 𝑓𝑖𝑙𝑒 𝑚𝑎𝑛𝑎𝑔𝑒𝑚𝑒𝑛𝑡              
  ║   
  ║   helpers.ps1: Predefined Online Resources for Hosts
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>


 #Requires -Version 7.0


function Get-OnlineFile{   ### NOEXPORT
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
    $totalLengthBytes = [System.Math]::Floor($response.get_ContentLength())
    $responseStream = $response.GetResponseStream()
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $Path, Create
    $buffer = new-object byte[] 10KB
    $count = $responseStream.Read($buffer,0,$buffer.length)
    $dlkb = 0
    $downloadedBytes = $count
    $script:steps = $totalLength
    while ($count -gt 0){
       $targetStream.Write($buffer, 0, $count)
       $count = $responseStream.Read($buffer,0,$buffer.length)
       $downloadedBytes = $downloadedBytes + $count
       $dlkb = $([System.Math]::Floor($downloadedBytes/1024))
       $msg = "Downloaded $dlkb Kb of $totalLength Kb"
       $perc = (($downloadedBytes / $totalLengthBytes)*100)
       Write-Progress -Activity $Script:ProgressTitle -Status $msg -PercentComplete $perc
    }

    $targetStream.Flush()
    $targetStream.Close()
    $targetStream.Dispose()
    $responseStream.Dispose()
  }catch{
    Show-ExceptionDetails $_ -ShowStack
    return $false
  }finally{
    Write-Progress -Activity $Script:ProgressTitle -Completed
    
    Write-verbose "Downloaded $Url"
  }
  return $true
}


function New-HostFile {  ### NOEXPORT
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$Path
    )  
  try{    
    $HostValues = Get-HostsValuesInMemory|Sort-Object -Property Domain,Hostname -Descending
   
    $hostsLen = $HostValues.Count
    $Script:Steps= $HostValues.Count
    $stepCounter=0

    $Script:ProgressTitle = "Preparing $hostsLen entries."
   
    
    Write-MMsg "Preparing $hostsLen entries." -h
    $Script:AllEntries = [System.Collections.ArrayList]::new()
    $LastDomain = ''
    $Total = 0
    $CountUi = 0
    ForEach($val in $HostValues){
      $Total++
      $CountUi++
      if($CountUi -gt 10000){$CountUi = 0;Write-MMsg "So far 10K entries for $Total total!";}
        $IP = $val.IP
        $Hostname = $val.Hostname
        $HostnameLen = $Hostname.Length
        $Diff = 50 - $HostnameLen
        if($HostnameLen -lt 50){
            for($i = 0 ; $i -lt $Diff ; $i++){
                $Hostname += ' '
            }
        } 
        $Comment = $val.Comment
        $TopLevelDomain = $val.TopLevelDomain
        $Domain = $val.Domain
        $SubDomain = $val.SubDomain
        $CommentLen = $Comment.Length
        if($CommentLen -eq 0){
            $Comment = 'Domain ' + $Domain 
        }
        if($Domain -eq ''){
          $formatstring = "{0}`t`t{1}"
          $fields = $ip,$hostname  
          $entry=($formatstring -f $fields)
          $null=$Script:AllEntries.Add($entry)
        }else{
            if($Domain -ne $LastDomain){
                $LastDomain=$Domain
                $formatstring = "{0}`t`t{1}`t# {2}"
                $fields = $ip,$hostname, $comment  
                $entry=($formatstring -f $fields)
                $null=$Script:AllEntries.Add($entry)
            }else{
                $formatstring = "{0}`t`t{1}`t# +"
                $fields = $ip,$hostname
                $entry=($formatstring -f $fields)
                $null=$Script:AllEntries.Add($entry)
            }
        }
  
        Write-ProgressHelper -Message "preparing entries... ($stepCounter / $Script:Steps)" -StepNumber ($stepCounter++)
    }

    Set-Variable -Name HOSTS_ENTRIES -Scope Global -Option allscope -Value $Script:AllEntries
    
    Write-MMsg "Updated Global Variable HOSTS_ENTRIES. Use 'Get-HostsValuesInMemory' to retrieve them in memory" -h  
 
    Write-Progress -Activity $Script:ProgressTitle -Completed
    
    $null = Remove-Item -Path $Path -Force  -ErrorAction Ignore
    
    $null = New-Item -Path $Path -ItemType File -Force
    Write-MOk "Writing to $Path" -h

    $lcl = Get-LocalHostEntries
    $cet = Get-CustomEntries
    $ack = Get-Acknowledgements
    Set-Content -Path $Path -Value $lcl -ErrorAction Stop
    Write-MMsg "Writing Local Host Entries..."
    Add-Content -Path $Path -Value $cet -ErrorAction Stop
    Write-MMsg "Custom Entries..."
    Add-Content -Path $Path -Value $Script:AllEntries -ErrorAction Stop
    Write-MMsg "Online Entries..."
    Add-Content -Path $Path -Value $ack -ErrorAction Stop
    Write-MMsg "Acknowledgements..."
    Write-MOk "Done"
  }catch{
    Show-ExceptionDetails $_ -ShowStack
    return 
  }finally{
    Write-Progress -Activity $Script:ProgressTitle -Completed
  }
  return    
}
