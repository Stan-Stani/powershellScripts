try {
    pwsh C:\Users\StanStanislaus\utils\pullMains\pullMains.ps1

    # pwsh C:\Users\StanStanislaus\Documents\Stan\Utils\backendConfigs\SignalR\setupSignalRAddress.ps1

    # pwsh C:\Users\StanStanislaus\Documents\Stan\Utils\backendConfigs\stan-backend-config-FUNCTIONS\setupLocalAzureFunctions.ps1
}
catch {
}
finally {
    if ($Error) {
        Write-Host -ForegroundColor Red "Error: $Error"
        pause
    }
}