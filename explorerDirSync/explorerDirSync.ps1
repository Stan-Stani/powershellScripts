# Replace with the path of the directory you want to navigate to
$targetDirectory = "C:\path\to\your\directory"

# Create a WSH shell object
$shell = New-Object -ComObject "WScript.Shell"

# Find all Windows Explorer windows
$explorerWindows = Get-Process | Where-Object { $_.MainWindowTitle -like "Home*" }

foreach ($window in $explorerWindows) {
    # Activate the window
    $shell.AppActivate($window.MainWindowHandle)

    # Wait for a short delay to ensure the window is activated
    Start-Sleep -Milliseconds 100

    # Send the directory path and press Enter
    $shell.SendKeys($targetDirectory)
    $shell.SendKeys("{ENTER}")

    # Wait for a short delay to allow the navigation to complete
    Start-Sleep -Milliseconds 100
}