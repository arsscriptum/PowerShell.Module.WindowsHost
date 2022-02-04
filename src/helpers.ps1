<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.WindowsHosts
  ║   𝑊𝑖𝑛𝑑𝑜𝑤𝑠 𝐻𝑂𝑆𝑇𝑆 𝑓𝑖𝑙𝑒 𝑚𝑎𝑛𝑎𝑔𝑒𝑚𝑒𝑛𝑡              
  ║   
  ║   online_host_url.ps1: Predefined Online Resources for Hosts
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>


 #Requires -Version 7.0


function Write-ProgressHelper {   ### NOEXPORT

     param (
     [Parameter(Mandatory=$True,Position=0)]
        [int]$StepNumber,
        [Parameter(Mandatory=$True,Position=1)]
        [string]$Message
    ) 
    Write-Progress -Activity $Script:ProgressTitle -Status $Message -PercentComplete (($StepNumber / $Script:Steps) * 100)
}

# ==================================
# Get-HostsValues function
# ==================================
function Global:Get-HostsValuesInMemory{    
  $Data=Get-Variable -Name HOSTSVALUES -Scope Global -ValueOnly -ErrorAction Ignore
  return $Data
}


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
    $responseStream = $response.GetResponseStream()
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $Path, Create
    $buffer = new-object byte[] 10KB
    $count = $responseStream.Read($buffer,0,$buffer.length)
    $Script:stepCounter = 0
    $downloadedBytes = $count
    $script:steps = $totalLength
    while ($count -gt 0){
       $targetStream.Write($buffer, 0, $count)
       $count = $responseStream.Read($buffer,0,$buffer.length)
       $downloadedBytes = $downloadedBytes + $count
       $Script:stepCounter = $([System.Math]::Floor($downloadedBytes/1024))
       Write-ProgressHelper -Message "Downloaded $Script:stepCounter K of $Script:Steps K" -StepNumber ($Script:stepCounter++)
       #Write-Progress -activity "Downloading file '$($url.split('/') | Select -Last 1)'" -status  -PercentComplete ((([System.Math]::Floor($downloadedBytes/1024)) / $totalLength)  * 100)
    }

    $targetStream.Flush()
    $targetStream.Close()
    $targetStream.Dispose()
    $responseStream.Dispose()
  }catch{
      Write-Host -ForegroundColor DarkRed "[!] " -NoNewline
      Write-Host "$_" -ForegroundColor DarkGray
    return $false
  }finally{
    Write-Progress -Activity $Script:ProgressTitle -Completed
    Write-Host "[i] " -f DarkGreen -NoNewLine
    Write-Host "Downloaded $Url" -f Gray
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
    $HostValues = Get-HostsValues
    $hostsLen = $HostValues.Count
    $Script:Steps= $HostValues.Count
    $stepCounter=0

    $Script:ProgressTitle = "Preparing $hostsLen entries."
   
    Write-Host "[WAIT] " -f Red -NoNewLine
    Write-Host "Preparing $hostsLen entries." -f DarkYellow      
    $AllEntries = [System.Collections.ArrayList]::new()
    $CurrentDomain = ''
    $Total = 0
    ForEach($val in $HostValues){
      $Total++
      if($Total -gt 8500){break;}
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
          <#if($CurrentDomain -ne ''){
              $tagstr = "# </$CurrentDomain>`n"
              $null=$AllEntries.Add($tagstr)
              #Write-Verbose "$tagstr"
            }
            $CurrentDomain = $Domain
          #>
          $formatstring = "{0}`t`t{1}"
          $fields = $ip,$hostname  
          $entry=($formatstring -f $fields)
          $null=$AllEntries.Add($entry)
          #Write-Verbose "$entry"
        }else{
          <#if($CurrentDomain -ne $Domain){
            if($CurrentDomain -ne ''){
              $tagstr = "# </$CurrentDomain>`n# <$Domain>"
              $null=$AllEntries.Add($tagstr)
              #Write-Verbose "$tagstr"
            }
            $CurrentDomain = $Domain
          }#>
          $formatstring = "{0}`t`t{1}`t# {2}"
          $fields = $ip,$hostname, $comment  
          $entry=($formatstring -f $fields)
          $null=$AllEntries.Add($entry)
          #Write-Verbose "$entry"
        }
  
        Write-ProgressHelper -Message "preparing entries... ($stepCounter / $Script:Steps)" -StepNumber ($stepCounter++)
    }

    Set-Variable -Name HOSTS_ENTRIES -Scope Global -Option allscope -Value $AllEntries
    Write-Host "[OK]`t" -f DarkGreen -NoNewLine
    Write-Host "Updated Global Variable HOSTS_ENTRIES" -f DarkGray  

    Write-Progress -Activity $Script:ProgressTitle -Completed
    Write-Host "Deleting $Path" -f DarkYellow
    $null = Remove-Item -Path $Path -Force  -ErrorAction Ignore
    Write-Host "Creating $Path" -f DarkYellow
    $null = New-Item -Path $Path -ItemType File -Force
    Write-Host "Writing to $Path" -f DarkYellow


    Set-Content -Path $Path -Value $localhost -ErrorAction Stop
    Add-Content -Path $Path -Value $custom_entries -ErrorAction Stop
    Add-Content -Path $Path -Value $AllEntries -ErrorAction Stop
    Add-Content -Path $Path -Value $acknowledgements -ErrorAction Stop

    Write-Host "Done" -f DarkGreen
}
