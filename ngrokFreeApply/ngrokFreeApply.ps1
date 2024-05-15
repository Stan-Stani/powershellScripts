# Open link in Webkit: npx playwright wk http://localhost:3001



function Get-Common-Line-Values {
    param (
        [string]
        $Path = ""
        # [string]
        # $regex = "url=([\S]+)"
    )


    # Read the lines from the file into an array
    $lines = Get-Content -Path $Path

    # Initialize an empty array to store the extracted URLs
    $localUrls = @()
    $externalUrls = @()

    # Iterate over each line and extract the URL using a regular expression
    foreach ($line in $lines) {
        if ($line -match "msg=`"started tunnel`".*?(?=addr=(\S+))") {
            $localUrls += $matches[1]

            if ($line -match "url=([\S]+)") {
                $externalUrls += $matches[1]
            }
        } 
       

    }
    Write-Host "local"
    Write-Host $localUrls
    Write-Host "external"
    Write-Host $externalUrls

    # Array should be something like
    # https://localhost:44396
    # https://0036-76-10-70-110.ngrok-free.app
    # https://localhost:44358
    # https://af88-76-10-70-110.ngrok-free.app
    # https://localhost:44357
    # https://53e6-76-10-70-110.ngrok-free.app
    return @($localUrls, $externalUrls)

}

function Start-Ngrok {
    param (
        [string]
        $WorkingDir = ""
    )

    #getEnvVars
    Get-Content .env.local | foreach {
        $name, $value = $_.split('=')
        if ([string]::IsNullOrWhiteSpace($name) || $name.Contains('#')) {
            continue
        }
        Set-Content env:\$name $value
    }

    if ($ngrokProcess) {
        Write-Host "An ngrok process is already running. Terminating it..."
        $ngrokProcess | Stop-Process -Force
        Write-Host "Ngrok process terminated."
        
        
    }

    $outputFile = ".\log.log"
    Write-Host "Making sure there is no old log file at $outputFile"
    Remove-Item $outputFile -ErrorAction Stop
  

    # Check if an ngrok process is already running
    $ngrokProcess = Get-Process -Name "ngrok" -ErrorAction SilentlyContinue

  

    

    Start-Process -FilePath "ngrok" -ArgumentList "start --all --log `"$outputFile`"" 


    Write-Host "Ngrok process started. Output is being redirected to $outputFile."
 

    # Sleeping to wait for tunnels to open
    Start-Sleep -Seconds 10
    $urlTuple = Get-Common-Line-Values -Path $outputFile
    $envPath = $Env:ENV_TO_CHANGE
    $envContent = Get-Content $envPath
    # length of both arrs should be same
    
    $urlIndex = 0
    foreach ($url in $urlTuple[0]) {
        Write-Host "internalURL"
        Write-Host $url
    
        for ($i = 0; $i -lt $envContent.Length; $i++) {
            $line = $envContent[$i]
            if ($line -match "^NEXT" -and $line -match $url) {
                # Replace internal URLs with ngrok external URLs
                Write-Host "EXTNERal"
                Write-Host $urlTuple[1][$urlIndex]
                $envContent[$i] = $line.Replace($url, $urlTuple[1][$urlIndex])
            }
          
        }
        
        
        $urlIndex++
    }

    $envContent | Set-Content $envPath
    # $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


    



}

Start-Ngrok

$session = New-PSSession -UseWindowsPowerShell
Invoke-Command -Session $session {

    # Src https://superuser.com/questions/1341997/using-a-uwp-api-namespace-in-powershell
    Add-Type -AssemblyName System.Runtime.WindowsRuntime
    $asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
    Function Await($WinRtTask, $ResultType) {
        $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
        $netTask = $asTask.Invoke($null, @($WinRtTask))
        $netTask.Wait(-1) | Out-Null
        $netTask.Result
    }
    

    # Src https://stackoverflow.com/questions/45833873/enable-windows-10-built-in-hotspot-by-cmd-batch-powershell
    Function Start-Hotspot() {
        $connectionProfile = [Windows.Networking.Connectivity.NetworkInformation, Windows.Networking.Connectivity, ContentType = WindowsRuntime]::GetInternetConnectionProfile()
        $tetheringManager = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager, Windows.Networking.NetworkOperators, ContentType = WindowsRuntime]::CreateFromConnectionProfile($connectionProfile)

        # Be sure to include Ben N.'s await for IAsyncOperation:
        # https://superuser.com/questions/1341997/using-a-uwp-api-namespace-in-powershell


        
        # Check whether Mobile Hotspot is enabled
        $tetheringManager.TetheringOperationalState

        # Start Mobile Hotspot
        Await ($tetheringManager.StartTetheringAsync()) ([Windows.Networking.NetworkOperators.NetworkOperatorTetheringOperationResult])

        # Stop Mobile Hotspot
        # Await ($tetheringManager.StopTetheringAsync()) ([Windows.Networking.NetworkOperators.NetworkOperatorTetheringOperationResult])
    }


    Start-Hotspot
}