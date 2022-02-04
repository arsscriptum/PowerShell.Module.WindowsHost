<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.WindowsHosts
  ║   𝑊𝑖𝑛𝑑𝑜𝑤𝑠 𝐻𝑂𝑆𝑇𝑆 𝑓𝑖𝑙𝑒 𝑚𝑎𝑛𝑎𝑔𝑒𝑚𝑒𝑛𝑡              
  ║   
  ║   online_host_url.ps1: Predefined Online Resources for Hosts
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>

function Initialize-WinHostModule{
<#
    .Synopsis
       Setup the module. Needs to be run only once
#>

    [CmdletBinding(SupportsShouldProcess)]
    param()

    # throw errors on undefined variables
    Set-StrictMode -Version 1

    # stop immediately on error
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    try {
        $null=New-RegistryValue "$ENV:OrganizationHKCU\powershell.module.windowshosts" "save_location" $Path "string"

        ForEach($hst in $HostsList){
            $url = $hst.url
            $name = $hst.name
            $DateStr = (Get-Date).GetDateTimeFormats()[12]
            $FileHash=''
            New-Item -Path "$ENV:OrganizationHKCU\powershell.module.windowshosts\$name" -ItemType Directory -ErrorAction Ignore
            $null=New-RegistryValue "$ENV:OrganizationHKCU\powershell.module.windowshosts\$name" "url" $url "string"
            Write-Host -ForegroundColor DarkGreen "[x] " -NoNewline ;Write-Host "powershell.module.windowshosts\$name url $name" 
            $null=New-RegistryValue "$ENV:OrganizationHKCU\powershell.module.windowshosts\$name" "updated" $DateStr "string"
            Write-Host -ForegroundColor DarkGreen "[x] " -NoNewline ;Write-Host "powershell.module.windowshosts\$name updated $DateStr" 
            $null=New-RegistryValue "$ENV:OrganizationHKCU\powershell.module.windowshosts\$name" "hash" $FileHash "string"
            Write-Host -ForegroundColor DarkGreen "[x] " -NoNewline ;Write-Host "powershell.module.windowshosts\$name hash $FileHash" 
        }
    }
    catch{
        Show-ExceptionDetails($_) -ShowStack
    }

}


function Update-HostsValues{
<#
    .Synopsis
       Update 
#>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param ()

    # throw errors on undefined variables
    Set-StrictMode -Version 1

    # stop immediately on error
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    try {

    $RegBasePath = "$ENV:OrganizationHKCU\powershell.module.windowshosts\"
    
    $HostsList=(Get-Item "$RegBasePath\*").PSChildName
    $count=$HostsList.Count
    Write-Verbose "Repair-AllShims: get entries in $RegBasePath* : $count"
   
    foreach($hst in $HostsList){
      $hurlexists=Test-RegistryValue "$RegBasePath\$hst" 'url'
      $hashexists=Test-RegistryValue "$RegBasePath\$hst" 'hash'
      if($hashexists -and $hurlexists){
        $Url=(Get-ItemProperty "$RegBasePath\$hst").url
        $Hash=(Get-ItemProperty "$RegBasePath\$hst").hash

        # DOWNLOAD
        # CHECK HASH
        # PARSE, etc...
        
        Sleep 1
      }
    }

    }catch{
      Show-ExceptionDetails($_) -ShowStack
    }
    finally{
      Write-Host -ForegroundColor DarkGreen "[DONE] " -NoNewline
      Write-Host " update completed" -ForegroundColor DarkGray
  }
}
