# Load SCOM PowerShell module
Import-Module OperationsManager

# Connect to the SCOM management server
$managementServer = "SCOM"
New-SCOMManagementGroupConnection -ComputerName $managementServer

# Fetch all open alerts
$openAlerts = Get-SCOMAlert -Criteria 'ResolutionState <> 255'

foreach ($alert in $openAlerts) {
    # Get the monitoring object related to the alert
    $monitoringObject = Get-SCOMMonitoringObject -Id $alert.MonitoringObjectId

    # Check if the monitor state is healthy
    if ($monitoringObject.HealthState -eq "Success") {
        # Close the alert if the monitor state is healthy
        $alert | Resolve-SCOMAlert -Comment "Alert automatically closed as the monitor returned to a healthy state."
        Write-Host "Closed alert: $($alert.Name) for object: $($monitoringObject.DisplayName)"
    }
    else {
        Write-Host "Alert $($alert.Name) for object: $($monitoringObject.DisplayName) is not in a healthy state."
    }
}


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

