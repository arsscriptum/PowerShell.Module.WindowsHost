<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.WindowsHosts
  ║   𝑊𝑖𝑛𝑑𝑜𝑤𝑠 𝐻𝑂𝑆𝑇𝑆 𝑓𝑖𝑙𝑒 𝑚𝑎𝑛𝑎𝑔𝑒𝑚𝑒𝑛𝑡              
  ║   
  ║   localhost.ps1: Predefined local entries
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>



function Get-LocalHostEntries {  ### NOEXPORT
    [CmdletBinding(SupportsShouldProcess)]
    Param()  

    $localhost = @'

# <localhost>

127.0.0.1       localhost
127.0.0.1       localhost.localdomain
255.255.255.255 broadcasthost
::1             localhost
127.0.0.1       local
::1             ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
ff02::3         ip6-allhosts
127.0.0.1       localhost
#__NEW_ENTRY_ADDRESS__       __NEW_ENTRY_HOSTNAME__

# </localhost>

'@

    return $localhost
}