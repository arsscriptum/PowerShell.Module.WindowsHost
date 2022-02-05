

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
        [Parameter(Mandatory=$false)]
        [String]$Path,
        [Parameter(Mandatory=$false)]
        [switch]$Force        
    )
  try {
    # throw errors on undefined variables
    Set-StrictMode -Version 1

    # stop immediately on error
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    $RegBasePath = "$ENV:OrganizationHKCU\Powershell.Module.WindowsHosts"
    if($Force -eq $False){
        $RegBasePath = "$ENV:OrganizationHKCU\Powershell.Module.WindowsHosts"
        $modloc=Test-RegistryValue "$RegBasePath" "module_location"
        $initdate=Test-RegistryValue "$RegBasePath" "initialized"  
        if($modloc -and $initdate){
            $ModPath=Get-RegistryValue "$RegBasePath" "module_location"
            $InitDateStr=Get-RegistryValue "$RegBasePath" "initialized"    
            Write-MOk "module state: already initialized on $InitDateStr" 
            return
        }  
    }else{
        Write-MWarn "Force initialisation (re-init)" 
    }

    $null=Remove-Item -Path "$RegBasePath" -ErrorAction Ignore -Force -Recurse
    $ModPath = $Script:MyInvocation.MyCommand.Path
    $InitDateStr = (Get-Date).GetDateTimeFormats()[12]
    $null=New-Item -Path "$RegBasePath" -ItemType Directory -ErrorAction Ignore -Force
    $null=New-RegistryValue "$RegBasePath" "module_location" $ModPath "string"
    $null=New-RegistryValue "$RegBasePath" "initialized" $InitDateStr "string"
    If( $PSBoundParameters.ContainsKey('Path') -eq $False ){ 
        Write-MMsg "empty init" 
        return
    }
    $HostsResources = Get-Content -Path  $Path | ConvertFrom-Json
    $HostsResourcesCount = $HostsResources.Count
    Write-MMsg "found $HostsResourcesCount online resources" 
    if($HostsResourcesCount -lt 1){
        throw "No resources found in $Path"
        return
    }
    
    ForEach($hst in $HostsResources){
        $url = $hst.Url
        $name = $hst.Name
        $DateStr = (Get-Date).GetDateTimeFormats()[12]
        $FileHash=$hst.Hash
        $null=New-Item -Path "$RegBasePath\$name" -ItemType Directory -ErrorAction Ignore -Force
        $null=New-RegistryValue "$RegBasePath\$name" "url" "$url" "string"
        Write-MOk "powershell.module.windowshosts\$name url $name" 
        $null=New-RegistryValue "$RegBasePath\$name" "last_update" "never" "string"
        Write-MOk "powershell.module.windowshosts\$name last_update never" 
        $null=New-RegistryValue "$RegBasePath\$name" "hash" "$FileHash" "string"
        Write-MOk "powershell.module.windowshosts\$name hash $FileHash" 
        $null=New-RegistryValue "$RegBasePath\$name" "added_on" "$DateStr" "string"
        Write-MOk "powershell.module.windowshosts\$name added_on $DateStr"             
    }
    #Start-RegistryEditor "$RegBasePath"
  }
  catch{
    Show-ExceptionDetails($_) -ShowStack
  }
}



function Check-WinHostModuleInitStatus{
<#
    .Synopsis
       Setup the module. Needs to be run only once
#>

    [CmdletBinding(SupportsShouldProcess)]
    Param
    ()

    # throw errors on undefined variables
    Set-StrictMode -Version 1

    # stop immediately on error
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

    $RegBasePath = "$ENV:OrganizationHKCU\Powershell.Module.WindowsHosts"

    try{
        $modloc=Test-RegistryValue "$RegBasePath" "module_location"
        $initdate=Test-RegistryValue "$RegBasePath" "initialized"  
        if($modloc -and $initdate){
            $ModPath=Get-RegistryValue "$RegBasePath" "module_location"
            $InitDateStr=Get-RegistryValue "$RegBasePath" "initialized"    
            Write-MOk "module state: initialized on $InitDateStr" 
            return $true
        }else{
            Write-MWarn "module state: not initialized" 
            return $false    
        }
    }catch{
        Write-MWarn "module state: not initialized" 
        return $false
    }
    return $true
}
