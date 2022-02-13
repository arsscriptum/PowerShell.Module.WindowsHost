<#
  ╓──────────────────────────────────────────────────────────────────────────────────────
  ║   PowerShell.Module.WindowsHosts
  ║   𝑊𝑖𝑛𝑑𝑜𝑤𝑠 𝐻𝑂𝑆𝑇𝑆 𝑓𝑖𝑙𝑒 𝑚𝑎𝑛𝑎𝑔𝑒𝑚𝑒𝑛𝑡              
  ║   
  ║   Acknowledgements.ps1: Predefined Acknowledgements entries
  ╙──────────────────────────────────────────────────────────────────────────────────────
 #>

function Get-Acknowledgements {  ### NOEXPORT
    [CmdletBinding(SupportsShouldProcess)]
    Param()  

    
    $acknowledgements = @'

# Acknowledgements
# I'd like to thank the following people for submitting sites, and
# helping promote the site.

# Dan Pollock. He has a very good black list located at
# http://someonewhocares.org/hosts/

# Ultimate Hosts Blacklist located at https://github.com/Ultimate-Hosts-Blacklist
# The Ultimate Hosts Blacklist. We clean our input sources with the powerful combination of @PyFunceble & GitHub Actions!
# https://hosts.ubuntu101.co.za
# hosts@ubuntu101.co.za

# Bill Allison, Harj Basi, Lance Russhing, Marshall Drew-Brook, 
#  Leigh Brasington, Scott Terbush, Cary Newfeldt, Kaye, Jeff
#  Scrivener, Mark Hudson, Matt Bells, T. Kim Nguyen, Lino Demasi,
#  Marcelo Volmaro, Troy Martin, Donald Kerns, B.Patten-Walsh,
#  bobeangi, Chris Maniscalco, George Gilbert, Kim Nilsson, zeromus,
#  Robert Petty, Rob Morrison, Clive Smith, Cecilia Varni, OleKing 
#  Cole, William Jones, Brian Small, Raj Tailor, Richard Heritage,
#  Alan Harrison, Ordorica, Crimson, Joseph Cianci, sirapacz, 
#  Dvixen, Matthew Craig, Tobias Hessem, Kevin F. Quinn, Thomas 
#  Corthals, Chris McBee, Jaime A. Guerra, Anders Josefson, 
#  Simon Manderson, Spectre Ghost, Darren Tay, Dallas Eschenauer, Cecilia
#  Varni, Adam P. Cole, George Lefkaditis, grzesiek, Adam Howard, Mike 
#  Bizon, Samuel P. Mallare, Leinweber, Walter Novak, Stephen Genus, 
#  Zube, Johny Provoost, Peter Grafton, Johann Burkard, Magus, Ron Karner,
#  Fredrik Dahlman, Michele Cybula, Bernard Conlu, Riku B, Twillers, 
#  Shaika-Dzari, Vartkes Goetcherian, Michael McCown, Garth, Richard Nairn,
#  Exzar Reed, Robert Gauthier, Floyd Wilder, Mark Drissel, Kenny Lyons,
#  Paul Dunne, Tirath Pannu, Mike Lambert, Dan Kolcun, Daniel Aleksandersen,
#  Chris Heegard, Miles Golding, Daniel Bisca, Frederic Begou, Charles 
#  Fordyce, Mark Lehrer, Sebastien Nadeau-Jean, Russell Gordon, Alexey 
#  Gopachenko, Stirling Pearson, Alan Segal, Bobin Joseph, Chris Wall, Sean
#  Flesch, Brent Getz, Jerry Cain, Brian Micek, Lee Hancock, Kay Thiele,
#  Kwan Ting Chan, Wladimir Labeikovsky, Lino Demasi, Bowie Bailey, Andreas 
#  Marschall, Michael Tompkins, Michael O'Donnell, José Lucas Teixeira
#  de Oliveira, M. Ömer Gölgeli, and Anthony Gelibert for helping to build 
#  the hosts file.
# Russell O'Connor for OS/2 information
# kwadronaut for Windows 7 and Vista information
# John Mueller and Lawrence H Smith for Mac Pre-OSX information
# Jesse Baird for the Cisco IOS script


'@

    return $acknowledgements
}
# SIG # Begin signature block
# MIIFxAYJKoZIhvcNAQcCoIIFtTCCBbECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUI7SPE1O5bBwNzgn7B6xcQv1m
# r3qgggNNMIIDSTCCAjWgAwIBAgIQmkSKRKW8Cb1IhBWj4NDm0TAJBgUrDgMCHQUA
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
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUp0xGRwlKH4ws1oqnrNq9
# yCi9FvEwDQYJKoZIhvcNAQEBBQAEggEAbGzQwZom1HHqLVlm8QS/bpcGSwzoMLjR
# pJH+R7wxnb9iFb509AgEzICVmiboF2BUmLxKsXYStrcwq8zYiQtZpjjrK7lCpIF1
# Tad1dAOihXM+l3I46fnWxNQraL8PNB/QJihkmTuUstd2b4eZt357ZXMhsHAGIW32
# U1/BdKd0rTgT8hQeq0bN1jtGV6z2B6Q31GuRvwClOtQ3PpB9vqa9LDu6cS0uFhR6
# 0C4Eyw86qfxNE+zq8sXk03EXXLtOxeNhcuaxevi4XSiWLI3eWn5MHfKVAjXjkRtg
# HEIUDr9lNkuFsoKLuJwoV5KrUppBrUQQNIxDWT6RTnecWptClAZLkA==
# SIG # End signature block
