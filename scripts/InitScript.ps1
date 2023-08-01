$DesktopFilePath = "C:\Users\$ENV:USERNAME\Desktop\"

# Chocolatey installation
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install powershell-core -y
choco install python311 -y
choco install vscode -y
choco install wireshark -y
Set-Shortcut -ApplicationFilePath "C:\Program Files\Wireshark\Wireshark.exe"  -DestinationFilePath "${DesktopFilePath}Wireshark.lnk"
# $env:Path += ";C:\Program Files\Wireshark\"
choco install pstools -y

New-Item -ItemType Directory -Name Tools -Path "c:\"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/jimgodden/Azure-Virtual-WAN-Sandbox/main/scripts/installTools.ps1" -OutFile "c:\installTools.ps1"
Set-Shortcut -ApplicationFilePath "c:\installTools.ps1" -DestinationFilePath "${DesktopFilePath}installTools.lnk"

# Define variables for the IIS website and certificate
$siteName = "Default Web Site"
$port = 443
$certName = "MySelfSignedCert"

# Create a self-signed certificate
New-SelfSignedCertificate -DnsName "localhost" -CertStoreLocation "cert:\LocalMachine\My" `
-FriendlyName $certName

# Open TCP port 10001 on the firewall
New-NetFirewallRule -DisplayName "Allow inbound TCP port ${port}" -Direction Inbound -LocalPort $port -Protocol TCP -Action Allow

# Install the IIS server feature
Install-WindowsFeature -Name Web-Server -includeManagementTools

Import-Module WebAdministration

New-WebBinding -Name $siteName -Port $port -Protocol "https"

$SSLCert = Get-ChildItem -Path "cert:\LocalMachine\My" | Where-Object {$_.subject -like 'cn=localhost'}
Set-Location "IIS:\sslbindings"
New-Item "!${port}!" -value $SSLCert

function Set-Shortcut {
    param (
        [Parameter(Mandatory)]
        [string]$ApplicationFilePath,
        [Parameter(Mandatory)]
        [string]$DestinationFilePath
    )
    $WScriptObj = New-Object -ComObject ("WScript.Shell")
    $shortcut = $WscriptObj.CreateShortcut($DestinationFilePath)
    $shortcut.TargetPath = $ApplicationFilePath
    $shortcut.Save()
}