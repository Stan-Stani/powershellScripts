function Invoke-GitExtensionCheckoutHistory {
    git reflog | Select-String 'checkout' | ForEach-Object { $_ -replace '^.*to ', '' } | Out-Host -Paging
}
New-Alias -Name gch -Value Invoke-GitExtensionCheckoutHistory