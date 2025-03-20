function Stop-NodeJS {
    param (
        [Parameter()]
        [switch]$Force,
        [Parameter()]
        [string]$ExcludePath
    )

    $nodeProcesses = Get-Process | Where-Object { $_.Description -eq "Node.js JavaScript Runtime" } | 
        ForEach-Object {
            $commandLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)").CommandLine
            $_ | Add-Member -MemberType NoteProperty -Name 'NodeCommandLine' -Value $commandLine -PassThru
        }

    if ($ExcludePath) {
        $nodeProcesses = $nodeProcesses | Where-Object { $_.NodeCommandLine -notlike "*$ExcludePath*" }
    }

    if ($nodeProcesses) {
        if ($Force) {
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
        else {
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
        }
    }
    else {
        Write-Host "No Node.js processes found running."
    }
}