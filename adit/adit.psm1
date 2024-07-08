# Open link in Webkit: npx playwright wk http://localhost:3001



# 
function Invoke-Adit {
    param (
        # Resets .env.local
        [switch]$ShouldReset,
        [switch]$ShouldKillExisting,
        [switch]$ZrokInstead
    )

    Start-Process PowerShell "zrok share reserved zfgxrjt9c9gl"
    Start-Process PowerShell "zrok share reserved ysqkfi80qfc4"
    Start-Process PowerShell "zrok share reserved h7v9m7iooegn"

    exit

    function Invoke-Kill-Ngrok {
        # Check if an ngrok process is already running
        $ngrokProcess = Get-Process -Name "ngrok" -ErrorAction SilentlyContinue
        if ($ngrokProcess) {
            Write-Host "An ngrok process is already running. Terminating it..."
            $ngrokProcess | Stop-Process -Force
            Write-Host "Ngrok process terminated."
        
        
        }
    }

    $moduleLocation = $PSScriptRoot

    if ($ShouldReset) {
        $ShouldKillExisting = $true
    }

    if ($ShouldReset) {
        $resetContent = Get-Content "C:\Users\StanStanislaus\Documents\git-repos\steffes-website\apps\web\.env.local copy.local"
        $resetContent | Set-Content -Path "C:\Users\StanStanislaus\Documents\git-repos\steffes-website\apps\web\.env.local"
        return
    }

    if ($ShouldKillExisting) {
        Invoke-Kill-Ngrok
        return
    }

    if ($ZrokInstead) {
        $coreAPIURL = "https://$Env:ZROK_RESERVED_CORE_API_TOKEN.share.zrok.io"
        $authAPIURL = "https://$Env:ZROK_RESERVED_AUTH_API_TOKEN.share.zrok.io"
        $externalAPIURL = "https://$Env:ZROK_RESERVED_EXTERNAL_API_TOKEN.share.zrok.io"
    }


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

    function Get-EnvVars {
        # https://stackoverflow.com/a/74839464/1465015
        #getEnvVars
        try {
            Get-Content (Join-Path $moduleLocation ".env.local") | foreach {
                $name, $value = $_.split('=')
                if ([string]::IsNullOrWhiteSpace($name) || $name.Contains('#')) {
                    write-host "continued"
                    continue
                }
                Write-Host $name
                Set-Content env:\$name $value
            }
        }
        catch {
            Write-Host Could not get env file stuff
        }
        write-host 'done'
    }

    # gpt4o says use this instead
    # function Get-EnvVars {
    #     # https://stackoverflow.com/a/74839464/1465015
    #     #getEnvVars
    #     try {
    #         $envFilePath = Join-Path $moduleLocation ".env.local"
    #         Write-Host "Reading environment variables from: $envFilePath"

    #         $lines = Get-Content $envFilePath

    #         Write-Host "Total lines to process: $($lines.Count)"

    #         $lines | ForEach-Object {
    #             Write-Host "Processing line: '$_'"

    #             # Trim leading and trailing whitespace from the line
    #             $_ = $_.Trim()

    #             # Skip blank lines and comments
    #             if ([string]::IsNullOrWhiteSpace($_) -or $_.StartsWith('#')) {
    #                 Write-Host "continued"
    #                 return
    #             }

    #             # Split the line into name and value
    #             $splitLine = $_.Split('=', 2)  # Limit split to 2 parts
    #             if ($splitLine.Count -ne 2) {
    #                 Write-Host "Invalid line: $_"
    #                 return
    #             }

    #             $name = $splitLine[0].Trim()
    #             $value = $splitLine[1].Trim()

    #             # Validate name
    #             if ([string]::IsNullOrWhiteSpace($name)) {
    #                 Write-Host "continued"
    #                 return
    #             }

    #             Write-Host "Setting environment variable: $name with value: $value"
    #             Set-Content -Path "env:\$name" -Value $value
    #         }
    #     }
    #     catch {
    #         Write-Error "Could not get env file stuff: $_"
    #     }

    #     Write-Host 'done'
    # }

    function Start-Ngrok {
        param (
            [string]
            $WorkingDir = ""
        )

       
        

        $outputFile = (Join-Path $moduleLocation ".\log.log")
        Write-Host "Making sure there is no old log file at $outputFile"
        Remove-Item $outputFile -ErrorAction Continue
  
    

        $ngrokProcess = Start-Process -FilePath "ngrok" -ArgumentList "start --all --log `"$outputFile`""  -PassThru


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

    function Start-Zrok {

        write-host helloz

        try {
            Start-Process -FilePath "zrok" -ArgumentList "zrok share reserved $Env:ZROK_RESERVED_CORE_API_TOKEN"
            Start-Process -FilePath "zrok" -ArgumentList "zrok share reserved $Env:ZROK_RESERVED_AUTH_API_TOKEN"
            Start-Process -FilePath "zrok" -ArgumentList "zrok share reserved $Env:ZROK_RESERVED_EXTERNAL_API_TOKEN"
        }
        catch {
            write-host "Couldn't start zrok processes"
        }

        Write-Host "Zrok processes started."
 

        # Sleeping to wait for tunnels to open
    

        # Initialize an empty array to store the extracted URLs
        $localUrls = @("https://localhost:44357", "https://localhost:44396", "https://localhost:44358")
        $externalUrls = @($coreAPIURL, $authAPIURL, $externalAPIURL)

        $urlTuple = @($localUrls, $externalUrls)

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
          
                write-host 'fail'
            }
        
        
            $urlIndex++
        }

        $envContent | Set-Content $envPath
    }

    write-host hello
    Get-EnvVars
    write-host hello
    if (-not $ZrokInstead) {
        Start-Ngrok
    }
    else {
        Start-Zrok
    }
    write-host 'fail2'

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

}
New-Alias -Name adit -Value Invoke-Adit

