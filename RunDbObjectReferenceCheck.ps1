param
(
	[string] $connectionString = "replace this",
	[string] $searchLocation = "replace this"
)

$ErrorActionPreference = "stop";

$nl = [Environment]::NewLine;

$outputFile = "$(Get-Location)\results.txt";
New-Item $outputFile -ItemType file -Force;

$conn = New-Object System.Data.SqlClient.SqlConnection($connectionString);

Add-Content $("Searching '$searchLocation' and '$($conn.DataSource)\$($conn.Database)'.") -Path $outputFile;
Add-Content $nl -Path $outputFile;

$dbObjects = .\GetDbObjectNames.ps1 $connectionString;

$excludedFileTypes = "*.sql", "*.dbmdl", "*.sqlproj";

foreach ($obj in $dbObjects) {
	Add-Content $("------------ $obj") -Path $outputFile;
	Add-Content $nl -Path $outputFile;
	
	Add-Content "File references:" -Path $outputFile;
	Add-Content $(.\FindReferencesInFiles.ps1 $searchLocation $obj $excludedFileTypes) -Path $outputFile;
	Add-Content $nl -Path $outputFile;
	
	Add-Content "Database references:" -Path $outputFile;
	Add-Content $(.\CheckForDbReferences.ps1 $connectionString $obj) -Path $outputFile;
	
	Add-Content $nl -Path $outputFile;
	Add-Content $nl -Path $outputFile;
}