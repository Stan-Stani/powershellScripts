function Invoke-GitExtensionCheckoutHistory {
    $history = git reflog | Select-String 'checkout' | ForEach-Object { 
        [PSCustomObject]@{
            Checkout = $_ -replace '^.*to ', ''
            Index    = $index++
        } 
    }
    
    $lessCommand = Get-Command less -ErrorAction SilentlyContinue
    $chocoCommand = Get-Command choco -ErrorAction SilentlyContinue

    $pager = if ($lessCommand) {
        $lessCommand.Name
    }
    elseif ($env:PAGER) {
        $env:PAGER
    }
    else {
        $null
    }



    if ($pager) {
        $history | Out-String | & $pager
    }
    elseif ($chocoCommand) {
        Start-Process 'pwsh' -Verb RunAs -ArgumentList "-Command choco install less" -PassThru
        Read-Host -Prompt "Installing ``less``. Press enter to refresh environment variables after choco finishes the install."
        refreshenv
    }
    else {
        $history | more
    }
}
New-Alias -Name gch -Value Invoke-GitExtensionCheckoutHistory

function Invoke-GitExtensionTUIDiff {
    $gitTUICommand = Get-Command git-tui -ErrorAction SilentlyContinue
    $chocoCommand = Get-Command choco -ErrorAction SilentlyContinue
    if ($gitTUICommand) {
        # `saps` aliases Start-Process
        # @todo figure out how to start maximized...
        saps pwsh "-NoExit -Command git-tui diff ${$args[0]}"
    }
    elseif ($chocoCommand) {
        Start-Process 'pwsh' -Verb RunAs -ArgumentList "-Command choco install gittui" -PassThru
        Read-Host -Prompt "Installing ``git-tui``. Press enter to refresh environment variables after choco finishes the install."
        refreshenv
        saps pwsh "-NoExit -Command git-tui diff ${$args[0]}"
    } else {
        Write-Host "Couldn't install git-tui because Chocolately isn't installed. Do that first!"
        Write-Host ""
        Write-Host "You'll just have to use good ol' ``git diff `"blah`"``"
    }
}
New-Alias -Name gtd -Value Invoke-GitExtensionTUIDiff