# PowerShell.Module.WindowsHost

PowerShell Module providing easy management of the Windows Hosts file.

[VIEW DEMO](https://github.com/arsscriptum/PowerShell.Module.WindowsHost/blob/master/doc/update.gif)

<!-- TABLE OF CONTENTS -->
## Table of Contents <!-- omit in toc -->

* [About The Project](#about-the-project)
  * [Built With](#built-with)
* [Getting Started](#getting-started)
* [Usage](#usage)
* [Acknowledgements](#acknowledgements)

<!-- ABOUT THE PROJECT -->
## About The Project

[![Product Screenshot][product-screenshot]](https://github.com/arsscriptum/PowerShell.Module.WindowsHost/doc/screenshot.png)

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

### Write Hosts File [VIEW DEMO](https://github.com/arsscriptum/PowerShell.Module.WindowsHost/blob/master/doc/Gen.gif)
```
    Update-HostsValues -Path ./new-host.txt -OverrideIPAddress "0.0.0.0"
```




<!-- ACKNOWLEDGEMENTS -->

## Acknowledgements

* [Dan Pollock. He has a very good black list](http://someonewhocares.org/hosts/)
* [Ultimate Hosts Blacklist](https://github.com/Ultimate-Hosts-Blacklist)
* [https://hosts.ubuntu101.co.za](https://hosts.ubuntu101.co.za)
* [More Acknowledgements](https://github.com/arsscriptum/PowerShell.Module.WindowsHost/doc/acknowledgements.md)



Repository
----------
https://github.com/arsscriptum/PowerShell.Module.WindowsHost/

