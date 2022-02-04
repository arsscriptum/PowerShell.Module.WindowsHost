<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.WindowsHosts
  ║   𝑊𝑖𝑛𝑑𝑜𝑤𝑠 𝐻𝑂𝑆𝑇𝑆 𝑓𝑖𝑙𝑒 𝑚𝑎𝑛𝑎𝑔𝑒𝑚𝑒𝑛𝑡              
  ║   
  ║   online_host_url.ps1: Predefined Online Resources for Hosts
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>

function Initialize-HostsOnlineResources{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $false)]
        [String]$Path
    )    
<#
    .Synopsis
       Setup the module. Needs to be run only once
#>

    try{
        If( $PSBoundParameters.ContainsKey('Path') -eq $False ){ 
            if(($ENV:PowerShellScriptsDev -eq $null) -Or ($ENV:PowerShellScriptsDev -eq '')){ $ENV:PowerShellScriptsDev = '$ENV:Temp\PowerShellDev' ; }
            $ModulePath = Join-Path $ENV:PowerShellScriptsDev 'PowerShell.Module.WindowsHosts'
            $ResPath = Join-Path $ModulePath 'res'
            $Path = Join-Path $ResPath 'online_resources.json'
            New-Item -Path $ResPath -ItemType Directory -ErrorAction Ignore -Force| Out-Null
            Write-Host "[init   path] " -f DarkRed -NoNewLine
            Write-Host " using $Path" -f DarkYellow  
        }

        $HostsFileResources = [System.Collections.ArrayList]::new()
        $hosts_source='https://someonewhocares.org/hosts/hosts'
        $adservers_hosts='https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt'
        $facebook_hosts='https://raw.githubusercontent.com/anudeepND/blacklist/master/facebook.txt'
        $arsscriptum_hosts='https://raw.githubusercontent.com/arsscriptum/PowerShell.Module.WindowsHost/master/blacklist/blacklisted_adservers.txt'
        $res = [PSCustomObject]@{
                        Name        = 'someonewhocares'
                        Url         = $hosts_source
                        LastUpdate  = 'Feb 4, 2022 12:22:38 PM'
                        Hash        = '132'
                    };
        $HostsFileResources.Add($res) | Out-Null
        $DbgStr = $res | ConvertTo-Json
        Write-Host "[adding  url] " -f DarkRed -n ; Write-Host "$hosts_source" -f DarkGray -n ; Write-Host "--> ok " -f DarkGreen
        $res = [PSCustomObject]@{
                        Name        = 'adservers_hosts'
                        Url         = $adservers_hosts
                        LastUpdate  = 'Feb 4, 2022 12:22:38 PM'
                        Hash        = '132'
                    }
        $HostsFileResources.Add($res) | Out-Null
        $DbgStr = $res | ConvertTo-Json
        Write-Host "[adding  url] " -f DarkRed -n ; Write-Host "$adservers_hosts" -f DarkGray -n ; Write-Host "--> ok " -f DarkGreen
        $res = [PSCustomObject]@{
                        Name        = 'facebook_hosts'
                        Url         = $facebook_hosts
                        LastUpdate  = 'Feb 4, 2022 12:22:38 PM'
                        Hash        = '132'
                    }
        $HostsFileResources.Add($res) | Out-Null
        $DbgStr = $res | ConvertTo-Json
        Write-Host "[adding  url] " -f DarkRed -n ; Write-Host "$facebook_hosts" -f DarkGray -n ; Write-Host "--> ok " -f DarkGreen

        $res = [PSCustomObject]@{
                        Name        = 'arsscriptum_hosts'
                        Url         = $arsscriptum_hosts
                        LastUpdate  = 'Feb 4, 2022 12:22:38 PM'
                        Hash        = '132'
                    }
        $HostsFileResources.Add($res) | Out-Null
        $DbgStr = $res | ConvertTo-Json
        Write-Host "[adding  url] "  -f DarkRed -n ; Write-Host "$arsscriptum_hosts" -f DarkGray -n ; Write-Host "--> ok " -f DarkGreen

        $JsonResources = $HostsFileResources | ConvertTo-Json
        Set-Content -Path $Path -Value $JsonResources
        Write-Host "[saving json] " -f DarkRed -n ; Write-Host "$Path" -f DarkYellow
        $Txt = "You can now use this file to initialise the module with starting values"

        Write-Host "`n`nDone! " -f DarkGreen -n ; Write-Host "$Txt" -f DarkCyan
        Write-Host ">> `$JsonFile=`"$Path`"" -f DarkGray
        Write-Host ">> Initialize-WinHostModule `$JsonFile`n`n"  -f DarkGray

    }catch{
        Write-Host "ERROR " -f DarkRed -n ; Write-Host "$_" -f DarkYellow
    }
}
