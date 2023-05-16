# ensures that Windows PowerShell is used
powershell.exe

# npcap for using Wireshark for taking packet captures
Invoke-WebRequest -Uri "https://npcap.com/dist/npcap-1.75.exe" -OutFile "c:\npcap-1.75.exe"
c:\npcap-1.75.exe

# Package required for installing Windows Terminal
Invoke-WebRequest -Uri "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -OutFile "c:\Microsoft.VCLibs.x64.14.00.Desktop.appx"
Add-AppxPackage "c:\Microsoft.VCLibs.x64.14.00.Desktop.appx"

Invoke-WebRequest -Uri "https://github.com/microsoft/terminal/releases/download/v1.16.10261.0/Microsoft.WindowsTerminal_Win10_1.16.10261.0_8wekyb3d8bbwe.msixbundle" -OutFile "c:\Microsoft.WindowsTerminal_Win10_1.16.10261.0_8wekyb3d8bbwe.msixbundle"
Add-AppxPackage "c:\Microsoft.WindowsTerminal_Win10_1.16.10261.0_8wekyb3d8bbwe.msixbundle"

# # Testing
# $shell = New-Object -ComObject Shell.Application
# $shortcut = $shell.CreateShortcut("$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\MyApp.lnk")
# $shortcut.TargetPath = "C:\Path\To\MyApp.exe"
# $shortcut.Save()

# Switches back to PowerShell Core
pwsh.exe