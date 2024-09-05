# Run this script when using powershellScripts for the first time on a computer.

PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force

Install-Module -Name z -RequiredVersion 1.1.13 -Scope CurrentUser -Force

# https://github.com/MScholtes/PSVirtualDesktop
Install-Module VirtualDesktop -Force

# # POSSIBLY Needs to be run as Admin I guess?
# Start-Process powershell -Verb runAs "pip install thefuck; Write-Host 'Closing in 15 seconds...'; Start-Sleep 15"

# 7-13-2024 thefuck is brokenish https://github.com/nvbn/thefuck/issues/1453 until new release to support
# latest version of python it seems. 


