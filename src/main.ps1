<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.WindowsHosts
  ║   𝑊𝑖𝑛𝑑𝑜𝑤𝑠 𝐻𝑂𝑆𝑇𝑆 𝑓𝑖𝑙𝑒 𝑚𝑎𝑛𝑎𝑔𝑒𝑚𝑒𝑛𝑡              
  ║   
  ║   online_host_url.ps1: Predefined Online Resources for Hosts
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>



function Get-HostFileDirectory{

    $systempath = [environment]::getfolderpath("system") 
    $HostFileDirectory = Join-Path $systempath 'drivers\etc'
    return $HostFileDirectory
}

function Get-HostFilePath{

    $HostFileDirectory = Get-HostFileDirectory
    $HostFilePath = Join-Path $HostFileDirectory 'HOSTS'
    return $HostFilePath
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



function Initialize-WinHostModule{
<#
    .Synopsis
       Setup the module. Needs to be run only once
#>

    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Leaf) ){
                throw "The Path argument must be a json file. Directory paths are not allowed."
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path
    )

    # throw errors on undefined variables
    Set-StrictMode -Version 1

    # stop immediately on error
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    $RegBasePath = "$ENV:OrganizationHKCU\Powershell.Module.WindowsHosts"
    $null=Remove-Item -Path "$RegBasePath" -ErrorAction Ignore -Force -Recurse
    Write-Host -ForegroundColor DarkGreen "[x] " -NoNewline ;Write-Host "reading $Path" 
    $HostsResources = Get-Content -Path  $Path | ConvertFrom-Json
    $HostsResourcesCount = $HostsResources.Count
    Write-Host -ForegroundColor DarkGreen "[x] " -NoNewline ;Write-Host "found $HostsResourcesCount online resources" 
    if($HostsResourcesCount -lt 1){
        throw "No resources found in $Path"
        return
    }
    try {
        $ModPath = $PSScriptRoot
        $null=New-Item -Path "$RegBasePath" -ItemType Directory -ErrorAction Ignore -Force
        $null=New-RegistryValue "$RegBasePath" "module_location" $ModPath "string"
        
        ForEach($hst in $HostsResources){
            $url = $hst.Url
            $name = $hst.Name
            $DateStr = (Get-Date).GetDateTimeFormats()[12]
            $FileHash=$hst.Hash
            $null=New-Item -Path "$RegBasePath\$name" -ItemType Directory -ErrorAction Ignore -Force
            $null=New-RegistryValue "$RegBasePath\$name" "url" "$url" "string"
            Write-Host -ForegroundColor DarkGreen "[i] " -NoNewline ;Write-Host "powershell.module.windowshosts\$name url $name" 
            $null=New-RegistryValue "$RegBasePath\$name" "updated" "$DateStr" "string"
            Write-Host -ForegroundColor DarkGreen "[i] " -NoNewline ;Write-Host "powershell.module.windowshosts\$name updated $DateStr" 
            $null=New-RegistryValue "$RegBasePath\$name" "hash" "$FileHash" "string"
            Write-Host -ForegroundColor DarkGreen "[i] " -NoNewline ;Write-Host "powershell.module.windowshosts\$name hash $FileHash" 
        }
        #Start-RegistryEditor "$RegBasePath"
    }
    catch{
        Show-ExceptionDetails($_) -ShowStack
    }
}

