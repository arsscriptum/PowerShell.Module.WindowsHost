# 𝑊𝑖𝑛𝑑𝑜𝑤𝑠 𝐻𝑂𝑆𝑇𝑆 𝑓𝑖𝑙𝑒 𝑚𝑎𝑛𝑎𝑔𝑒𝑚𝑒𝑛𝑡, 𝑓𝑢𝑠𝑖𝑜𝑛 𝑓𝑟𝑜𝑚 𝑙𝑎𝑡𝑒𝑠𝑡 𝑜𝑛𝑙𝑖𝑛𝑒 𝑟𝑒𝑠𝑜𝑢𝑟𝑐𝑒𝑠
Downloads different trusted HOSTS file resources **merge them** and create a local host file

# Usage

### [PowerShell v7](https://www.microsoft.com/en-us/download/details.aspx?id=50395) and Later

* **[Recommended]** Dumps directly in temp file
    ```PowerShell
    .\GenerateHost.ps1 -OverrideIPAddress "0.0.0.0" -WriteHostFile -HostFilePath "c:\Temp\Test.txt"
    ```
* **[Requires Elevation]** Dumps directly in system HOSTS file
    ```PowerShell
    .\GenerateHost.ps1 -OverrideIPAddress "0.0.0.0" -WriteHostFile -HostFilePath "c:\Temp\Test.txt"
    ```

### PowerShell v6 and Earlier
NOT SUPPORTED

