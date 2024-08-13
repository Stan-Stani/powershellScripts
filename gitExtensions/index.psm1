function Invoke-GitExtensionCheckoutHistory {
    $history = git reflog | Select-String 'checkout' | ForEach-Object { $_ -replace '^.*to ', '' }
    
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
        $chocoProcess = Start-Process 'pwsh' -Verb RunAs -ArgumentList "-Command choco install less" -PassThru
        Read-Host -Prompt "Installing ``less``. Press enter to refresh environment variables after choco finishes the install."
        refreshenv
    }
    else {
        $history | more
    }
}
New-Alias -Name gch -Value Invoke-GitExtensionCheckoutHistory