<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.WindowsHosts
  ║   𝑊𝑖𝑛𝑑𝑜𝑤𝑠 𝐻𝑂𝑆𝑇𝑆 𝑓𝑖𝑙𝑒 𝑚𝑎𝑛𝑎𝑔𝑒𝑚𝑒𝑛𝑡              
  ║   
  ║   online_host_url.ps1: Predefined Online Resources for Hosts
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>


 #Requires -Version 7.0


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


function Write-ProgressHelper {

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
function Global:Get-HostsValues{
  $Data=Get-Variable -Name HOSTSVALUES -Scope Global -ValueOnly -ErrorAction Ignore
  return $Data
}
