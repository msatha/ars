Function Execute-SqlCmd {
    Param(
        [Parameter(Mandatory=$true)][string]$command,
        [Parameter(Mandatory=$true)][string]$sqlServerName,
        [Parameter(Mandatory=$true)][string]$databaseName,
        [Parameter(Mandatory=$true)][string]$userName,
        [Parameter(Mandatory=$true)][string]$password
    )
    Process
    {
        #$pwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
        #$command = Get-Content -Path .\scripts\sql\create-table.sql
        $gscn = New-Object System.Data.SqlClient.SqlConnection
        $gscn.ConnectionString = "Server=tcp:$sqlServerName.database.windows.net,1433;Initial Catalog=$databaseName;Persist Security Info=False;User ID=$userName;Password=$password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
        
        $wrCmd = New-Object System.Data.SqlClient.SqlCommand
        $wrCmd.Connection = $gscn
        $wrCmd.CommandTimeout = 0
        $wrCmd.CommandText = $command
 
        $gscn.Open()
        $wrCmd.ExecuteNonQuery() | Out-Null
        $gscn.Dispose()
        $wrCmd.Dispose()

        # try
        # {
        #     $gscn.Open()
        #     $wrCmd.ExecuteNonQuery() | Out-Null
        # }
        # catch [Exception]
        # {
        #     Write-Warning $_.Exception.Message
        #     Write-Warning $command
        # }
        # finally
        # {
        #     $gscn.Dispose()
        #     $wrCmd.Dispose()
        # }
    }
}

