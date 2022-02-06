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
    [ConsoleColor]$TitleColor = 'Blue'
    [ConsoleColor]$NormalTextColor = 'DarkGray'
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

        