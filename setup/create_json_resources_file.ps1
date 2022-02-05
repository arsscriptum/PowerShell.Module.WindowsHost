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
        [String]$Path
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
            New-Item -Path $ResPath -ItemType Directory -ErrorAction Ignore -Force| Out-Null
            Write-output "Generating $Path"
        }
        $InitDateStr = (Get-Date).GetDateTimeFormats()[12]
        $HostsFileResources = [System.Collections.ArrayList]::new()
        $hosts_source='https://someonewhocares.org/hosts/hosts'
        $adservers_hosts='https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt'
        $facebook_hosts='https://raw.githubusercontent.com/anudeepND/blacklist/master/facebook.txt'
        $arsscriptum_hosts='https://raw.githubusercontent.com/arsscriptum/PowerShell.Module.WindowsHost/master/blacklist/blacklisted_adservers.txt'
        $res = [PSCustomObject]@{
                        Name        = 'someonewhocares'
                        Url         = $hosts_source
                        LastUpdate  = 'never'
                        Hash        = '0'
                        AddedOn     = "$InitDateStr"
                    };
        $HostsFileResources.Add($res) | Out-Null
        $DbgStr = $res | ConvertTo-Json
        Write-output "adding $hosts_source"
        $res = [PSCustomObject]@{
                        Name        = 'adservers_hosts'
                        Url         = $adservers_hosts
                        LastUpdate  = 'never'
                        Hash        = '0'
                        AddedOn     = "$InitDateStr"
                    }
        $HostsFileResources.Add($res) | Out-Null
        $DbgStr = $res | ConvertTo-Json
        Write-output "adding $adservers_hosts"
        $res = [PSCustomObject]@{
                        Name        = 'facebook_hosts'
                        Url         = $facebook_hosts
                        LastUpdate  = 'never'
                        Hash        = '0'
                        AddedOn     = "$InitDateStr"
                    }
        $HostsFileResources.Add($res) | Out-Null
        $DbgStr = $res | ConvertTo-Json
        Write-output "adding $facebook_hosts"

        $res = [PSCustomObject]@{
                        Name        = 'arsscriptum_hosts'
                        Url         = $arsscriptum_hosts
                        LastUpdate  = 'never'
                        Hash        = '0'
                        AddedOn     = "$InitDateStr"
                    }
        $HostsFileResources.Add($res) | Out-Null
        $DbgStr = $res | ConvertTo-Json
        Write-output "adding $arsscriptum_hosts"

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

