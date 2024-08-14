# Check for active SCOM connections
$activeConnections = Get-SCOMManagementGroupConnection

if ($activeConnections) {
    foreach ($connection in $activeConnections) {
        Write-Host "Disconnecting from Management Group: $($connection.ManagementGroupName)"
        Remove-SCOMManagementGroupConnection -Connection $connection
    }
    Write-Host "All connections have been disconnected."
} else {
    Write-Host "No active SCOM connections found."
}

