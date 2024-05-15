function Invoke-TimeLocker {
    param (
        # Can do `Invoke-Timelocker -minutes 5` OR `Invoke-Timelocker 5`
        [Parameter(Position = 0)]
        [int]$Minutes
    )

    if ($Minutes -eq 0) {
        $Minutes = Read-Host -Prompt "How many minutes do you want to spend?"
    }
    # https://ephos.github.io/posts/2018-8-20-Timers
    $stopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
    $stopWatch.Start()
    $timeSpan = New-TimeSpan -Minutes $Minutes


    $voice = New-Object -ComObject Sapi.spvoice
    $voice.rate = 0
    $hasSpoken = $false


    while ($stopWatch.Elapsed -le $timeSpan) {
        $elapsedTime = $stopWatch.Elapsed
        Start-Sleep 0.99

        Write-Host "`r" $($elapsedTime.Minutes):$($elapsedTime.Seconds) -NoNewLine + "out of $Minutes minutes"

        if (!$hasSpoken -and $timeSpan.totalMinutes - $elapsedTime.totalMinutes -le 5) {
            $voice.speak("5 minutes remaining.")
            $hasSpoken = $true
        }
    }

    Rundll32.exe user32.dll, LockWorkStation
}