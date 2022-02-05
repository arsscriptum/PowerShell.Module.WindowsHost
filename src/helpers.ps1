<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.WindowsHosts
  ║   𝑊𝑖𝑛𝑑𝑜𝑤𝑠 𝐻𝑂𝑆𝑇𝑆 𝑓𝑖𝑙𝑒 𝑚𝑎𝑛𝑎𝑔𝑒𝑚𝑒𝑛𝑡              
  ║   
  ║   online_host_url.ps1: Predefined Online Resources for Hosts
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>


 #Requires -Version 7.0


#===============================================================================
# ChannelProperties
#===============================================================================

class ChannelProperties
{
    #ChannelProperties
    [string]$Channel = 'WindowsHosts'
    [ConsoleColor]$TitleColor = 'Blue'
    [ConsoleColor]$NormalTextColor = 'DarkGray'
    [ConsoleColor]$InfoColor = 'DarkCyan'
    [ConsoleColor]$WarnColor = 'DarkYellow'
    [ConsoleColor]$ErrorColor = 'DarkRed'
    [ConsoleColor]$SuccessColor = 'DarkGreen'
    [ConsoleColor]$ErrorDescriptionColor = 'DarkYellow'
}
$Script:ChannelProps = [ChannelProperties]::new()


function Write-MMsg{               # NOEXPORT   
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [Parameter(Mandatory=$false,Position=1)]
        [Alias('h','y')]
        [switch]$Highlight
    )
    if($Highlight){
        Write-Host "⚡ $Message"
    }else{
        Write-Host "⚡ $Message" -f DarkGray
    }
}


function Write-MOk{                        # NOEXPORT        
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [Parameter(Mandatory=$false,Position=1)]
        [Alias('h','y')]
        [switch]$Highlight
    )
    
    if($Highlight){
        Write-Host "✅ $Message"
    }else{
        Write-Host "✅ $Message" -f DarkGray
    }
}

function Write-MWarn{                # NOEXPORT                 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [Parameter(Mandatory=$false,Position=1)]
        [Alias('h','y')]
        [switch]$Highlight
    )
    if($Highlight){
        Write-Host "❗ $Message" -f DarkYellow
    }else{
        Write-Host "❗ $Message" -f DarkGray
    }
    
}

function Write-MError{                # NOEXPORT                 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [Parameter(Mandatory=$false,Position=1)]
        [Alias('h','y')]
        [switch]$Highlight
    )
    if($Highlight){
        Write-Host "❗ $Message" -f DarkYellow
    }else{
        Write-Host "❗ $Message" -f DarkGray
    }
    
}


function Write-MException{                # NOEXPORT                 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.ErrorRecord]$Record
    )
    $formatstring = "{0}`n{1}"
    $fields = $Record.FullyQualifiedErrorId,$Record.Exception.ToString()
    $ExceptMsg=($formatstring -f $fields)
    Write-Host "❗ $ExceptMsg" -f DarkYellow
}


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
      
      Write-MError "$_" 
    return $false
  }finally{
    Write-Progress -Activity $Script:ProgressTitle -Completed
    
    Write-MMsg "Downloaded $Url" -h
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
    $HostValues = Get-HostsValuesInMemory|Sort-Object -Property Domain,Hostname -Descending
   
    $hostsLen = $HostValues.Count
    $Script:Steps= $HostValues.Count
    $Script:stepCounter=0

    $Script:ProgressTitle = "Preparing $hostsLen entries."
   
    
    Write-MMsg "Preparing $hostsLen entries." -h
    $Script:AllEntries = [System.Collections.ArrayList]::new()
    $LastDomain = ''
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
  
        Write-ProgressHelper -Message "preparing entries... ($Script:stepCounter / $Script:Steps)" -StepNumber ($Script:stepCounter++)
    }

    Set-Variable -Name HOSTS_ENTRIES -Scope Global -Option allscope -Value $Script:AllEntries
    
    Write-MMsg "Updated Global Variable HOSTS_ENTRIES. Use 'Get-HostsValuesInMemory' to retrieve them in memory" -h  
 
    Write-Progress -Activity $Script:ProgressTitle -Completed
    Write-MOk "Deleting $Path" -h
    $null = Remove-Item -Path $Path -Force  -ErrorAction Ignore
    Write-MOk "Creating $Path" -h
    $null = New-Item -Path $Path -ItemType File -Force
    Write-MOk "Writing to $Path" -h

    Set-Content -Path $Path -Value $Script:localhost -ErrorAction Stop
    Add-Content -Path $Path -Value $Script:custom_entries -ErrorAction Stop
    Add-Content -Path $Path -Value $Script:AllEntries -ErrorAction Stop
    Add-Content -Path $Path -Value $Script:acknowledgements -ErrorAction Stop

    Write-MOk "Done"
}
