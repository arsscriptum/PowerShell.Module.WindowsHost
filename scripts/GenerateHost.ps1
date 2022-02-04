<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║                                                                                      
  ║   GenerateHost.𝗽𝘀𝟭                                                                     
  ║   𝑊𝑖𝑛𝑑𝑜𝑤𝑠 𝐻𝑂𝑆𝑇𝑆 𝑓𝑖𝑙𝑒 𝑚𝑎𝑛𝑎𝑔𝑒𝑚𝑒𝑛𝑡, 𝑓𝑢𝑠𝑖𝑜𝑛 𝑓𝑟𝑜𝑚 𝑙𝑎𝑡𝑒𝑠𝑡 𝑜𝑛𝑙𝑖𝑛𝑒 𝑟𝑒𝑠𝑜𝑢𝑟𝑐𝑒𝑠                   
  ║                                                                                      
  ║   𝗖𝗼𝗽𝘆𝗿𝗶𝗴𝗵𝘁 (𝗰) 𝟮𝟬𝟮𝟬, Guillaume Plante <guillaumeplante.qc@gmail.com> 
  ║   𝗔𝗹𝗹 𝗿𝗶𝗴𝗵𝘁𝘀 𝗿𝗲𝘀𝗲𝗿𝘃𝗲𝗱.                                                                  
  ║                                                                                      
  ║   𝗩𝗲𝗿𝘀𝗶𝗼𝗻 𝟭.𝟬.𝟬                                                                       
  ║   𝗵𝘁𝘁𝗽𝘀://arsscriptum.𝗴𝗶𝘁𝗵𝘂𝗯.𝗶𝗼/𝗽𝗿𝗼𝗷𝗲𝗰𝘁𝘀/𝗵𝗼𝘀𝘁𝘀.𝗵𝘁𝗺𝗹                                  
  ║                                                                                      
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>


 #Requires -Version 7.0

[CmdletBinding(SupportsShouldProcess)]
  Param
  (
      [Parameter(Mandatory=$false)]
      [ValidateScript({$_ -match [IPAddress] $_ })]  
      [string]$OverrideIPAddress,
      [Parameter(Mandatory=$false)]
      [switch]$UseDatabase,
      [Parameter(Mandatory=$false)]
      [switch]$WriteHostFile,
      [Parameter(Mandatory=$false)]
      [string]$HostFilePath="C:\Temp\HOSTS.tmp"
  )

# ==================================
# Debug
# ==================================
$Script:OfflineTest=$False
$Script:OfflineFilePath="c:\Temp\test.txt"


function List-ScriptFunctions {
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true)]
        [String]$Path
    )
    $FuncList = [System.Collections.ArrayList]::new()
    ( Get-ChildItem -Path $Path -Filter '*.ps1' -Recurse | Select-String -Pattern "function" ) | %{ $FName=$_.Line ; $FLen=$FName.Length;$FName=$FName.Substring(9,$FLen-9) ; $FName = $Fname -replace "{" ; Write-Verbose "Found function $FName"; $null=$FuncList.Add($FName.trim()) ;}
    return $FuncList
}


function DependencyCheck{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.ArrayList]$FunctionList
    )
    Write-Host "Running Dependency Check on Imports" -f DarkRed
    $NumFuntions=0
    try{
        foreach($Cmdlet in $FunctionList){
            $adv = 30-$Cmdlet.Length
            $name = $Cmdlet
            for($i=0;$i -lt $adv;$i++){$name+=' ';}
            $cmd=get-command -Name $Cmdlet -ErrorAction SilentlyContinue
            if($cmd -ne $null){
                $NumFuntions=$NumFuntions+1
                Write-Host "[check] " -f DarkYellow -NoNewLine
                Write-Host "detected in scope: " -f DarkGray -n
                Write-Host "$name" -n
                Write-Host -ForegroundColor  Green "`t`t[OK] "
                
            }
        }
    }
    catch [Exception] {
        $ErrorsCount += 1
        Write-Host -ForegroundColor Red "[KO] " -NoNewline
        Write-Host "Failed to find Cmdlet $Cmdlet"
        Write-Host -ForegroundColor Red "[ERROR]" $_.Exception.Message.Trim()
    }
    return $NumFuntions
}


