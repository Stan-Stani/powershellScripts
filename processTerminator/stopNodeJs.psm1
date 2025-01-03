


function Stop-NodeJS {
    param ([Parameter(Position = 0)]
    $CheckCommandsFirst)

# Get Node.js processes with their command line info
$nodeProcesses = Get-Process | Where-Object { $_.Description -eq "Node.js JavaScript Runtime" } | 
    ForEach-Object {
        $commandLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)").CommandLine
        $_ | Add-Member -MemberType NoteProperty -Name 'NodeCommandLine' -Value $commandLine -PassThru
    }

# Check if any processes were found
if ($nodeProcesses) {
    
# @todo get this option to actually work
    if ($dryRun -eq "--check-commands-first") {

    
    Write-Host "Found the following Node.js processes:"
    $nodeProcesses | Format-Table Id, ProcessName, StartTime, NodeCommandLine

    $confirmation = Read-Host "Do you want to terminate these processes? (y/n)"
    if ($confirmation -eq 'y') {
        try {
            $nodeProcesses | ForEach-Object {
                Stop-Process -Id $_.Id -Force
                Write-Host "Successfully terminated process $($_.Id)"
            }
            Write-Host "All Node.js processes have been terminated."
        }
        catch {
            Write-Error "Error terminating processes: $_"
        }
    }
    } else {
         try {
            $nodeProcesses | ForEach-Object {
                Stop-Process -Id $_.Id -Force
                Write-Host "Successfully terminated process $($_.Id)"
            }
            Write-Host "All Node.js processes have been terminated."
        }
        catch {
            Write-Error "Error terminating processes: $_"
        }
    }
}
else {
    Write-Host "No Node.js processes found running."
}
}