$listenAddress = "127.0.0.1"
$connectAddress = $listenAddress



function New-LocalhostPortForward {
    param (
        [Parameter(Position = 0)]
        [int] $listenPort,
        [Parameter(Position = 1)]
        [int] $connectPort
    )

    netsh interface portproxy add v4tov4 listenport=$listenPort listenAddress=$listenAddress connectPort=$connectPort connectAddress=$connectAddress
  
}

function Remove-LocalhostPortForward {
    param (
        [Parameter(Position = 0)]
        [int] $listenPort
    )
    
    netsh interface portproxy delete v4tov4 listenport=$listenPort listenaddress=$listenAddress
}

function Remove-LocalhostPortForwardAll {
    if (Get-IsElevated) {
        netsh interface portproxy reset
    }
    else {
        Write-Host "Running as Admin..."
        $commandToRun = "Import-Module $PSCommandPath; Remove-LocalHostPortForwardAll"
        Start-Process pwsh -Verb RunAs -ArgumentList "-NoExit", "-Command", "$commandToRun"
    }
}

function Get-IsElevated {

    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()

    $p = New-Object System.Security.Principal.WindowsPrincipal($id)

    if ($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))

    { Write-Output $true }      

    else

    { Write-Output $false }   

}


function New-NucleusLocalPortForward {

    
    if (Get-IsElevated) {   
        Write-Host "Forwarding Internal, External, and Auth Api Ports as deployed in Docker, to Windows Dev Ports..."

        $ModulePathForGetEnv = Join-Path -Path $PSScriptRoot -ChildPath /readEnv.psm1


        Write-Host "Reading Port settings from .env..."
        Import-Module $ModulePathForGetEnv
        Get-Env($PSScriptRoot)


        Write-Host "Setting up forwarding..."
        # Nucleus CoreAPI Auth
        New-LocalhostPortForward $Env:AuthFrom $Env:AuthTo
        # Nucleus CoreAPI (Internal)
        New-LocalhostPortForward $Env:InternalFrom $Env:InternalTo
        # Nucleus CoreAPI External
        New-LocalhostPortForward $Env:ExternalFrom $Env:ExternalTo

        Write-Host "Finished. Listing current settings..."

        netsh interface portproxy show all
        Pause
        Exit

    }
    else {
        Write-Host "Running as Admin..."
        $commandToRun = "Import-Module $PSCommandPath; New-NucleusLocalPortForward"
        Start-Process pwsh -Verb RunAs -ArgumentList "-NoExit", "-Command", "$commandToRun"
    }




}

