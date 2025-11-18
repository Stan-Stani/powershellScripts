# List all active TCP connections on local port 3001
# 

$portToCheck = 3001
$connections = Get-NetTCPConnection -LocalPort $portToCheck |
    Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess

$connections | Format-Table -AutoSize

Write-Host "`n---`n"

# Get unique process IDs from the connections
$processIds = $connections | Select-Object -ExpandProperty OwningProcess -Unique

# List process details for those IDs
Get-Process | Where-Object { $processIds -contains $_.Id } |
    Select-Object Id, ProcessName |
    Format-Table -AutoSize