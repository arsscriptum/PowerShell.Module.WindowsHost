Set-RegistryValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache' -Name 'Start' -Value '4' -Type DWORD
ipconfig /flushdns

Restart-Service Dnscache
