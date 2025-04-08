function Get-Env {
    param (
        [Parameter(Position = 0)]
        $EnvFileContainingDir
    )

    $envPath = if ($EnvFileContainingDir) { Join-Path $EnvFileContainingDir ".env" } else { ".env" }
    
    if (Test-Path $envPath) {
        Get-Content $envPath | ForEach-Object {
            $line = $_.Trim()
            
            # Skip empty lines and comment lines
            if ([string]::IsNullOrWhiteSpace($line) || $line.StartsWith('#')) {
                # Write-Host "Skipping: $line"
            } 
            else {
                $name, $value = $line.Split('=', 2)
                $name = $name.Trim()
                if (![string]::IsNullOrWhiteSpace($name)) {
                    # Write-Host "Adding $name to env"
                    [Environment]::SetEnvironmentVariable($name, $value, "Process")
                }
            }
        }
    } else {
        Write-Host "Environment file not found: $envPath"
    }
}