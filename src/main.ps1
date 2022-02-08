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
        Write-MMsg "Reading content..."
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
        Write-verbose "Parsing $Path"
        
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
        Show-ExceptionDetails $_ -ShowStack
        return $false
      }
      finally{
        $LocalHostsValuesCount = $LocalHostsValues.Count
        
        Write-MOk "Parsing complete $LocalHostsValuesCount entries."
        Write-Progress -Activity $Script:ProgressTitle -Completed
      }    

    return $LocalHostsValues      
}
function Get-RawHostsValuesInMemory{
<#
    .Synopsis
       Update 
#>
    [CmdletBinding(SupportsShouldProcess)]
    Param
    ()
    $HostValues = Get-Variable -Name RAW_HOST_VALUES -Scope Global -ValueOnly
    return $HostValues
}


function Get-HostsValuesInMemory{
<#
    .Synopsis
       Update 
#>
    [CmdletBinding(SupportsShouldProcess)]
    Param
    ()
    $HostValues = Get-Variable -Name PROCESSED_HOST_VALUES -Scope Global -ValueOnly
    return $HostValues
}


function Update-HostsValues{
<#
    .Synopsis
       Update 
#>
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true,HelpMessage="The output file path")]
        [String]$Path,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true,HelpMessage="The ip address used for entries")]
        [String]$OverrideIPAddress="0.0.0.0"
    )

    if(Test-Path -PathType Leaf $Path){
        $Null=Remove-Item -Path $Path -Force -ErrorAction Ignore
    }
    $Null=New-Item -Path $Path -Force -ErrorAction Ignore -ItemType File
    $Null=Remove-Item -Path $Path -Force -ErrorAction Ignore
    # throw errors on undefined variables
    Set-StrictMode -Version 1

    # stop immediately on error
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

  try {
    $ShouldUpdateFile = $False
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

            Write-MMsg "Check [$Url]..."
            # PARSE, etc...
            $DateStr = (Get-Date).GetDateTimeFormats()[12]
            $FileHash=$Hash

            
            $TmpFilePath = (New-TemporaryFile).fullname

            Write-verbose "Download $Url to $TmpFilePath"
            $Downloaded = Get-OnlineFile $Url $TmpFilePath
            if($Downloaded -eq $False){
                Write-MError "Download Error ($Url)"
                return
            }
            $DownloadedHash=(Get-FileHash $TmpFilePath).Hash

            if($FileHash -ne $DownloadedHash){
                $ShouldUpdateFile = $True
                Write-verbose "$FileHash vs $DownloadedHash"
                Write-MWarn "DIFFERENT HASHES - PARSING" -h

                $null=Set-RegistryValue "$RegBasePath\$hst" "last_update" "$DateStr" 
                Write-verbose "powershell.module.windowshosts\$hst last_update $DateStr" 
                $null=Set-RegistryValue "$RegBasePath\$hst" "hash" "$DownloadedHash" 
                Write-verbose "powershell.module.windowshosts\$hst hash $DownloadedHash" 
                $TmpFileCopyPath = $TmpFilePath + '.copy'
                Write-verbose "Copy $TmpFilePath to $TmpFileCopyPath"
                Copy-Item $TmpFilePath $TmpFileCopyPath
                Write-verbose "GO Build-HostFileData -Path $TmpFileCopyPath" 
                $Data = Build-HostFileData -Path $TmpFileCopyPath -OverrideIPAddress $OverrideIPAddress
                $GlobalHostsValues += $Data       
            }else{
                Write-MOk "Nothing New from $Url" -h
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
       
    Write-MMsg "Values are sorted, made unique."
    Write-verbose "Starting to dump values to '$Path'"

    $GlobalHostsValuesCount = $GlobalHostsValues.Count
    Set-Variable -Name RAW_HOST_VALUES -Scope Global -Option allscope -Value $GlobalHostsValues            
    Write-MOk "Updated Global Variable. $GlobalHostsValuesCount entries."     

    New-HostFile $Path
    
  }catch{
        Show-ExceptionDetails $_ -ShowStack
        Write-MError "Fatal Error"
        return
  }finally{
      Write-MMsg "update completed"
  }
}


