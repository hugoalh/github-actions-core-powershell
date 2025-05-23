#Requires -PSEdition Core -Version 7.2
<#
This script is help for copy members to the data file for best performance, and use for debug.
#>
$ErrorActionPreference = 'Stop'
[System.String]$PackageName = 'hugoalh.GitHubActionsCore'
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath "$PackageName\$PackageName.psm1")
) -Scope 'Local'
[PSCustomObject[]]$PackageCommands = Get-Command -Module $PackageName -ListImported
ForEach ($CommandType In @('Function', 'Alias')) {
	$PackageCommands |
		Where-Object -FilterScript { $_.CommandType -ieq $CommandType } |
		Select-Object -ExpandProperty 'Name' |
		Sort-Object |
		Join-String -Separator ",`n" -SingleQuote |
		Set-Clipboard -Confirm
}
