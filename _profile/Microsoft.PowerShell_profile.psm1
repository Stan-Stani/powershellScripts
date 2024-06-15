# Setup python encoding so ps doesn't complain
$env:PYTHONIOENCODING = "utf-8"

# Setup git error debug logging
$env:GIT_TRACE2_EVENT = "C:\Users\StanStanislaus\Documents\Stan\git_trace2_event.log"

# Runs the --alias command for thefuck, setting up thefuck properly for ps
Invoke-Expression "$(thefuck --alias)"
Import-Module posh-git
Import-Module z

$PROFILE_MODULE = $PSScriptRoot


# Makes a list of systemfunctions before profile loads, and thus before my custom functions load.
# Built off of https://stackoverflow.com/a/15694429/1465015 @mjolinor's answer.
$sysfunctions = gci function:
$sysaliases = gci alias:
function Get-MyFunctions {
    $userAliases = gci alias: | where { $sysaliases -notcontains $_ }
    $userFunctions = gci function: | where { $sysfunctions -notcontains $_ }

    $output = foreach ($function in $userFunctions) {
        $alias = $userAliases | where { $_.Definition -eq $function.Name }
        $functionInfo = $function | Select-Object Name,
        @{Name = 'Alias'; Expression = { if ($alias) { $alias.Name } else { "-" } } }
        $functionInfo
    }

    $output | Format-Table -AutoSize
}
New-Alias -Name mf -Value Get-MyFunctions


# g => git
function Invoke-Git { & git $args; Write-Host Ran $MyInvocation.MyCommand from `$profile }
New-Alias -Name g -Value Invoke-Git

# list useful git commands
function Get-UsefulGitCommands { 
    $gitCommands = @(
        [PSCustomObject]@{
            Command = 'stash show [index]'
            Description = 'Show changes recorded in the stash as a diff'
        },
        [PSCustomObject]@{
            Command = 'log main..'
            Description = 'Show commits on this branch not yet merged into the main branch'
        },
        [PSCustomObject]@{
            Command = 'gui'
            Description = 'Launch the Git GUI'
        },
        [PSCustomObject]@{
            Command     = 'diff --stat main'
            Description = 'Show change summary between main and current branch, kind of like `git status` but for comparing branches'
        }
    )

    foreach ($cmd in $gitCommands) {
        Write-Host "$($cmd.Command): $($cmd.Description)"
    }

    return $gitCommands
}
New-Alias -Name ggc -Value Get-UsefulGitCommands


# d => git diff
function Invoke-GitDiff { & git diff $args; Write-Host Ran $MyInvocation.MyCommand from `$profile }
New-Alias -Name d -Value Invoke-GitDiff

# s => git status
function Invoke-GitStatus { & git status; Write-Host Ran $MyInvocation.MyCommand from `$profile }
New-Alias -Name s -Value Invoke-GitStatus

# c => git checkout
function Invoke-GitCheckout {
    & git checkout $args;
    Write-Host Ran $MyInvocation.MyCommand from `$profile
    # $currentLocation = Get-Location
    # if ($currentLocation.Path -like "*\testing*" -or $currentLocation.Path -like "*\frontends*") {
    #     & "C:\Users\StanStanislaus\Documents\Stan\Utils\apply my frontends configs.lnk"
    # }
}
New-Alias -Name c -Value Invoke-GitCheckout

# a => git checkout; git stash apply
function Invoke-GitCheckoutStashApply {
    & git checkout $args
    git stash apply
    Write-Host Ran $MyInvocation.MyCommand from `$profile
    # $currentLocation = Get-Location
    # if ($currentLocation.Path -like "*\testing*" -or $currentLocation.Path -like "*\frontends*") {
    #     & "C:\Users\StanStanislaus\Documents\Stan\Utils\apply my frontends configs.lnk"
    # }
}
New-Alias -Name a -Value Invoke-GitCheckoutStashApply

# p => git pull
function Invoke-GitPull {
    & git pull $args
    Write-Host Ran $MyInvocation.MyCommand from `$profile
}
New-Alias -Name p -Value Invoke-GitPull

