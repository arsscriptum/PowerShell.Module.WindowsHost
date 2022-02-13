Set-RegistryValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache' -Name 'Start' -Value '2'
ipconfig /flushdns

Restart-Service Dnscache