function Run-DependencyCheck{
    $FuncList=List-ScriptFunctions ".\inc"
    $FuncListLen=$FuncList.Length
    $DepCheckOk=DependencyCheck $FuncList  
}

$CurrentPath = (Get-Location).Path
$IncludePath = Join-Path $CurrentPath 'inc'

$Includes = gci -Path $IncludePath -Filter '*.ps1'
ForEach($inc in $Includes){
    $full = $inc.Fullname
    $name = $inc.Name
        Write-Host "[Dependencies] " -f Red -NoNewLine
        Write-Host "including $name" -f DarkYellow  
    . "$inc"
}

ForEach($url in $Global:HostsFileURLs){
        Write-Host "[onlineurl] " -f Red -NoNewLine
        Write-Host "will fetch $url" -f DarkYellow  
}

Run-DependencyCheck

#New-HostFile $HostFilePath
#return
try{
    $CurrentPath = (Get-Location).Path
    $NewHost = 'c:\Temp\NewHost.txt'
    $GlobalHostsValues = [System.Collections.ArrayList]::new()

    if(($Script:OverrideIPAddress -ne $null)-And($Script:OverrideIPAddress -ne '')){
        Write-Host "[NOTE]`t" -f Red -NoNewLine
        Write-Host "ALL ENTRIES WILL HAVE THE IP $OverrideIPAddress" -f DarkYellow  
    }else{
        Write-Host "[NOTE] On Windows there is a difference: packets sent to 127.0.0.1 will end up bombarding whatever 
          server you have running on your computer (and you may be running a server without knowing it), 
          whereas trying to send packets 0.0.0.0 will immediately return with error code 1214 (ERROR_INVALID_NETNAME)." -f Yellow -b DarkGray
        Write-Host 'Better to use -OverrideIPAddress "0.0.0.0"' -f DarkRed -b DarkGray 
    }
    $null = New-Item -Path $NewHost -ItemType File -Force
    ForEach($hostsfile in $Global:HostsFileURLs){
        $Data = Build-HostFileFromURL $hostsfile -NewHostFile $NewHost 
        $GlobalHostsValues += $Data
        $GlobalHostsValuesCount = $GlobalHostsValues.Count
        Set-Variable -Name HOSTSVALUES -Scope Global -Option allscope -Value $GlobalHostsValues
        Write-Host "[OK]`t" -f DarkGreen -NoNewLine
        Write-Host "Updated Global Variable. $GlobalHostsValuesCount entries." -f DarkGray  
    }


    $Script:ProgressTitle = 'STATE: SORTING'
    Write-ProgressHelper -Message "Sorting all entries..." -StepNumber ($stepCounter++)
    $GlobalHostsValues = ($GlobalHostsValues | Sort-Object -Property "SubDomain" -Descending -Unique)
    Write-Progress -Activity $Script:ProgressTitle -Completed
    Write-Host "[OK]`t" -f DarkGreen -NoNewLine
    Write-Host "Values are sorted, made unique." -f DarkGray

    Remove-Alias -Name 'hosts' -ErrorAction Ignore
    New-Alias -Name 'hosts' -Value Global:Get-HostsValues -Scope Global -ErrorAction Stop -DESCRIPTION 'Get the HOSTS values that have been downloaded and parsed'
    Write-Host "[OK]`t" -f DarkGreen -NoNewLine
    Write-Host "New Alias is recorded." -f DarkGray
    Write-Host 'Run "Get-HostsValues" (func) or "hosts" (alias) to get the hosts values' -f Cyan

    if($WriteHostFile){
        Write-Host "[OK]`t" -f DarkGreen -NoNewLine
        Write-Host "Starting to dump values to '$HostFilePath'" -f DarkGray
        New-HostFile $HostFilePath
    }

}catch{
    Write-Host "[ERROR]`t" -f DarkRed -NoNewLine
    Write-Host "$_" -f DarkYellow
}