<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.WindowsHosts
  ║   𝑊𝑖𝑛𝑑𝑜𝑤𝑠 𝐻𝑂𝑆𝑇𝑆 𝑓𝑖𝑙𝑒 𝑚𝑎𝑛𝑎𝑔𝑒𝑚𝑒𝑛𝑡              
  ║   
  ║   helpers.ps1: Predefined Online Resources for Hosts
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>


 #Requires -Version 7.0


function Get-OnlineFile{   ### NOEXPORT
     param (
     [Parameter(Mandatory=$True,Position=0)]
        [string]$Url,
        [Parameter(Mandatory=$True,Position=1)]
        [string]$Path
    ) 
  try{

    $Script:ProgressTitle = 'STATE: DOWNLOAD'
    #Write-Host "Downloading " -f Gray -NoNewLine
    # Write-Host "$Url" -f Cyan
    $uri = New-Object "System.Uri" "$Url"
    $request = [System.Net.HttpWebRequest]::Create($Url)
    $request.set_Timeout(15000) #15 second timeout
    $response = $request.GetResponse()
    $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
    $totalLengthBytes = [System.Math]::Floor($response.get_ContentLength())
    $responseStream = $response.GetResponseStream()
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $Path, Create
    $buffer = new-object byte[] 10KB
    $count = $responseStream.Read($buffer,0,$buffer.length)
    $dlkb = 0
    $downloadedBytes = $count
    $script:steps = $totalLength
    while ($count -gt 0){
       $targetStream.Write($buffer, 0, $count)
       $count = $responseStream.Read($buffer,0,$buffer.length)
       $downloadedBytes = $downloadedBytes + $count
       $dlkb = $([System.Math]::Floor($downloadedBytes/1024))
       $msg = "Downloaded $dlkb Kb of $totalLength Kb"
       $perc = (($downloadedBytes / $totalLengthBytes)*100)
       if(($perc -gt 0)-And($perc -lt 100)){
         Write-Progress -Activity $Script:ProgressTitle -Status $msg -PercentComplete $perc 
       }
       
    }

    $targetStream.Flush()
    $targetStream.Close()
    $targetStream.Dispose()
    $responseStream.Dispose()
  }catch{
    Show-ExceptionDetails $_ -ShowStack
    return $false
  }finally{
    Write-Progress -Activity $Script:ProgressTitle -Completed
    
    Write-verbose "Downloaded $Url"
  }
  return $true
}

    
function Invoke-WriteHostFileFromMemory {  
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$Path
    ) 
    $lcl = Get-LocalHostEntries
    $cet = Get-CustomEntries
    $ack = Get-Acknowledgements
    $AllEntries = Get-HostsValuesInMemory
    Set-Content -Path $Path -Value $lcl -ErrorAction Stop
    Write-MMsg "Writing Local Host Entries..."
    Add-Content -Path $Path -Value $cet -ErrorAction Stop
    Write-MMsg "Custom Entries..."
    Add-Content -Path $Path -Value $AllEntries -ErrorAction Stop
    Write-MMsg "Online Entries..."
    Add-Content -Path $Path -Value $ack -ErrorAction Stop
    Write-MMsg "Acknowledgements..."
    Write-MOk "Done"
}

