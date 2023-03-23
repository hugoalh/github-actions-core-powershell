#Requires -PSEdition Core -Version 7.2
Import-Module -Name (
	@(
		'internal\new-random-token'
	) |
		ForEach-Object -Process { Join-Path -Path $PSScriptRoot -ChildPath "$_.psm1" }
) -Prefix 'GitHubActions' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Format StdOut Command Parameter Value
.DESCRIPTION
Format the stdout command parameter value characters that can cause issues.
.PARAMETER InputObject
String that need to format the stdout command parameter value characters.
.OUTPUTS
[String] A string that formatted the stdout command parameter value characters.
#>
Function Format-StdOutCommandParameterValue {
	[CmdletBinding()]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyString()][Alias('Input', 'Object')][String]$InputObject
	)
	Process {
		(Format-StdOutCommandValue -InputObject $InputObject) -ireplace ',', '%2C' -ireplace ':', '%3A' |
			Write-Output
	}
}
Set-Alias -Name 'Format-CommandParameterValue' -Value 'Format-StdOutCommandParameterValue' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Format-CommandPropertyValue' -Value 'Format-StdOutCommandParameterValue' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Format-StdOutCommandPropertyValue' -Value 'Format-StdOutCommandParameterValue' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Format StdOut Command Value
.DESCRIPTION
Format the stdout command value characters that can cause issues.
.PARAMETER InputObject
String that need to format the stdout command value characters.
.OUTPUTS
[String] A string that formatted the stdout command value characters.
#>
Function Format-StdOutCommandValue {
	[CmdletBinding()]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)][AllowEmptyString()][Alias('Input', 'Object')][String]$InputObject
	)
	Process {
		$InputObject -ireplace '%', '%25' -ireplace '\n', '%0A' -ireplace '\r', '%0D' |
			Write-Output
	}
}
Set-Alias -Name 'Format-CommandContent' -Value 'Format-StdOutCommandValue' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Format-CommandMessage' -Value 'Format-StdOutCommandValue' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Format-CommandValue' -Value 'Format-StdOutCommandValue' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Format-StdOutCommandContent' -Value 'Format-StdOutCommandValue' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Format-StdOutCommandMessage' -Value 'Format-StdOutCommandValue' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Write File Command
.DESCRIPTION
Write file command to communicate with the runner machine.
.PARAMETER FileCommand
File command. (LEGACY: Literal path of the file command.)
.PARAMETER Name
Name.
.PARAMETER Value
Value.
.OUTPUTS
[Void]
#>
Function Write-FileCommand {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_writegithubactionsfilecommand')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][Alias('Command', 'LiteralPath'<# LEGACY #>, 'Path'<# LEGACY #>)][String]$FileCommand,
		[Parameter(Mandatory = $True, Position = 1, ValueFromPipelineByPropertyName = $True)][String]$Name,
		[Parameter(Mandatory = $True, Position = 2, ValueFromPipelineByPropertyName = $True)][String]$Value
	)
	Process {
		If (<# LEGACY #>[System.IO.Path]::IsPathFullyQualified($FileCommand)) {
			[String]$FileCommandPath = $FileCommand
		}
		Else {
			Try {
				[String]$FileCommandPath = Get-Content -LiteralPath "Env:\$([WildcardPattern]::Escape($FileCommand.ToUpper()))" -ErrorAction 'Stop'
			}
			Catch {
				Write-Error -Message "Unable to write the GitHub Actions file command: Environment path ``$($FileCommand.ToUpper())`` is not defined!" -Category 'ResourceUnavailable'
				Return
			}
			If (![System.IO.Path]::IsPathFullyQualified($FileCommandPath)) {
				Write-Error -Message "Unable to write the GitHub Actions file command: Environment path ``$($FileCommand.ToUpper())`` is not contain a valid file path!" -Category 'ResourceUnavailable'
				Return
			}
		}
		If ($Value -imatch '^.+$') {
			Add-Content -LiteralPath $FileCommandPath -Value "$Name=$Value" -Confirm:$False -Encoding 'UTF8NoBOM'
		}
		Else {
			[String]$ItemRaw = "$Name=$Value" -ireplace '\r?\n', ''
			Do {
				[String]$Token = New-GitHubActionsRandomToken
			}
			While ($ItemRaw -imatch [RegEx]::Escape($Token))
			@(
				"$Name<<$Token",
				($Value -ireplace '\r?\n', "`n"),
				$Token
			) |
				Add-Content -LiteralPath $FileCommandPath -Confirm:$False -Encoding 'UTF8NoBOM'
		}
	}
}
<#
.SYNOPSIS
GitHub Actions - Write StdOut Command
.DESCRIPTION
Write stdout command to communicate with the runner machine.
.PARAMETER StdOutCommand
Stdout command.
.PARAMETER Parameter
Parameters of the stdout command.
.PARAMETER Value
Value of the stdout command.
.OUTPUTS
[Void]
#>
Function Write-StdOutCommand {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh-studio/ghactions-toolkit-powershell/wiki/api_function_writegithubactionsstdoutcommand')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^(?:[\da-z][\da-z_-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions stdout command!')][Alias('Command')][String]$StdOutCommand,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Parameters', 'Properties', 'Property')][Hashtable]$Parameter,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Alias('Content', 'Message')][String]$Value
	)
	Process {
		Write-Host -Object "::$StdOutCommand$(($Parameter.Count -igt 0) ? " $(
			$Parameter.GetEnumerator() |
				Sort-Object -Property 'Name' |
				ForEach-Object -Process { "$($_.Name)=$(Format-StdOutCommandParameterValue -InputObject $_.Value)" } |
				Join-String -Separator ','
		)" : '')::$(Format-StdOutCommandValue -InputObject $Value)"
	}
}
Set-Alias -Name 'Write-Command' -Value 'Write-StdOutCommand' -Option 'ReadOnly' -Scope 'Local'
Export-ModuleMember -Function @(
	'Write-FileCommand',
	'Write-StdOutCommand'
) -Alias @(
	'Write-Command'
)
