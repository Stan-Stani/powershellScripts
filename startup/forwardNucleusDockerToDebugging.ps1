Import-Module (Join-Path $PSScriptRoot "../myTools/localPortRedirecter.psm1")

New-NucleusLocalPortForward $false

Start-Sleep 5
exit