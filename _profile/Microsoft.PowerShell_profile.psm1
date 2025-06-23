# Setup python encoding so ps doesn't complain
$env:PYTHONIOENCODING = "utf-8"

# Otput git stuff with correct formatting, e.g. `git diff > mypatch.patch`
$env:LESSCHARSET = 'UTF-8'

# Setup git error debug logging
$env:GIT_TRACE2_EVENT = "C:\Users\StanStanislaus\Documents\Stan\git_trace2_event.log"

# hx uses esc differently and I keep accidentally clearing lines in vanilla pwsh
# ctrl + c will clear line effectively enough if I need it
Set-PSReadLineKeyHandler -Key Escape -ScriptBlock {}

try {
    # Runs the --alias command for thefuck, setting up thefuck properly for ps
    Invoke-Expression "$(thefuck --alias)" 
}
catch {
    Clear-Host
    Write-Host `n'Yeah, we know thefuck is broken for now.'`n
}
Import-Module posh-git
Import-Module z
$gitExtensionsModuleFolder = "$PSScriptRoot/../gitExtensions" 
foreach ($module in Get-Childitem $gitExtensionsModuleFolder -Name -Filter "*.psm1") {
    Import-Module "$gitExtensionsModuleFolder/$module"
}


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

    $output | Format-Table -AutoSize | Out-Host -Paging
}
New-Alias -Name mf -Value Get-MyFunctions


# g => git
function Invoke-Git { & git $args; Write-Host Ran $MyInvocation.MyCommand from `$profile }
New-Alias -Name g -Value Invoke-Git

# list useful git commands
function Get-UsefulGitCommands { 
    $gitCommands = @(
        [PSCustomObject]@{
            Command     = 'stash show [index]'
            Description = 'Show changes recorded in the stash as a diff'
        },
        [PSCustomObject]@{
            Command     = 'log main..'
            Description = 'Show commits on this branch not yet merged into the main branch'
        },
        [PSCustomObject]@{
            Command     = 'gui'
            Description = 'Launch the Git GUI'
        },
        [PSCustomObject]@{
            Command     = 'diff --stat main'
            Description = 'Show change summary between main and current branch, kind of like `git status` but for comparing branches'
        },
        [PSCustomObject]@{
            Command     = 'git stash list -i -p -G "searchString"'
            Description = 'Search stashes for a text match.'
        },
        [PSCustomObject]@{
            Command     = 'git diff [branchName] -- *'
            Description = 'Diff current branch and branchName. May need to checkout the target branch first.'
        },
        [PSCustomObject]@{
            Command     = 'git merge [branchName] --strategy-option theirs'
            Description = "Uses incoming branch's side automatically, if there are conflicts."
        },
        [PSCustomObject]@{
            Command     = 'git update-index --skip-worktree <file_name>'
            Description = "Use this to avoid commiting changes to a tracked file. (Don't use assume-unchanged instead.)"
        },
        [PSCustomObject]@{
            Command     = 'git-tui diff --no-index "[path1]" "[path2]"'
            Description = "Nice terminal diff of any two files not in index. Need to insall ``git-tui``."
        },
        [PSCustomObject]@{
            Command     = 'git add --update * OR g add -u *'
            Description = "Stage only modified files. Don't stage untracked files."
        },
        [PSCustomObject]@{
            Command     = 'git log -S "code" --author="name" --patch'
            Description = "Search for code committed by a specific user."
        },
         [PSCustomObject]@{
            Command     = 'git log --follow -- filename'
            Description = "Show commits that affected specific file"
        },
        [PSCustomObject]@{
            Command     = 'git rev-list --max-count 1 --first-parent --before="2025-02-01 13:37" main'
            Description = "Get first commit before date"
        }
    )

    return $gitCommands | less
}
New-Alias -Name ggc -Value Get-UsefulGitCommands


# d => git diff
function Invoke-GitDiff { & git diff $args; Write-Host Ran $MyInvocation.MyCommand from `$profile }
New-Alias -Name d -Value Invoke-GitDiff

# s => git status
function Invoke-GitStatus { & git status; Write-Host Ran $MyInvocation.MyCommand from `$profile }
New-Alias -Name s -Value Invoke-GitStatus

# c => git checkout; git pull;
function Invoke-GitCheckout {
    Write-Host "Running: 
    & git checkout $args;
    & git pull;"
    & git checkout $args;
    Start-Sleep -m 500
    & git pull;
    Write-Host Ran $MyInvocation.MyCommand from `$profile
    # $currentLocation = Get-Location
    # if ($currentLocation.Path -like "*\testing*" -or $currentLocation.Path -like "*\frontends*") {
    #     & "C:\Users\StanStanislaus\Documents\Stan\Utils\apply my frontends configs.lnk"
    # }
}
New-Alias -Name c -Value Invoke-GitCheckout

# q => git checkout (q meaning quick)
function Invoke-GitCheckoutNoPull {
    Write-Host "Running: 
    & git checkout $args;"

    & git checkout $args;

    Write-Host Ran $MyInvocation.MyCommand from `$profile
}
New-Alias -Name q -Value Invoke-GitCheckoutNoPull

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
    param(     
     [string]$PRBranch,
     [string]$BaseBranch="main"

 )
 
    $Env:HUSKY_SKIP_HOOKS=1
    # https://matklad.github.io/2023/10/23/unified-vs-split-diff.html
    git fetch origin $PRBranch
    git checkout FETCH_HEAD
    $base = git merge-base HEAD $BaseBranch
    git reset $base
    $Env:HUSKY_SKIP_HOOKS=0

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

function Start-SteffesWebsiteSecure {
    yarn dev -- -- --experimental-https --experimental-https-key C:/Users/StanStanislaus/web-certificates/localhost-key.pem --experimental-https-cert C:/Users/StanStanislaus/web-certificates/localhost.pem -H 0.0.0.0
}
New-Alias -Name h -Value Start-SteffesWebsiteSecure

Import-Module "$PSScriptRoot\..\timelocker\timeLocker.psm1"
Import-Module "$PSScriptRoot\..\adit\adit.psm1"
Import-Module "$PSScriptRoot\..\processTerminator\stopNodeJs.psm1"



Export-ModuleMember -Function * -Alias * -Variable PROFILE_MODULE   