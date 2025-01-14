# Config A: just localhost 
$listenAddress = "127.0.0.1"
$connectAddress = $listenAddress

# Config B: forward incoming connections to chosen localhost ports 
# $listenAddress = "0.0.0.0"
# $connectAddress = "127.0.0.1"



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
    param (
        [Parameter(Position = 0)]
        [boolean] $YesPause = $true
    )

    
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

        Write-Host "Opening ports to local network..."
        New-NetFirewallRule -DisplayName "Ports 8083-8083 TCP Inbound" -Direction Inbound -LocalPort 8080-8083 -Protocol TCP -Action Allow
        New-NetFirewallRule -DisplayName "Ports 8080-8083 TCP Outbound" -Direction Outbound -LocalPort 8080-8083 -Protocol TCP -Action Allow

        # UDP Firewall Rules
        New-NetFirewallRule -DisplayName "Ports 8080-8083 UDP Inbound" -Direction Inbound -LocalPort 8080-8083 -Protocol UDP -Action Allow
        New-NetFirewallRule -DisplayName "Ports 8080-8083 UDP Outbound" -Direction Outbound -LocalPort 8080-8083 -Protocol UDP -Action Allow


        Write-Host "Finished. Listing relevant firewall current settings..."

        Get-NetFirewallRule | Where-Object DisplayName -like '*Ports 8083-*' | Format-Table -Property DisplayName,Enabled,Direction,Action

        # if you need to remove the firewall openings:  Get-NetFirewallRule | Where-Object DisplayName -like 'Ports 8083-*' | Remove-NetFirewallRule


 Write-Host "Listing portproxy current settings..."
        netsh interface portproxy show all
        if ($YesPause) { Pause; Exit }

    }
    else {
        Write-Host "Running as Admin..."
        $commandToRun = "Import-Module $PSCommandPath; New-NucleusLocalPortForward"
        Start-Process pwsh -Verb RunAs -ArgumentList "-NoExit", "-Command", "$commandToRun"
    }




}