function New-HostFile {  ### NOEXPORT
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$True,Position=0)]
        [string]$Path
    )  
  try{    
    $HostValues = Get-Variable -Name RAW_HOST_VALUES -Scope Global -ValueOnly
    $HostValues = $HostValues |Sort-Object -Property Domain,Hostname -Descending
   
    $hostsLen = $HostValues.Count
    $Script:Steps= $HostValues.Count
    $stepCounter=0

    $Script:ProgressTitle = "Preparing $hostsLen entries."
   
    
    Write-MMsg "Preparing $hostsLen entries." -h
    $AllEntries = [System.Collections.ArrayList]::new()
    $LastDomain = ''
    $Total = 0
    $CountUi = 0
    ForEach($val in $HostValues){
      $Total++
      $CountUi++
      if($CountUi -gt 10000){$CountUi = 0;Write-MMsg "So far 10K entries for $Total total!";}
        $IP = $val.IP
        $Hostname = $val.Hostname
        $HostnameLen = $Hostname.Length
        $Diff = 50 - $HostnameLen
        if($HostnameLen -lt 50){
            for($i = 0 ; $i -lt $Diff ; $i++){
                $Hostname += ' '
            }
        } 
        $Comment = $val.Comment
        $TopLevelDomain = $val.TopLevelDomain
        $Domain = $val.Domain
        $SubDomain = $val.SubDomain
        $CommentLen = $Comment.Length
        if($CommentLen -eq 0){
            $Comment = 'Domain ' + $Domain 
        }
        if($Domain -eq ''){
          $formatstring = "{0}`t`t{1}"
          $fields = $ip,$hostname  
          $entry=($formatstring -f $fields)
          $null=$AllEntries.Add($entry)
        }else{
            if($Domain -ne $LastDomain){
                $LastDomain=$Domain
                $formatstring = "{0}`t`t{1}`t# {2}"
                $fields = $ip,$hostname, $comment  
                $entry=($formatstring -f $fields)
                $null=$AllEntries.Add($entry)
            }else{
                $formatstring = "{0}`t`t{1}`t# +"
                $fields = $ip,$hostname
                $entry=($formatstring -f $fields)
                $null=$AllEntries.Add($entry)
            }
        }
  
        Write-ProgressHelper -Message "preparing entries... ($stepCounter / $Script:Steps)" -StepNumber ($stepCounter++)
    }

    Set-Variable -Name PROCESSED_HOST_VALUES -Scope Global -Option allscope -Value $AllEntries
    
    Write-MMsg "Updated Global Variable PROCESSED_HOST_VALUES. Use 'Get-HostsValuesInMemory' to retrieve them in memory" -h  
 
    Write-Progress -Activity $Script:ProgressTitle -Completed
    
    $null = Remove-Item -Path $Path -Force  -ErrorAction Ignore
    
    $null = New-Item -Path $Path -ItemType File -Force
    Write-MOk "Writing to $Path" -h

    $lcl = Get-LocalHostEntries
    $cet = Get-CustomEntries
    $ack = Get-Acknowledgements
    Set-Content -Path $Path -Value $lcl -ErrorAction Stop
    Write-MMsg "Writing Local Host Entries..."
    Add-Content -Path $Path -Value $cet -ErrorAction Stop
    Write-MMsg "Custom Entries..."
    Add-Content -Path $Path -Value $AllEntries -ErrorAction Stop
    Write-MMsg "Online Entries..."
    Add-Content -Path $Path -Value $ack -ErrorAction Stop
    Write-MMsg "Acknowledgements..."
    Write-MOk "Done"
  }catch{
    Show-ExceptionDetails $_ -ShowStack
    return 
  }finally{
    Write-Progress -Activity $Script:ProgressTitle -Completed
  }
  return    
}

# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUPCKRrH6EGQyKrXO17WoeT25S
# Gm2gggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUDzwkETI0ZqovyYsn4Xmu
# GB4Tpn0wDQYJKoZIhvcNAQEBBQAEggEAxjqQLtHePHSyDT4C35cYC1z7tfUCIQql
# Neh25Qy1E63Msi7mgJ1UF7/JQzA6zjPmbvh/AuPxkXQKxPeKsDPBsKj+SZybe1kO
# 4Nqm6bpPPHnoFEhdzKxPALdtmwqLuDaG79Yws0HvxjygoPvCOhrFfXWUjdtIXlR5
# 1UyNyvy9ROul3EhVD+cE7Ln9VQJVs8O1AN3r5TL1tWaz0faJblDy9e9d7yo5gkam
# xf4oVlCBaOczbeMVDvprwKuJGqwa7ngAr8WQchwA2rJ8vZpyDSu3tXOe6mucUFQ4
# WPi0MczZy5BFDeiHK5Bi8aLTyXLa4tovcU8y/YY50cVSVqToLu8cHA==
# SIG # End signature block
