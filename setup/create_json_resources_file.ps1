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
            $FileUrls.Add('https://adaway.org/hosts.txt')
            $FileUrls.Add('https://gitlab.com/The_Quantum_Alpha/the-quantum-ad-list/-/raw/master/Individual%20lists/The_Quantum_Abuse-List.txt')
            $FileUrls.Add('https://gitlab.com/The_Quantum_Alpha/the-quantum-ad-list/-/raw/master/Individual%20lists/Extreme%20lists/The_Quantum_Extreme_Youtube_Ad-List.txt')
            $FileUrls.Add('https://gitlab.com/The_Quantum_Alpha/the-quantum-ad-list/-/raw/master/Individual%20lists/The_Quantum_Youtube-Ads-List.txt')
            $FileUrls.Add('https://gitlab.com/The_Quantum_Alpha/the-quantum-ad-list/-/raw/master/Individual%20lists/The_Quantum_Privacy-list.txt')
            $FileUrls.Add('https://gitlab.com/The_Quantum_Alpha/the-quantum-ad-list/-/raw/master/Individual%20lists/The_Quantum_Simply-ads-list.txt')
            $FileUrls.Add('https://someonewhocares.org/hosts/hosts')
            $FileUrls.Add('https://ewpratten.retrylife.ca/youtube_ad_blocklist/hosts.ipv4.txt')
            $FileUrls.Add('https://gist.githubusercontent.com/anilshanbhag/7576643/raw/1a2b22edbfb609366548982a3638ba155bd8c33e/hosts')
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

