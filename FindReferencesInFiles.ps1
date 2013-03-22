param
(
	[string]$searchLocation = $(throw "searchLocation is empty. Please specify where you want to search."),
	[string]$searchString = $(throw "searchString is empty. Please specify what you want to search for."),
	[string[]]$excludedFileTypes = @("")
)

return (Get-ChildItem -Path $searchLocation -Recurse | Select-String -Pattern $searchString -SimpleMatch -Exclude $excludedFileTypes | Select-Object -Unique -ExpandProperty Path )