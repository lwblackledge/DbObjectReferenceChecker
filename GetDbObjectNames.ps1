param
(
	[string] $connectionString = $(throw "Enter a connection string.")
)

$getObjectsQuery = "SELECT name FROM sys.sql_modules AS sm INNER JOIN sys.objects AS o ON sm.object_id = o.object_id";

$results = @();

$conn = New-Object System.Data.SqlClient.SqlConnection($connectionString);
$conn.Open();
$cmd = New-Object System.Data.SqlClient.SqlCommand($getObjectsQuery, $conn);

$reader = $cmd.ExecuteReader();

while ($reader.Read() -eq $true) {
	$results += $reader[0];
}

$reader.Dispose();
$cmd.Dispose();
$conn.Close();
$conn.Dispose();

return $results | Sort-Object $_ -Unique;