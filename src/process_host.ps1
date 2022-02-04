<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.WindowsHosts
  ║   𝑊𝑖𝑛𝑑𝑜𝑤𝑠 𝐻𝑂𝑆𝑇𝑆 𝑓𝑖𝑙𝑒 𝑚𝑎𝑛𝑎𝑔𝑒𝑚𝑒𝑛𝑡              
  ║   
  ║   online_host_url.ps1: Predefined Online Resources for Hosts
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>

 #Requires -Version 7.0

function Build-HostFileFromURL{
  <#
    .SYNOPSIS
      Download a HOSTS file, then parse it.

    .DESCRIPTION
      Will download an HOSTS file from a Url, and assuming entries are found, 
      a custom object is written to the pipeline with the IP Address, name and comment, if any.
  
    .NOTES
      On Windows there is a difference: packets sent to 127.0.0.1 will end up bombarding whatever 
      server you have running on your computer (and you may be running a server without knowing it), 
      whereas trying to send packets 0.0.0.0 will immediately return with error code 1214 (ERROR_INVALID_NETNAME).
      Better to use Use 0.0.0.0
  #>

    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$Url,
        [string]$NewHostFile
    )  
    Write-Host "[START]`t" -f Cyan -NoNewLine
    if($Script:OfflineTest -eq $false){
     
      Write-Host "Process started for $Url "  -f Gray
      }else{
        Write-Host "OFFLINE TEST Process started. Using $Script:OfflineFilePath" -f Gray
      }
    
    $LocalHostsValues = [System.Collections.ArrayList]::new()
    try{
        Write-Verbose "Entering the BEGIN block [$($MyInvocation.MyCommand.CommandType): $($MyInvocation.MyCommand.Name)]."            
        if($Script:OfflineTest){
          Write-Output "DEBUG: Using data from from $Script:OfflineFilePath"
          $HostsData=Get-Content $Script:OfflineFilePath
          $HostsDataLines=(Get-Content -Path $Script:OfflineFilePath | Measure-Object –Line).Lines
          $HostsDataSize=(Get-Content -Path $Script:OfflineFilePath | Measure-Object -Property length -Sum).Sum
          $script:steps = $HostsDataLines          
        }else{

              $CurrentPath = (Get-Location).Path
              $TmpFilePath = Join-Path $CurrentPath 'downloaded'
              $Index = $Url.LastIndexOf('/') + 1
              $Name = $Url.Substring($Index)
              $TmpFilePath = Join-Path $TmpFilePath $Name  
              New-Item -Path $TmpFilePath -ItemType File -Force -EA Ignore | Out-Null 
              Remove-Item -Path $TmpFilePath -Force -EA Ignore | Out-Null 
          

          Get-OnlineFile $Url $TmpFilePath
          $HostsData=Get-Content -Path $TmpFilePath
          $HostsDataLines=(Get-Content -Path $TmpFilePath | Measure-Object –Line).Lines
          $HostsDataSize=(Get-Content -Path $TmpFilePath | Measure-Object -Property length -Sum).Sum
          $script:steps = $HostsDataLines
        }
  
      }catch{
          ScriptException($_)
          return $false
      }finally{
        Write-Output "Download complete! ($HostsDataSize bytes)"
      }

      try{
        #Write-Host "Parsing " -f Gray -NoNewLine
        #Write-Host "$TmpFilePath" -f Cyan
        $Script:ProgressTitle = 'STATE: PARSING'
        $stepCounter = 0
        #define a regex to return first NON-whitespace character
        [regex]$r="\S"
        #strip out any lines beginning with # and blank lines
        if ($HostsData){
          #only process if something was found in HOSTS

          $HostsData | foreach {
            if( (($r.Match($_)).value -ne "#") -and ($_ -notmatch "^\s+$") -and ($_.Length -gt 0) ){
            # named values
             $_ -match "(?<IP>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(?<HOSTNAME>\S+)" | Out-Null
                  $ip=$matches.ip
                  $hostname=$matches.hostname  
                          
                   #get a comment if defined for the line
                   if ($_.contains("#")){
                    $comment=$_.substring($_.indexof("#")+1)
                   }
                   else {
                    $comment=$null
                   }
           
                 
                  if(($Script:OverrideIPAddress -ne $null)-And($Script:OverrideIPAddress -ne '')){
                    $ip = $Script:OverrideIPAddress
                  }
                  $array=$hostname.Split('.')
                  $N = $array.Count - 1
                  $H1 = ''
                  $H2 = ''
                  $H3 = ''
                  if($N -ge 2){
                      $H1 = $array.Get($N)
                      $H2 = $array.Get($N - 1) + '.' + $array.Get($N - 0)
                      $H3 = $array.Get($N - 2) + '.' + $array.Get($N - 1) + '.' + $array.Get($N - 0)
                  }

                  $obj = [PSCustomObject]@{
                      IP          = $ip
                      Hostname    = $hostname
                      Comment     = $comment
                      TopLevelDomain      = $H1
                      Domain      = $H2
                      SubDomain    = $H3
                    }
                  
                   $null=$LocalHostsValues.Add($obj)
                   #$ip = '0.0.0.0'

                   Write-ProgressHelper -Message "Parsing HOSTS file... ($stepCounter / $Script:Steps)" -StepNumber ($stepCounter++)
                   #$formatstring = "{0}`t{1}`t# {2}"
                   #$fields = $ip,$hostname, $comment
                   #$entry=($formatstring -f $fields)
                   #Add-Content -Path $NewHostFile -Value $entry
                }
           }
         }
        
      }
      catch{
          ScriptException($_) -ShowStack
          return $false
        }
      finally{
        $LocalHostsValuesCount = $LocalHostsValues.Count
        Write-Host "[OK]`t" -f DarkGreen -NoNewLine
        Write-Host "Parsing complete! $LocalHostsValuesCount entries."
        Write-Progress -Activity $Script:ProgressTitle -Completed
      }
  return $LocalHostsValues
} # End Function



function New-HostFile { 
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
