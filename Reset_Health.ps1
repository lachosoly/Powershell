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

    # Reset the health state of the monitoring object
    if ($monitoringObject) {
        Write-Host "Resetting health for: $($monitoringObject.DisplayName)"
        $monitoringObject.ResetMonitoringState()
    }
    else {
        Write-Host "Could not find the monitoring object for alert: $($alert.Name)"
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


