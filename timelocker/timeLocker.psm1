function Invoke-TimeLocker {
    param (
        # Can do `Invoke-Timelocker -MinMinutes 5` OR `Invoke-Timelocker 5`
        [Parameter(Position = 0)]
        [int]$MinMinutes,
        [Parameter(Position = 1)]
        [int]$MaxMinutes
    )
    Write-Host

    if ($MinMinutes -le 0) {
        $MinMinutes = Read-Host -Prompt "How many minutes MINIMUM do you want to spend?"
    }
    if ($MinMinutes -le 0) {
        Write-Host
        Write-Host "You must enter a positive number for the minimum time." -ForegroundColor Red
        Write-Host
        Invoke-TimeLocker
    }

    if ($MaxMinutes -le 0) {
        $MaxMinutes = Read-Host -Prompt "How many minutes MAXIMUM do you want to spend?"
    }
    if ($MaxMinutes -lt $MinMinutes) {
        Write-Host
        Write-Host "The maximum time cannot be less than the minimum time, you dolt!" -ForegroundColor Red

        Write-Host
        $MaxMinutes = Read-Host -Prompt "How many minutes MAXIMUM do you want to spend?"
    }
    if ($MaxMinutes -le 0 -OR $MaxMinutes -lt $MinMinutes) {
        $MaxMinutes = $MinMinutes
        Write-Host
        Write-Host "Setting maximum time to same value as minimum time, that is: $MinMinutes."
    }
    # https://ephos.github.io/posts/2018-8-20-Timers
    $stopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
    $stopWatch.Start()
    $minTimeSpan = New-TimeSpan -Minutes $MinMinutes
    $maxTimeSpan = New-TimeSpan -Minutes $MaxMinutes
    $breakTimeSpan = New-TimeSpan -Minutes 7


    $voice = New-Object -ComObject Sapi.spvoice
    $voice.rate = 0
    $hasSpoken = $false

    Write-Host
    Write-Host
  


    while ($stopWatch.Elapsed -le $minTimeSpan) {
  
        if ([System.Console]::KeyAvailable) {
            # true means don't display
            $keyPressedInfo = [System.Console]::ReadKey($true) 
            $keyPressed = $keyPressedInfo.Key 
            Write-Host "`nYou pressed $keyPressed."
            if ($keyPressed -eq "P") {
                $stopwatch.Stop()
                Write-Host "Paused. Press any key to resume timer..."
                [System.Console]::ReadKey($true)
                $stopWatch.Start()
            }
        }
          
        Start-Sleep 0.99
        $elapsedTime = $stopWatch.Elapsed

        Write-Host "`r" $($elapsedTime.Minutes):$($elapsedTime.Seconds) -NoNewLine + "out of $MinMinutes minutes MINIMUM and $MaxMinutes MAXIMUM."

        if (!$hasSpoken -and $minTimeSpan.totalMinutes - $elapsedTime.totalMinutes -le 5) {
            $words = "5 minutes remaining until minimum."
            $voice.speak($words)
            Write-Host
            Write-Host($words)
            $hasSpoken = $true
        }
    }

    $words = "Minimum time reached."
    $voice.speak($words)
    Write-Host
    Write-Host($words)
    $hasSpoken = $false

    $words = "Go take a $($breakTimeSpan.totalMinutes) minute break!"
    $voice.speak($words)
    Write-Host $words
    $bigAsciiArtWords = @"
   _____   ____    _______         _  __ ______              ____   _____   ______            _  __
  / ____| / __ \  |__   __| /\    | |/ /|  ____|     /\     |  _ \ |  __ \ |  ____|    /\    | |/ /
 | |  __ | |  | |    | |   /  \   | ' / | |__       /  \    | |_) || |__) || |__      /  \   | ' / 
 | | |_ || |  | |    | |  / /\ \  |  <  |  __|     / /\ \   |  _ < |  _  / |  __|    / /\ \  |  <  
 | |__| || |__| |    | | / ____ \ | . \ | |____   / ____ \  | |_) || | \ \ | |____  / ____ \ | . \ 
  \_____| \____/     |_|/_/    \_\|_|\_\|______| /_/    \_\ |____/ |_|  \_\|______|/_/    \_\|_|\_\
                                                                                                                                                                            
"@

    $shell = New-Object -ComObject "Shell.Application"
    $shell.MinimizeAll()

    $tempFile = [System.IO.Path]::GetTempFileName()
    $bigAsciiArtWords | Out-File -FilePath $tempFile -Encoding ASCII
    $sleepSeconds = 10

    Start-Process -FilePath "pwsh.exe" -ArgumentList "-NoExit", "-Command &{Get-Content -Path '$tempFile' -Raw; Write-Host $words; Remove-Item -Path '$tempFile'; Start-Sleep -Seconds $sleepSeconds; exit}" -PassThru -WindowStyle Maximized
    Start-Sleep -Seconds $sleepSeconds
    $shell.UndoMinimizeALL(); Rundll32.exe user32.dll, LockWorkStation;
    $breakStopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
    $stopWatch.Elapsed
    $stopWatch.Stop()
    $breakStopWatch.Start()

    while ($breakStopWatch.Elapsed -le $breakTimeSpan) {
        $elapsedTime = $breakStopWatch.Elapsed
        Start-Sleep 0.99

        Write-Host "`r" $($elapsedTime.Minutes):$($elapsedTime.Seconds) -NoNewLine + "out of $($breakTimeSpan.TotalMinutes) minutes in break."
    }
    $breakStopWatch.Stop()

    Write-Host
    Read-Host -Prompt "Press enter to start timer until the maximum minutes: $MaxMinutes"
    Write-Host
    $stopWatch.Elapsed
    $stopWatch.Start()
    

    while ($stopWatch.Elapsed -le $maxTimeSpan) {
        $elapsedTime = $stopWatch.Elapsed
        Start-Sleep 0.99

        Write-Host "`r" $($elapsedTime.Minutes):$($elapsedTime.Seconds) -NoNewLine + "out of $MaxMinutes minutes MAXIMUM"

        if (!$hasSpoken -and $maxTimeSpan.totalMinutes - $elapsedTime.totalMinutes -le 5) {
            $words = "5 minutes remaining until logoff."
            $voice.speak("5 minutes remaining until logoff.")
            $hasSpoken = $true
            Write-Host
            Write-Host($words)
        }
    }

    Rundll32.exe user32.dll, LockWorkStation
}
New-Alias -Name tl -Value Invoke-TimeLocker

