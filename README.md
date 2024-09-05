# Overview

This project uses PowerShell Core (pwsh.exe, not powershell.exe).

# First time setup

Run the setup script when using powershellScripts for the first time on a computer.
`_profile\Setup.ps1`

## Setting up startup scripts

Create shortcuts from the files in the `startup` dir and put the shortcuts in your dir that corresponds to `shell:startup` when entered into the Run (accessed via `WindowsKey + R`).

### setupVirtualDesktops
1. Use Win 11's virtual desktop feature to create some virtual desktops.
1. Use [PowerToys](https://learn.microsoft.com/en-us/windows/powertoys/) to save each virtual desktop's layout to a corresponding workspace, being sure to generate desktop shortcuts for the workspaces. Both the VD and Workspace should have the same exact name. Make sure you add "- Primary" to the VD/Workspace you want to be on after you start up your computer.
1. Move the Workspace shortcuts into the `./startup/setupVirtualDesktops/shortcuts` folder.