function Build-HostFileData{    ### NOEXPORT
<#
    .Synopsis
       Setup the module. Needs to be run only once
#>

    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Leaf) ){
                throw "The Path argument must be a HOSTS file. Directory paths are not allowed."
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path,
        [Parameter(Mandatory=$false,Position=1)]
        [String]$OverrideIPAddress        
    )

 try{
        
        $HostsData=Get-Content -Path $Path
        $HostsDataLines=(Get-Content -Path $Path | Measure-Object –Line).Lines
        $HostsDataSize=(Get-Content -Path $Path | Measure-Object -Property length -Sum).Sum
        $script:steps = $HostsDataLines
        if(($HostsDataLines -eq 0)-Or($HostsDataSize -eq 0)){
          Write-Host -n -f DarkRed "[!] " 
          Write-Host "HostsDataSize: $HostsDataSize. HostsDataLines: $HostsDataLines" -ForegroundColor DarkGray
          return;
        }
        $LocalHostsValues = [System.Collections.ArrayList]::new()
        Write-Host "Parsing " -f Gray -NoNewLine
        Write-Host "$Path" -f Cyan
        $Script:ProgressTitle = 'STATE: PARSING'
        $Script:stepCounter = 0
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
           
                 
                  if(($OverrideIPAddress -ne $null)-And($OverrideIPAddress -ne '')){
                    $ip = $OverrideIPAddress
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

                   Write-ProgressHelper -Message "Parsing HOSTS file... ($Script:stepCounter / $Script:Steps)" -StepNumber ($Script:stepCounter++)
                   #$formatstring = "{0}`t{1}`t# {2}"
                   #$fields = $ip,$hostname, $comment
                   #$entry=($formatstring -f $fields)
                   #Add-Content -Path $NewHostFile -Value $entry
                }
           }
         }
        
      }
      catch{
          Show-ExceptionDetails($_) -ShowStack
          return $false
        }
      finally{
        $LocalHostsValuesCount = $LocalHostsValues.Count
        Write-Host -n -f DarkGreen "[i] " 
        Write-Host "Parsing complete $LocalHostsValuesCount entries."
        Write-Progress -Activity $Script:ProgressTitle -Completed
      }    

    return $LocalHostsValues      
}

function Update-HostsValues{
<#
    .Synopsis
       Update 
#>
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true,Position=0)]
        [String]$HostFilePath       
    )

    # throw errors on undefined variables
    Set-StrictMode -Version 1

    # stop immediately on error
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

  try {
    $GlobalHostsValues = [System.Collections.ArrayList]::new()
    $RegBasePath = "$ENV:OrganizationHKCU\Powershell.Module.WindowsHosts"
    
    $HostsList=(Get-Item "$RegBasePath\*").PSChildName
    $count=$HostsList.Count
    
    foreach($hst in $HostsList){
        $hurlexists=Test-RegistryValue "$RegBasePath\$hst" 'url'
        $hashexists=Test-RegistryValue "$RegBasePath\$hst" 'hash'
        if($hashexists -and $hurlexists){
            $Url=(Get-ItemProperty "$RegBasePath\$hst").url
            $Hash=(Get-ItemProperty "$RegBasePath\$hst").hash

            # DOWNLOAD
            Write-Host -ForegroundColor DarkYellow "[w] " -NoNewline ;Write-Host "Chech Hash $Hash" 
            # CHECK HASH
            Write-Host -ForegroundColor DarkYellow "[w] " -NoNewline ;Write-Host "Download URL $Url" 
            # PARSE, etc...
            $DateStr = (Get-Date).GetDateTimeFormats()[12]
            $FileHash=$hst.Hash

            $TmpFilePath = (New-TemporaryFile).fullname

            $Downloaded = Get-OnlineFile $Url $TmpFilePath
        
            $DownloadedHash=Get-FileHash $TmpFilePath

            if($FileHash -ne $DownloadedHash){
                Write-Host -ForegroundColor DarkYellow "[w] " -NoNewline ;Write-Host "DIFFERENT HASHES - PARSING" 

                $Data = Build-HostFileData -Path $TmpFilePath -OverrideIPAddress "0.0.0.0"
                $GlobalHostsValues += $Data
                $GlobalHostsValuesCount = $GlobalHostsValues.Count
                Set-Variable -Name HOSTSVALUES -Scope Global -Option allscope -Value $GlobalHostsValues
                Write-Host "[i] " -f DarkGreen -NoNewLine
                Write-Host "Updated Global Variable. $GlobalHostsValuesCount entries." -f DarkGray        
            }else{
                Write-Host -ForegroundColor DarkYellow "[w] " -NoNewline ;Write-Host "SAME HASHES, BAILING"
                continue
            }


            Sleep 1
        }
    }
    $Script:stepCounter = 0
    $Script:ProgressTitle = 'STATE: SORTING'
    Write-ProgressHelper -Message "Sorting all entries..." -StepNumber ($Script:stepCounter++)
    $GlobalHostsValues = ($GlobalHostsValues | Sort-Object -Property "SubDomain" -Descending -Unique)
    Write-Progress -Activity $Script:ProgressTitle -Completed
    Write-Host "[i] " -f DarkGreen -NoNewLine
    Write-Host "Values are sorted, made unique." -f DarkGray
            
    Write-Host "[i] " -f DarkGreen -NoNewLine
    Write-Host "Starting to dump values to '$HostFilePath'" -f DarkGray
    New-HostFile $HostFilePath

  }catch{
      #Show-ExceptionDetails($_) -ShowStack
      Write-Host -ForegroundColor DarkRed "[!] " -NoNewline
      Write-Host "$_" -ForegroundColor DarkGray
  }finally{
      Write-Host -ForegroundColor DarkGreen "[i] " -NoNewline
      Write-Host " update completed" -ForegroundColor DarkGray
  }
}