# pp => git checkout $args; git pull
function Invoke-GitCheckoutPull {
    & git checkout $args
    & git pull
    Write-Host Ran $MyInvocation.MyCommand from `$profile
}
New-Alias -Name pp -Value Invoke-GitCheckoutPull


# m => git stash; git checkout main; git pull
function Invoke-GitStashPullMain {
    $ErrorActionPreference = "Stop"
    & git stash
    & git checkout main
    & git pull
    Write-Host Ran $MyInvocation.MyCommand from `$profile
}
New-Alias -Name m -Value Invoke-GitStashPullMain

function Set-ClickablePowerShellScript {
    # Find the first .ps1 script in the current directory
    $script = Get-ChildItem -Filter *.ps1 | Select-Object -First 1

    # Check if a .ps1 script was found
    if ($null -ne $script) {
        # Generate the command to execute the PowerShell script
        $command = "pwsh.exe -File `"$($script.FullName)`""

        # Output the command to a batch file
        $batPath = "$($script.BaseName).bat"
        Set-Content -Path $batPath -Value $command
        Write-Host "Batch file created."

        # Create a shortcut to the batch file
        $shell = New-Object -COMObject WScript.Shell
        $shortcut = $shell.CreateShortcut("$PWD\$($script.BaseName).lnk")
        $shortcut.TargetPath = "$PWD\$batPath"
        $shortcut.Save()
        Write-Host "Shortcut created."
    }
    else {
        Write-Host "No .ps1 scripts found in the current directory."
    }
}

function Invoke-LernaNoCache {
    # yarn lerna exec yarn rimraf ./node_modules/.cache 
    # yarn lerna run build --skip-nx-cache
    # $targetDir = "C:\Users\StanStanislaus\Documents\git-repos\steffes-packages"
    $targetDir = Get-Location
    Start-Process cmd -ArgumentList "/k cd $targetDir && yarn lerna run build && pause" -Verb runAs



}
New-Alias -Name l -Value Invoke-LernaNoCache

# src: https://ilovepowershell.com/uncategorized/powershell-profile-trick-random-background-color/
function Invoke-RandomUI {
    $random = New-Object System.Random
    switch ($random.Next(5)) {
        0 { $host.ui.RawUI.BackgroundColor = "DarkMagenta"; $host.ui.RawUI.ForegroundColor = "White" }
        1 { $host.ui.RawUI.BackgroundColor = "Black"; $host.ui.RawUI.ForegroundColor = "Green" }
        2 { $host.ui.RawUI.BackgroundColor = "Gray"; $host.ui.RawUI.ForegroundColor = "DarkBlue" }
        3 { $host.ui.RawUI.BackgroundColor = "DarkCyan"; $host.ui.RawUI.ForegroundColor = "DarkYellow" }
        4 { $host.ui.RawUI.BackgroundColor = "DarkGray"; $host.ui.RawUI.ForegroundColor = "DarkRed" }
    }
    cls
}
function Get-PullRequest {
    # https://matklad.github.io/2023/10/23/unified-vs-split-diff.html
    git fetch origin $args[0]
    git checkout FETCH_HEAD
    $base = git merge-base HEAD main
    git reset $base
}
New-Alias -Name gpr -Value Get-PullRequest

function Remove-NodeModulesAll {
    $input = Read-Host -Prompt "'y' to remove all node_modules in this and sub-dirs. 'Enter' to cancel..."
    if ($input -eq 'y') {
        Get-ChildItem -Path . -Recurse -Directory -Name -Filter 'node_modules' | ForEach-Object { Remove-Item -Path $_ -Recurse -Force }
    }
    $pr 
}

function Start-Webkit {
    cd C:\Users\StanStanislaus\Documents\Stan\Utils\webkit-browser
    node nocache.js
}

Import-Module "C:\Users\StanStanislaus\Documents\Stan\Utils\PowershellScripts\timelocker\timeLocker.psm1"
Import-Module "C:\Users\StanStanislaus\Documents\Stan\Utils\PowershellScripts\ngrokFreeApply\ngrokFreeApply.psm1"



Export-ModuleMember -Function * -Alias * -Variable PROFILE_MODULE