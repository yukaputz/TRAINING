# Define the list of servers to scan
$servers = Get-Content "C:\path\to\servers.txt"  # Adjust the path to your server list

# Create an empty array to hold the results
$results = @()

# Define the range of ports to scan (1 through 65535)
$ports = 1..65535

# Create a job to scan each server in parallel
$jobs = @()

foreach ($server in $servers) {
    $job = Start-Job -ScriptBlock {
        param($server, $ports)

        $serverResults = @()

        foreach ($port in $ports) {
            # Check if the port is open
            $connection = Test-NetConnection -ComputerName $server -Port $port

            # Create a custom object for each result
            $result = [PSCustomObject]@{
                ServerName   = $server
                Port         = $port
                IsOpen       = $connection.TcpTestSucceeded
                ResponseTime = $connection.ResponseTime
            }

            $serverResults += $result
        }

        return $serverResults
    } -ArgumentList $server, $ports

    $jobs += $job
}

# Wait for all jobs to finish and collect the results
$jobs | ForEach-Object {
    $jobResults = Receive-Job -Job $_
    $results += $jobResults
    Remove-Job -Job $_
}

# Export the results to a CSV file
$results | Export-Csv -Path "C:\path\to\output.csv" -NoTypeInformation

Write-Host "Scan complete. Results saved to output.csv"
