#This script configures winrm to only listen on HTTPS and enables a self-signed certificate to be used with the SSL transport.

$hostname = $env:COMPUTERNAME
$serverCert = New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName $hostname
Export-Certificate -Cert $serverCert -FilePath "C:\PsRemoting-Cert.cer"
Enable-PSRemoting -Force
Get-ChildItem wsman:\localhost\listener | Where-Object -Property Keys -eq 'Transport=HTTP' | Remove-Item -Force
New-Item -Path WSMan:\localhost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $serverCert.Thumbprint -Force
New-NetFirewallRule -DisplayName "WinRM - Powershell Remote SSL-in" -Name "WinRM - Powershell remote SSLin" -Profile Any -LocalPort 5986 -Protocol TCP
Restart-Service WinRM

Write-host "Remember to add hostname: " $hostname "to hosts file if outside of domain"