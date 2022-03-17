<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.WindowsHosts
  ║   𝑊𝑖𝑛𝑑𝑜𝑤𝑠 𝐻𝑂𝑆𝑇𝑆 𝑓𝑖𝑙𝑒 𝑚𝑎𝑛𝑎𝑔𝑒𝑚𝑒𝑛𝑡              
  ║   
  ║   modlog.ps1: logs
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>


 #Requires -Version 7.0


#===============================================================================
# ChannelProperties
#===============================================================================

class ChannelProperties
{
    #ChannelProperties
    [string]$Channel = 'WinHost'
    [ConsoleColor]$TitleColor = (Get-RandomColor)
    [ConsoleColor]$NormalTextColor = 'DarkGray'
    [ConsoleColor]$MessageColor = 'DarkCyan'
    [ConsoleColor]$InfoColor = 'DarkCyan'
    [ConsoleColor]$WarnColor = 'DarkYellow'
    [ConsoleColor]$ErrorColor = 'DarkRed'
    [ConsoleColor]$SuccessColor = 'DarkGreen'
    [ConsoleColor]$ErrorDescriptionColor = 'DarkYellow'
}
$Script:CPropsWinHost = [ChannelProperties]::new()


function Write-MMsg{               # NOEXPORT   
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [Parameter(Mandatory=$false,Position=1)]
        [Alias('h','y')]
        [switch]$Highlight
    )
    if($Highlight){
        Write-Host "⚡ $Message"
    }else{
        Write-Host "⚡ $Message" -f DarkGray
    }
}


function Write-MOk{                        # NOEXPORT        
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [Parameter(Mandatory=$false,Position=1)]
        [Alias('h','y')]
        [switch]$Highlight
    )
    
    if($Highlight){
        Write-Host "✅ $Message"
    }else{
        Write-Host "✅ $Message" -f DarkGray
    }
}


function Write-MWarn{                # NOEXPORT                 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [Parameter(Mandatory=$false,Position=1)]
        [Alias('h','y')]
        [switch]$Highlight
    )
    if($Highlight){
        Write-Host "⚠ $Message" -f DarkYellow
    }else{
        Write-Host "⚠ $Message" -f DarkGray
    }
}



function Write-MError{                # NOEXPORT                 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [Parameter(Mandatory=$false,Position=1)]
        [Alias('h','y')]
        [switch]$Highlight
    )
    if($Highlight){
        Write-Host "❗❗❗ $Message" -f DarkYellow
    }else{
        Write-Host "❗❗❗ $Message" -f DarkGray
    }
    
}


function Write-ProgressHelper {   ### NOEXPORT

    param (
    [Parameter(Mandatory=$True,Position=0)]
        [int]$StepNumber,
        [Parameter(Mandatory=$True,Position=1)]
        [string]$Message
    ) 
    try{
        Write-Progress -Activity $Script:ProgressTitle -Status $Message -PercentComplete (($StepNumber / $Script:Steps) * 100)
    }catch{
        Write-Host "⌛ StepNumber $StepNumber" -f DarkYellow
        Write-Host "⌛ ScriptSteps $Script:Steps" -f DarkYellow
        $val = (($StepNumber / $Script:Steps) * 100)
        Write-Host "⌛ PercentComplete $val" -f DarkYellow
        Show-ExceptionDetails $_ -ShowStack
    }
}




function Write-ChannelMessage{               # NOEXPORT   
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message        
    )

    Write-Host "[$($Script:CPropsWinHost.Channel)] " -f $($Script:CPropsWinHost.TitleColor) -NoNewLine
    Write-Host "$Message" -f $($Script:CPropsWinHost.MessageColor)
}


function Write-ChannelResult{                        # NOEXPORT        
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$Message,
        [switch]$Warning
    )

    if($Warning -eq $False){
        Write-Host "[$($Script:CPropsWinHost.Channel)] " -f $($Script:CPropsWinHost.TitleColor) -NoNewLine
        Write-Host "[ OK ] " -f $($Script:CPropsWinHost.SuccessColor) -NoNewLine
    }else{
        Write-Host "[WARN] " -f $($Script:CPropsWinHost.ErrorColor) -NoNewLine
    }
    
    Write-Host "$Message" -f $($Script:CPropsWinHost.MessageColor)
}



function Write-ChannelError{                # NOEXPORT                 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.ErrorRecord]$Record
    )
    $formatstring = "{0}`n{1}"
    $fields = $Record.FullyQualifiedErrorId,$Record.Exception.ToString()
    $ExceptMsg=($formatstring -f $fields)
    Write-Host "[$($Script:CPropsWinHost.Channel)] " -f $($Script:CPropsWinHost.TitleColor) -NoNewLine
    Write-Host "[ERROR] " -f $($Script:CPropsWinHost.ErrorColor) -NoNewLine
    Write-Host "$ExceptMsg`n`n" -ForegroundColor DarkYellow
}

        
# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnbpZlrRrYw6Lym31T4UNdTlD
# x8CgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUHo61bZhKM1Y0om3LoHVf
# rX/DVtwwDQYJKoZIhvcNAQEBBQAEggEAgl7jXsxKPc7aRyVnZcEqtItWmG7wAg5f
# PZ6C4UkTX8CPu78JvJn/45xttXi+ZR30NYpWXkWD28Ie/iPpVLbUZ0dvT37PewKj
# yFf+ttUDiFcGMbhgM5zuCpF1KSE8ReYJFvciNQ7mFcp76c9Q0TXy3a5RCC998GVA
# DuVY3pZvpE81JZlfgRv53x2GHMe4SOgPHFWJ0btHfp3G+vIh1sn279He8G/Vft6Y
# 53uuvbCtWt51ICL1CxuP8UQBrsOSvEXz7SKCNAtPBz82LumTiMxUXiObid0ZWkIl
# VFc8W6omZVsmhsudK6erDeXKtmpbkH4wWz7EWXzaMQ9DPLr0fKpfyQ==
# SIG # End signature block
