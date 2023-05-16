# Chocolatey installation
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install powershell-core -y
# Add the PowerShell Core executable path to the system PATH environment variable
$envPath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
$psCorePath = 'C:\Program Files\PowerShell\7'
if ($envPath -notlike "*$psCorePath*") {
    [Environment]::SetEnvironmentVariable('Path', "$envPath;$psCorePath", 'Machine')
}

choco install python311 -y
# Set the path to add
$newPath = "C:\Python311\python.exe"

# Set the scope of the environment variables to modify
$scope = "Machine" # or "User"

# Get the current path variable
$currentPath = [Environment]::GetEnvironmentVariable("Path", $scope)

# Check if the new path is already in the variable
if ($currentPath -notlike "*$newPath*") {
    # Append the new path to the current path variable
    $newPathString = "$currentPath;$newPath"
    [Environment]::SetEnvironmentVariable("Path", $newPathString, $scope)
    Write-Host "Path added successfully."
} else {
    Write-Host "Path already exists in environment variables."
}

choco install vscode -y
# Set the path to add
$newPath = "C:\Program Files\Microsoft VS Code\code.exe"

# Set the scope of the environment variables to modify
$scope = "Machine" # or "User"

# Get the current path variable
$currentPath = [Environment]::GetEnvironmentVariable("Path", $scope)

# Check if the new path is already in the variable
if ($currentPath -notlike "*$newPath*") {
    # Append the new path to the current path variable
    $newPathString = "$currentPath;$newPath"
    [Environment]::SetEnvironmentVariable("Path", $newPathString, $scope)
    Write-Host "Path added successfully."
} else {
    Write-Host "Path already exists in environment variables."
}


choco install wireshark -y
# Set the path to add
$newPath = "C:\Program Files\Wireshark\Wireshark.exe"

# Set the scope of the environment variables to modify
$scope = "Machine" # or "User"

# Get the current path variable
$currentPath = [Environment]::GetEnvironmentVariable("Path", $scope)

# Check if the new path is already in the variable
if ($currentPath -notlike "*$newPath*") {
    # Append the new path to the current path variable
    $newPathString = "$currentPath;$newPath"
    [Environment]::SetEnvironmentVariable("Path", $newPathString, $scope)
    Write-Host "Path added successfully."
} else {
    Write-Host "Path already exists in environment variables."
}

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/jimgodden/PrivateLinkSandbox/main/scripts/installTools.ps1" -OutFile "c:\installTools.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/jimgodden/PrivateLinkSandbox/main/scripts/sourceTestingScript.ps1" -OutFile "c:\sourceTestingScript.ps1"

# Define variables for the IIS website and certificate
$siteName = "Default Web Site"
$port = 10001
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