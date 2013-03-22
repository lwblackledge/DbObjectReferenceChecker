param
(
	[string] $connectionString = $(throw "Enter a connection string."),
	[string] $objectName = $(throw "Enter an object to check for dependencies.")
)

$invalidObjectsFile = "$(Get-Location)\invalidObjects.txt";
if ((Test-Path $invalidObjectsFile) -eq $false) {
	New-Item $invalidObjectsFile -ItemType file;
}

$invalidObjects = "'" + (([regex]::split([IO.File]::ReadAllText($invalidObjectsFile).trim(), [system.environment]::newline)) -join "','") + "'";

$results = @();

$getDependenciesQuery = "
SELECT o.Name AS CallingObject
   , o.type_desc AS OfType
   , re.referenced_entity_name AS ReferencesThis
   , reo.Type_desc AS TypeOf
FROM sys.sql_modules AS sm
INNER JOIN sys.objects AS o ON sm.object_id = o.object_id
INNER JOIN sys.schemas AS sch ON o.schema_id = sch.schema_id
CROSS APPLY sys.dm_sql_referenced_entities (sch.name + '.' + o.Name, 'OBJECT') AS re
INNER JOIN sys.objects AS reo ON re.referenced_entity_name = reo.Name
WHERE o.Name NOT IN( $invalidObjects )
   AND reo.name = '$objectName'
ORDER BY o.Name ASC, reo.Type_desc ASC, re.referenced_entity_name ASC;";

$conn = New-Object System.Data.SqlClient.SqlConnection($connectionString);
$conn.Open();
$cmd = New-Object System.Data.SqlClient.SqlCommand($getDependenciesQuery, $conn);

$reader = $cmd.ExecuteReader();
while ($reader.Read() -eq $true) {
	$results += $reader[0];
}

$reader.Dispose();
$cmd.Dispose();
$conn.Close();
$conn.Dispose();

return $results | Sort-Object $_ -Unique;