<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.WindowsHosts
  ║   𝑊𝑖𝑛𝑑𝑜𝑤𝑠 𝐻𝑂𝑆𝑇𝑆 𝑓𝑖𝑙𝑒 𝑚𝑎𝑛𝑎𝑔𝑒𝑚𝑒𝑛𝑡              
  ║   
  ║   online_host_url.ps1: Predefined Online Resources for Hosts
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>


    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $false)]
        [String]$Path,
        [Parameter(Mandatory = $false)]
        [switch]$Test
    )    
<#
    .Synopsis
       Setup the module. Needs to be run only once
#>

    try{
        If( $PSBoundParameters.ContainsKey('Path') -eq $False ){ 
            $ModulePath = (Resolve-Path "$PSScriptRoot\..").Path
            $ResPath = Join-Path $ModulePath 'res'
            $Path = Join-Path $ResPath 'online_resources.json'
            if($Test){
                $Path = Join-Path $ResPath 'online_resources_test.json'
            }
            New-Item -Path $ResPath -ItemType Directory -ErrorAction Ignore -Force| Out-Null
            Write-output "Generating $Path"
        }

        $InitDateStr = (Get-Date).GetDateTimeFormats()[12]
        $HostsFileResources = [System.Collections.ArrayList]::new()
        $FileUrls = [System.Collections.ArrayList]::new()
        if($Test){
            $FileUrls.Add('https://raw.githubusercontent.com/arsscriptum/PowerShell.Module.WindowsHost/master/tests/test_01.txt')
            #$FileUrls.Add('https://raw.githubusercontent.com/arsscriptum/PowerShell.Module.WindowsHost/master/tests/test_02.txt')
        }else{
            $FileUrls.Add('https://someonewhocares.org/hosts/hosts')
            $FileUrls.Add('https://ewpratten.retrylife.ca/youtube_ad_blocklist/hosts.ipv4.txt')
            $FileUrls.Add('https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt')
            $FileUrls.Add('https://raw.githubusercontent.com/anudeepND/blacklist/master/facebook.txt')
            $FileUrls.Add('https://raw.githubusercontent.com/arsscriptum/PowerShell.Module.WindowsHost/master/blacklist/blacklisted_adservers.txt')
        }

        $InitDateStr = (Get-Date).GetDateTimeFormats()[12]
        $HostsFileResources = [System.Collections.ArrayList]::new()
        ForEach($u in $FileUrls){
            [Uri]$MyUri =  $u
            $name = $MyUri.Host
            $i = $u.LastIndexOf('/')+1
            $name += '_'
            $name += $u.Substring($i)
            $res = [PSCustomObject]@{
                Name        = "$name"
                Url         = "$u"
                LastUpdate  = 'never'
                Hash        = '0'
                AddedOn     = "$InitDateStr"
            };            
            $HostsFileResources.Add($res) | Out-Null
            Write-output "Added $name ($u)"
        }

        $JsonResources = $HostsFileResources | ConvertTo-Json
        Set-Content -Path $Path -Value $JsonResources
        Write-output "Saved $Path"
        $Txt = "You can now use this file to initialise the module with starting values"

        Write-Host "`n`nDone! " -f DarkGreen -n ; Write-Host "$Txt" -f DarkCyan
        Write-Host ">> `$JsonFile=`"$Path`"" -f DarkGray
        Write-Host ">> Initialize-WinHostModule `$JsonFile`n`n"  -f DarkGray

    }catch{
        Write-Host "ERROR " -f DarkRed -n ; Write-Host "$_" -f DarkYellow
    }


# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUcjUzkTIZFW+EUolLuOJ5FHYE
# 0++gggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUktld+q7P4+PhrTa1Ll8Z
# Edv43HUwDQYJKoZIhvcNAQEBBQAEggEAzADefZQiJ7nHwjRy+Mi9lPgtIFevy9nA
# ITnOSj2vJPXcl3W6X8yzFSFn2ch+kJjdhrJI3vP3AD9KJQxKJApc8gunzBJ8jCgL
# mjZUHKLevAoJFJJFLMFgx9vxH4eXemEJERP31rIt3AEIu2MqOEicQr67Z8cTQiCC
# MKbKOuKVybRPdhb601lMLSPbe06BNWJLK0BeXeXpRfMqZAYchu5LTM8vThu7D8v4
# F5t25v3wKSDLNIsvFOXkRGYBALyJM1HbdOCHZ17NJ+BuESIJrOJ9m9xIBkHqnKV4
# vv/eRqVx7tK5q8KhiyQiUBvLBrWt/xQNVupZLVw2X8WoQV+wi/BdRg==
# SIG # End signature block
