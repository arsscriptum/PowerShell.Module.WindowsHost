<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.WindowsHosts
  ║   𝑊𝑖𝑛𝑑𝑜𝑤𝑠 𝐻𝑂𝑆𝑇𝑆 𝑓𝑖𝑙𝑒 𝑚𝑎𝑛𝑎𝑔𝑒𝑚𝑒𝑛𝑡              
  ║   
  ║   online_host_url.ps1: Predefined Online Resources for Hosts
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>


 #Requires -Version 7.0


$Global:HostsFileURLs = [System.Collections.ArrayList]::new()

$hosts_source='https://someonewhocares.org/hosts/hosts'
$adservers_hosts='https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt'
$facebook_hosts='https://raw.githubusercontent.com/anudeepND/blacklist/master/facebook.txt'

$Global:HostsFileURLs.Add($hosts_source) | Out-Null
$Global:HostsFileURLs.Add($adservers_hosts) | Out-Null
$Global:HostsFileURLs.Add($facebook_hosts) | Out-Null