function List-WinHostUrls{
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
    $CurrentList = [System.Collections.ArrayList]::new()
    $RegBasePath = "$ENV:OrganizationHKCU\Powershell.Module.WindowsHosts"
    
    $HostsList=(Get-Item "$RegBasePath\*").PSChildName
    $count=$HostsList.Count
    if($count -eq 0){
        Write-MWarn "no online resources added yet" 
        return
    }
    $i = 0
    foreach($hst in $HostsList){
        $hurlexists=Test-RegistryValue "$RegBasePath\$hst" 'url'
        $hashexists=Test-RegistryValue "$RegBasePath\$hst" 'hash'
        if($hashexists -and $hurlexists){
            $Url=(Get-ItemProperty "$RegBasePath\$hst").url
            $Hash=(Get-ItemProperty "$RegBasePath\$hst").hash
            $Updated=(Get-ItemProperty "$RegBasePath\$hst").last_update
            $AddedOn=(Get-ItemProperty "$RegBasePath\$hst").added_on
            $res = [PSCustomObject]@{
                Id          = "$i"
                Name        = "$hst"
                Url         = "$Url"
                LastUpdate  = "$Updated"
                AddedOn     = "$AddedOn"
                Hash        = "$Hash"
            };
            $i++
            $Null=$CurrentList.Add($res)
        }
    }

    $CurrentList | ft
   

  }catch{
    Show-ExceptionDetails $_ -ShowStack
  }
}

function New-WinHostResource{
<#
    .Synopsis
       Update 
#>
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="The resource name")]
        [String]$Name,
        [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$true,HelpMessage="Resource URL")]
        [String]$Url
    )

    # throw errors on undefined variables
    Set-StrictMode -Version 1

    # stop immediately on error
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

  try {
    $RegBasePath = "$ENV:OrganizationHKCU\Powershell.Module.WindowsHosts"
    Write-MMsg "Validating $Url..." -h
    # first try to get the file from the url
    $TmpFilePath = (New-TemporaryFile).fullname
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile($Url,$TmpFilePath)
    $Size = (Get-Item -Path $TmpFilePath).Length
    if($Size -gt 0){
        Write-verbose "file size $Size bytes" 
        [DateTime]$CurrDate=(Get-Date)

        #$FileHash=Get-FileHash $TmpFilePath
        #$DateStr = CurrDate.GetDateTimeFormats()[12]

        $FileHash='0'     # Bogus, placeholder hash until this res is used ro update the HOST
        $CurrDate = $CurrDate.AddYears(-5)
        $DateStr = $CurrDate.GetDateTimeFormats()[12] # Bogus, placeholder hash until this res is used ro update the HOST
        
        $null=New-Item -Path "$RegBasePath\$Name" -ItemType Directory -ErrorAction Ignore -Force
        $null=New-RegistryValue "$RegBasePath\$Name" "url" "$Url" "string"
        Write-verbose "powershell.module.windowshosts\$Name url $Url" 
        $null=New-RegistryValue "$RegBasePath\$Name" "last_update" "never" "string"
        Write-verbose "powershell.module.windowshosts\$Name last_update never" 
        $null=New-RegistryValue "$RegBasePath\$Name" "hash" "$FileHash" "string"
        Write-verbose "powershell.module.windowshosts\$Name hash $FileHash" 
        $null=New-RegistryValue "$RegBasePath\$Name" "added_on" "$DateStr" "string"
        Write-MOk "Added: $Name $Url" 
        List-WinHostUrls
    }else{
        Write-MError "Invalid file"
        return
    }

  }catch{
    Show-ExceptionDetails $_ -ShowStack
  }
}

function Remove-WinHostResource{

<#
    .Synopsis
       Update 
#>
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,HelpMessage="The resource name")]
        [String]$Name
    )

    # throw errors on undefined variables
    Set-StrictMode -Version 1

    # stop immediately on error
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

  try {
    $RegBasePath = "$ENV:OrganizationHKCU\Powershell.Module.WindowsHosts"
    
    $null=Remove-Item -Path "$RegBasePath\$Name" -ErrorAction Ignore -Force -Recurse
    Write-MOk "Removed: $Name" 
    List-WinHostUrls


  }catch{
    Show-ExceptionDetails $_ -ShowStack
  }
}