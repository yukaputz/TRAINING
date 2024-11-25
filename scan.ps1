# Define the list of servers to scan
$servers = Get-Content "C:\path\to\servers.txt"  # Adjust the path to your server list

# Create an empty array to hold the results
$results = @()

# Loop through each server
foreach ($server in $servers) {
    # Loop through each port (1 to 65535)
    for ($port = 1; $port -le 65535; $port++) {
        # Check if the port is open
        $connection = Test-NetConnection -ComputerName $server -Port $port

        # Create a custom object for each result
        $result = [PSCustomObject]@{
            ServerName   = $server
            Port         = $port
            IsOpen       = $connection.TcpTestSucceeded
            ResponseTime = $connection.ResponseTime
        }

        # Add the result to the results array
        $results += $result

        # Optional: To speed up scanning, you could output progress every 100 ports
        if ($port % 100 -eq 0) {
            Write-Host "Scanning server '$server', port $port..."
        }
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path "C:\path\to\output.csv" -NoTypeInformation

Write-Host "Scan complete. Results saved to output.csv"