function List-OnlineResources{
<#
    .Synopsis
       Update 
#>
    [CmdletBinding(SupportsShouldProcess)]
    Param
    ()

    # throw errors on undefined variables
    Set-StrictMode -Version 1

    # stop immediately on error
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

  try {
    $GlobalHostsValues = [System.Collections.ArrayList]::new()
    $RegBasePath = "$ENV:OrganizationHKCU\Powershell.Module.WindowsHosts"
    
    $HostsList=(Get-Item "$RegBasePath\*").PSChildName
    $count=$HostsList.Count
    $i = 0
    foreach($hst in $HostsList){
        $hurlexists=Test-RegistryValue "$RegBasePath\$hst" 'url'
        $hashexists=Test-RegistryValue "$RegBasePath\$hst" 'hash'
        if($hashexists -and $hurlexists){
            $Url=(Get-ItemProperty "$RegBasePath\$hst").url
            $Hash=(Get-ItemProperty "$RegBasePath\$hst").hash
            $Updated=(Get-ItemProperty "$RegBasePath\$hst").updated
            
            $res = [PSCustomObject]@{
                Name        = "$hst"
                Url         = "$Url"
                LastUpdate  = "$Updated"
                Hash        = "$Hash"
            };
            $i++
            $DbgStr = $res | ConvertTo-Json
            Write-Host -f DarkRed "[res id $i]"
            Write-Host "$DbgStr" -f DarkYellow
        }
    }
   

  }catch{
      #Show-ExceptionDetails($_) -ShowStack
      Write-Host -n -f DarkRed "[!] "
      Write-Host "$_" -f DarkGray
  }
}

function New-OnlineResources{
<#
    .Synopsis
       Update 
#>
    [CmdletBinding(SupportsShouldProcess)]
    Param
    ()

    # throw errors on undefined variables
    Set-StrictMode -Version 1

    # stop immediately on error
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

  try {
        Write-Host -n -f DarkRed "[!] "
      Write-Host "NOT IMPLEMENTED" -f DarkYellow

  }catch{
      #Show-ExceptionDetails($_) -ShowStack
      Write-Host -n -f DarkRed "[!] "
      Write-Host "$_" -f DarkGray
  }
}

function Remove-OnlineResources{
<#
    .Synopsis
       Update 
#>
    [CmdletBinding(SupportsShouldProcess)]
    Param
    ()

    # throw errors on undefined variables
    Set-StrictMode -Version 1

    # stop immediately on error
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

  try {
   
        Write-Host -n -f DarkRed "[!] "
      Write-Host "NOT IMPLEMENTED" -f DarkYellow
  }catch{
      #Show-ExceptionDetails($_) -ShowStack
      Write-Host -n -f DarkRed "[!] "
      Write-Host "$_" -f DarkGray
  }
}

