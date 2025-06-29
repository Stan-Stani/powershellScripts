
# netsh interface portproxy add v4tov4 listenport=3003 listenaddress=127.0.0.1 connectport=3003 connectaddress=192.168.11.49

function New-PortForward {
    param (
        [Parameter(Position = 0)]
        [string] $listenAddress,
        [Parameter(Position = 1)]
        [int] $listenPort,
        [Parameter(Position = 2)]
        [string] $connectAddress,
        [Parameter(Position = 3)]
        [int] $connectPort
    )

    netsh interface portproxy add v4tov4 listenport=$listenPort listenAddress=$listenAddress connectPort=$connectPort connectAddress=$connectAddress
  
}

# Forward a given localhost port to another localhost port
function New-LocalhostPortForward {
    param (
        [Parameter(Position = 0)]
        [int] $listenPort,
        [Parameter(Position = 1)]
        [int] $connectPort
    )

   New-PortForward "127.0.0.1" $listenPort "127.0.0.1" $connectPort
  
}

function Remove-LocalhostPortForward {
    param (
        [Parameter(Position = 0)]
        [int] $listenPort
    )
    
    netsh interface portproxy delete v4tov4 listenport=$listenPort listenaddress=$listenAddress
}

function Remove-PortForwardAll {
    if (Get-IsElevated) {
        netsh interface portproxy reset
    }
    else {
        Write-Host "Running as Admin..."
        $commandToRun = "Import-Module $PSCommandPath; Remove-PortForwardAll"
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


function New-NucleusPortForward {
    param (
        [Parameter(Position = 0)]
        [boolean] $YesPause = $true
    )

    $FirewallRuleSetIdentifier = "NucleusPortForward"
    
    if (Get-IsElevated) {   
        Write-Host "Forwarding Internal, External, and Auth Api Ports..."

        $ModulePathForGetEnv = Join-Path -Path $PSScriptRoot -ChildPath /readEnv.psm1


        Write-Host "Reading Port settings from .env..."
    
            $ModulePathForGetEnv
            Import-Module $ModulePathForGetEnv
            Get-Env($PSScriptRoot)
      

        Write-Host "Setting up forwarding..."
        # Nucleus CoreAPI Auth
        New-PortForward  $Env:ListenAddress $Env:AuthFrom $Env:ConnectAddress $Env:AuthTo
        # Nucleus CoreAPI (Internal)
        New-PortForward $Env:ListenAddress $Env:InternalFrom $Env:ConnectAddress $Env:InternalTo
        # Nucleus CoreAPI External
        New-PortForward $Env:ListenAddress $Env:ExternalFrom $Env:ConnectAddress $Env:ExternalTo

        Write-Host "Clearing matching firewalls rules, if they already exist..."
        Get-NetFirewallRule | Where-Object DisplayName -like "$FirewallRuleSetIdentifier*" | Remove-NetFirewallRule

        Write-Host "Opening ports to local network, via firewall..."

        # TCP Firewall Rules
        New-NetFirewallRule -DisplayName "$FirewallRuleSetIdentifier $Env:AuthFrom TCP Inbound" -Direction Inbound -LocalPort $Env:AuthFrom -Protocol TCP -Action Allow
        New-NetFirewallRule -DisplayName "$FirewallRuleSetIdentifier $Env:InternalFrom TCP Inbound" -Direction Inbound -LocalPort $Env:InternalFrom -Protocol TCP -Action Allow
        New-NetFirewallRule -DisplayName "$FirewallRuleSetIdentifier $Env:ExternalFrom TCP Inbound" -Direction Inbound -LocalPort $Env:ExternalFrom -Protocol TCP -Action Allow

        New-NetFirewallRule -DisplayName "$FirewallRuleSetIdentifier $Env:AuthFrom TCP Outbound" -Direction Outbound -LocalPort $Env:AuthFrom -Protocol TCP -Action Allow
        New-NetFirewallRule -DisplayName "$FirewallRuleSetIdentifier $Env:InternalFrom TCP Outbound" -Direction Outbound -LocalPort $Env:InternalFrom -Protocol TCP -Action Allow
        New-NetFirewallRule -DisplayName "$FirewallRuleSetIdentifier $Env:ExternalFrom TCP Outbound" -Direction Outbound -LocalPort $Env:ExternalFrom -Protocol TCP -Action Allow

        # UDP Firewall Rules
        New-NetFirewallRule -DisplayName "$FirewallRuleSetIdentifier $Env:AuthFrom UDP Inbound" -Direction Inbound -LocalPort $Env:AuthFrom -Protocol UDP -Action Allow
        New-NetFirewallRule -DisplayName "$FirewallRuleSetIdentifier $Env:InternalFrom UDP Inbound" -Direction Inbound -LocalPort $Env:InternalFrom -Protocol UDP -Action Allow
        New-NetFirewallRule -DisplayName "$FirewallRuleSetIdentifier $Env:ExternalFrom UDP Inbound" -Direction Inbound -LocalPort $Env:ExternalFrom -Protocol UDP -Action Allow

        New-NetFirewallRule -DisplayName "$FirewallRuleSetIdentifier $Env:AuthFrom UDP Outbound" -Direction Outbound -LocalPort $Env:AuthFrom -Protocol UDP -Action Allow
        New-NetFirewallRule -DisplayName "$FirewallRuleSetIdentifier $Env:InternalFrom UDP Outbound" -Direction Outbound -LocalPort $Env:InternalFrom -Protocol UDP -Action Allow
        New-NetFirewallRule -DisplayName "$FirewallRuleSetIdentifier $Env:ExternalFrom UDP Outbound" -Direction Outbound -LocalPort $Env:ExternalFrom -Protocol UDP -Action Allow


        Write-Host "Finished. Listing relevant firewall current settings..."

        Get-NetFirewallRule | Where-Object DisplayName -like "*$FirewallRuleSetIdentifier*" | Format-Table -Property DisplayName,Enabled,Direction,Action



 Write-Host "Listing portproxy current settings..."
        netsh interface portproxy show all
        if ($YesPause) { Pause; Exit }

    }
    else {
        Write-Host "Running as Admin..."
        $commandToRun = "Import-Module $PSCommandPath; New-NucleusPortForward"
        Start-Process pwsh -Verb RunAs -ArgumentList "-NoExit", "-Command", "$commandToRun"
    }

}


