
function Get-Env {
    param (
        [Parameter(Position = 0)]
        $EnvFileContainingDir
    )

    # https://stackoverflow.com/a/74839464/1465015
    Get-Content ("$EnvFileContainingDir/.env" || .env) | ForEach-Object {
        $name, $value = $_.split('=')
        if ([string]::IsNullOrWhiteSpace($name) || $name.Contains('#')) {
            continue
        }
        Set-Content env:\$name $value
    }
}