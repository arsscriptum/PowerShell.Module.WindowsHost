

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

# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUsHLcLjjk80F4zzGgMjkclmKn
# 236gggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0yMjAyMDkyMzI4NDRaFw0zOTEyMzEyMzU5NTlaMCUxIzAhBgNVBAMTGkFyc1Nj
# cmlwdHVtIFBvd2VyU2hlbGwgQ1NDMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
# CgKCAQEA60ec8x1ehhllMQ4t+AX05JLoCa90P7LIqhn6Zcqr+kvLSYYp3sOJ3oVy
# hv0wUFZUIAJIahv5lS1aSY39CCNN+w47aKGI9uLTDmw22JmsanE9w4vrqKLwqp2K
# +jPn2tj5OFVilNbikqpbH5bbUINnKCDRPnBld1D+xoQs/iGKod3xhYuIdYze2Edr
# 5WWTKvTIEqcEobsuT/VlfglPxJW4MbHXRn16jS+KN3EFNHgKp4e1Px0bhVQvIb9V
# 3ODwC2drbaJ+f5PXkD1lX28VCQDhoAOjr02HUuipVedhjubfCmM33+LRoD7u6aEl
# KUUnbOnC3gVVIGcCXWsrgyvyjqM2WQIDAQABo3YwdDATBgNVHSUEDDAKBggrBgEF
# BQcDAzBdBgNVHQEEVjBUgBD8gBzCH4SdVIksYQ0DovzKoS4wLDEqMCgGA1UEAxMh
# UG93ZXJTaGVsbCBMb2NhbCBDZXJ0aWZpY2F0ZSBSb290ghABvvi0sAAYvk29NHWg
# Q1DUMAkGBSsOAwIdBQADggEBAI8+KceC8Pk+lL3s/ZY1v1ZO6jj9cKMYlMJqT0yT
# 3WEXZdb7MJ5gkDrWw1FoTg0pqz7m8l6RSWL74sFDeAUaOQEi/axV13vJ12sQm6Me
# 3QZHiiPzr/pSQ98qcDp9jR8iZorHZ5163TZue1cW8ZawZRhhtHJfD0Sy64kcmNN/
# 56TCroA75XdrSGjjg+gGevg0LoZg2jpYYhLipOFpWzAJqk/zt0K9xHRuoBUpvCze
# yrR9MljczZV0NWl3oVDu+pNQx1ALBt9h8YpikYHYrl8R5xt3rh9BuonabUZsTaw+
# xzzT9U9JMxNv05QeJHCgdCN3lobObv0IA6e/xTHkdlXTsdgxggHhMIIB3QIBATBA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdAIQ
# mkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUvc1e2twb/IBZloRMS5JC
# 0+H/3qIwDQYJKoZIhvcNAQEBBQAEggEAAUx7s6H33JqwBqtY6UBCu6QHWnhyvO4X
# HzZ6we1RqJc/E9JyCa5Qd5HOOZJ+8lBNeFr153f0skX5DxTzU8XssOvVjWHubJ1S
# 9VcEMZGsWdmS45PmHfCan5Lt//wMXb4HAG3gpqMA1nEzqA4qS6jwdBNFtjlH/2z/
# GFOuo0jujUo78VXC7a9+9N9LCVYHVDJawPFe9vG3bsLlGPZM9a/EIwjI/gZ0/kZ0
# nn6laIiF4viDnbCgkFJ5Or3+JkXFM10NMgOvIqIpyWWBbs49DOLAKPfZST4zm96u
# l8VtrWas5rZ31i9pscLmWwh1SRMW85oWg7I+4axrcq+C5yVVCEwrZA==
# SIG # End signature block
