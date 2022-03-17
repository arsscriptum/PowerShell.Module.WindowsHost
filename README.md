# PowerShell.Module.WindowsHost

<p align="center">
  <img src="https://github.com/arsscriptum/PowerShell.Module.WindowsHost/raw/master/doc/ModTitle-WINHOST.png" width="550" alt="PowerShell Module">
</p>


PowerShell Module providing easy management of the Windows Hosts file.


<!-- TABLE OF CONTENTS -->
## Table of Contents <!-- omit in toc -->


* [About The Project](#about-the-project)
  * [Built With](#built-with)
* [Getting Started](#getting-started)
* [Usage](#usage)
* [Documentation](#doc)
* [Acknowledgements](#acknowledgements)


<!-- ABOUT THE PROJECT -->
## About The Project


Using the system's HOST file is an easy and effective way to 
- disable annoying ads
- protect you from many types of spyware
- reduces bandwidth use, blocks certain pop-up traps
- prevents user tracking by way of "web bugs" embedded in spam
- provides partial protection from certain web-based exploits
- blocks most advertising you would otherwise be subjected to on the internet

The host values are changing often and are provided by different reliable sources.

In order to facilitate the creation of an updated HOST file this module handles the following:
- Management (Adding, removing) of online HOST resources 
- Get HOST file information (Get-HostFileDirectory, Get-HostFilePath)
- Generation of HOST file
  - Downloading from web resource
  - Merge all downloaded entries
  - Remove duplicates, sort and add comments




### Built With [Arsscriptum PowerShell Module Builder](https://github.com/arsscriptum/PowerShell.Module.Builder)

<!-- GETTING STARTED -->
## Getting Started, compile

```pwsh
git clone https://github.com/arsscriptum/PowerShell.Module.Builder/PowerShell.Module.Builder.git
pushd PowerShell.Module.Builder
./Setup.ps1
popd
git clone https://github.com/arsscriptum/PowerShell.Module.WindowsHost/PowerShell.Module.WindowsHost.git
pushd PowerShell.Module.WindowsHost
makeall
popd
```

<!-- USAGE EXAMPLES -->
## Usage

### Initialize Module with list of online resources. [VIEW DEMO](https://github.com/arsscriptum/PowerShell.Module.WindowsHost/blob/master/doc/Init.gif)
```
     .\setup\create_json_resources_file.ps1
     $JsonFile="C:\DOCUMENTS\PowerShell\Module-Development\PowerShell.Module.WindowsHost\res\online_resources.json"
     Initialize-WinHostModule $JsonFile -Force    
```
### List Online Resources
```
     List-WinHostUrls
```

### Write Hosts File [VIEW DEMO](https://github.com/arsscriptum/PowerShell.Module.WindowsHost/blob/master/doc/gen1.gif)
```
    Update-HostsValues -Path ./new-host.txt -OverrideIPAddress "0.0.0.0"
```

<!-- doc -->
## Documentation

- [Check-WinHostModuleInitStatus](https://github.com/arsscriptum/PowerShell.Module.WindowsHost/blob/master/doc/Check-WinHostModuleInitStatus.md)
- [Get-HostFileDirectory](https://github.com/arsscriptum/PowerShell.Module.WindowsHost/blob/master/doc/Get-HostFileDirectory.md)
- [Get-HostFilePath](https://github.com/arsscriptum/PowerShell.Module.WindowsHost/blob/master/doc/Get-HostFilePath.md)
- [Get-HostsValuesInMemory](https://github.com/arsscriptum/PowerShell.Module.WindowsHost/blob/master/doc/Get-HostsValuesInMemory.md)
- [Get-RawHostsValuesInMemory](https://github.com/arsscriptum/PowerShell.Module.WindowsHost/blob/master/doc/Get-RawHostsValuesInMemory.md)
- [Initialize-WinHostModule](https://github.com/arsscriptum/PowerShell.Module.WindowsHost/blob/master/doc/Initialize-WinHostModule.md)
- [Invoke-WriteHostFileFromMemory](https://github.com/arsscriptum/PowerShell.Module.WindowsHost/blob/master/doc/Invoke-WriteHostFileFromMemory.md)
- [List-WinHostUrls](https://github.com/arsscriptum/PowerShell.Module.WindowsHost/blob/master/doc/List-WinHostUrls.md)
- [New-WinHostResource](https://github.com/arsscriptum/PowerShell.Module.WindowsHost/blob/master/doc/New-WinHostResource.md)
- [Remove-WinHostResource](https://github.com/arsscriptum/PowerShell.Module.WindowsHost/blob/master/doc/Remove-WinHostResource.md)
- [Update-HostsValues](https://github.com/arsscriptum/PowerShell.Module.WindowsHost/blob/master/doc/Update-HostsValues.md)


<!-- ACKNOWLEDGEMENTS -->

## Acknowledgements

* [Dan Pollock. He has a very good black list](http://someonewhocares.org/hosts/)
* [Ultimate Hosts Blacklist](https://github.com/Ultimate-Hosts-Blacklist)
* [https://hosts.ubuntu101.co.za](https://hosts.ubuntu101.co.za)
* [More Acknowledgements](https://github.com/arsscriptum/PowerShell.Module.WindowsHost/doc/acknowledgements.md)

<p align="center">
  <img src="https://github.com/arsscriptum/PowerShell.Module.WindowsHost/blob/master/doc/gen1.gif?raw=true" width="600" alt="PowerShell Module">
</p>


Repository
----------
https://github.com/arsscriptum/PowerShell.Module.WindowsHost/

