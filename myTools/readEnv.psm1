
function Get-Env {
    # https://stackoverflow.com/a/74839464/1465015
    Get-Content .env | ForEach-Object {
        $name, $value = $_.split('=')
        if ([string]::IsNullOrWhiteSpace($name) || $name.Contains('#')) {
            continue
        }
        Set-Content env:\$name $value
    }
}