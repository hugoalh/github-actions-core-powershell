#Requires -PSEdition Core -Version 7.2
[String[]]$CommandsStdOutCurrent = @(
	'add-mask',
	'add-matcher',
	'debug',
	'echo',
	'endgroup',
	'error',
	'group',
	'notice',
	'remove-matcher',
	'stop-commands',
	'warning'
)
[String[]]$CommandsStdOutForbid = @(
	'add-path',
	'save-state',
	'set-env',
	'set-output'
)
<#
.SYNOPSIS
	Escape GitHub Actions runner stdout command value.
.NOTES
	Use internal only.
#>
Function Format-StdOutCommandValue {
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][AllowEmptyString()][AllowNull()][String]$InputObject
	)
	Return ($InputObject -ireplace '%', '%25' -ireplace '\n', '%0A' -ireplace '\r', '%0D')
}
<#
.SYNOPSIS
	Escape GitHub Actions runner stdout command property value.
.NOTES
	Use internal only.
#>
Function Format-StdOutCommandPropertyValue {
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][AllowEmptyString()][AllowNull()][String]$InputObject
	)
	Return ((Format-StdOutCommandValue -InputObject $InputObject) -ireplace ',', '%2C' -ireplace ':', '%3A')
}
<#
.SYNOPSIS
	Format stdout command to communicate with the GitHub Actions runner.
.PARAMETER StdOutCommand
	StdOut command.
.PARAMETER Parameter
	Parameters of the stdout command.
.PARAMETER Value
	Value of the stdout command.
.NOTES
	Advanced.
#>
Function Format-StdOutCommand {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_formatstdoutcommand')]
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)][ValidatePattern('^(?:[\da-z][\da-z._-]*)?[\da-z]$', ErrorMessage = '`{0}` is not a valid GitHub Actions stdout command!')][String]$Command,
		[Parameter(ValueFromPipelineByPropertyName = $True)][ValidateScript({ $_ -is [Hashtable] -or $_ -is [PSCustomObject] -or $_ -is [Ordered] }, ErrorMessage = 'Value is not a Hashtable, PSCustomObject, or OrderedDictionary')]$Properties = @{},
		[Parameter(ValueFromPipelineByPropertyName = $True)][AllowEmptyString()][AllowNull()][String]$Message
	)
	Process {
		[String[]]$PropertiesName = ([PSCustomObject]$Properties).PSObject.Properties.Name
		Return "::$Command$(($PropertiesName.Count -gt 0) ? " $(
			$PropertiesName |
				ForEach-Object -Process { "$_=$(Format-StdOutCommandPropertyValue ($Properties.($_) ?? ''))" } |
				Join-String -Separator ','
		)" : '')::$(Format-StdOutCommandValue ($Message ?? ''))"
	}
}




















<#
.SYNOPSIS
Disable StdOut Command Echo
.DESCRIPTION
Disable echo most of the stdout commands, the log will not show the stdout command itself unless there has any issues; Environment variable `ACTIONS_STEP_DEBUG` will ignore this setting.
.OUTPUTS
[Void]
#>
Function Disable-StdOutCommandEcho {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_disablestdoutcommandecho')]
	[OutputType([Void])]
	Param ()
	Write-StdOutCommand -StdOutCommand 'echo' -Value 'off'
}
Set-Alias -Name 'Disable-CommandEcho' -Value 'Disable-StdOutCommandEcho' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-CommandEcho' -Value 'Disable-StdOutCommandEcho' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-StdOutCommandEcho' -Value 'Disable-StdOutCommandEcho' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Disable StdOut Command Process
.DESCRIPTION
Disable process all of the stdout commands, to allow log anything without accidentally execute any stdout command.
.PARAMETER EndToken
An end token for re-enable stdout command process.
.OUTPUTS
[String] An end token for re-enable stdout command process.
#>
Function Disable-StdOutCommandProcess {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_disablestdoutcommandprocess')]
	[OutputType([String])]
	Param (
		[Parameter(Position = 0)][ValidateScript({ Test-StdOutCommandEndToken -InputObject $_ }, ErrorMessage = 'Value is not a single line string, more than or equal to 4 characters, and not match any GitHub Actions commands!')][Alias('EndKey', 'EndValue', 'Key', 'Token', 'Value')][String]$EndToken
	)
	If ($EndToken.Length -eq 0) {
		$EndToken = (New-Guid).Guid.ToLower() -ireplace '-', ''
	}
	Write-StdOutCommand -StdOutCommand 'stop-commands' -Value $EndToken
	Write-Output -InputObject $EndToken
}
Set-Alias -Name 'Disable-CommandProcess' -Value 'Disable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-CommandProcess' -Value 'Disable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Stop-StdOutCommandProcess' -Value 'Disable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Suspend-CommandProcess' -Value 'Disable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Suspend-StdOutCommandProcess' -Value 'Disable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Enable StdOut Command Echo
.DESCRIPTION
Enable echo most of the stdout commands, the log will show the stdout command itself; Environment variable `ACTIONS_STEP_DEBUG` will ignore this setting.
.OUTPUTS
[Void]
#>
Function Enable-StdOutCommandEcho {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_enablestdoutcommandecho')]
	[OutputType([Void])]
	Param ()
	Write-StdOutCommand -StdOutCommand 'echo' -Value 'on'
}
Set-Alias -Name 'Enable-CommandEcho' -Value 'Enable-StdOutCommandEcho' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-CommandEcho' -Value 'Enable-StdOutCommandEcho' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-StdOutCommandEcho' -Value 'Enable-StdOutCommandEcho' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Enable StdOut Command Process
.DESCRIPTION
Enable process all of the stdout commands, to allow execute any stdout command.
.PARAMETER EndToken
An end token from disable stdout command process.
.OUTPUTS
[Void]
#>
Function Enable-StdOutCommandProcess {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_enablestdoutcommandprocess')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][ValidateScript({ Test-StdOutCommandEndToken -InputObject $_ }, ErrorMessage = 'Value is not a single line string, more than or equal to 4 characters, and not match any GitHub Actions commands!')][Alias('EndKey', 'EndValue', 'Key', 'Token', 'Value')][String]$EndToken
	)
	Write-StdOutCommand -StdOutCommand $EndToken
}
Set-Alias -Name 'Enable-CommandProcess' -Value 'Enable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Resume-CommandProcess' -Value 'Enable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Resume-StdOutCommandProcess' -Value 'Enable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-CommandProcess' -Value 'Enable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-StdOutCommandProcess' -Value 'Enable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Internal - Format StdOut Command Value
.DESCRIPTION
Format GitHub Actions stdout command value.
.PARAMETER InputObject
Value.
.OUTPUTS
[String] A formatted GitHub Actions stdout command value.
#>
Function Format-StdOutCommandValue {
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][AllowEmptyString()][AllowNull()][Alias('Input', 'Object', 'Value')][String]$InputObject
	)
	Return ($InputObject -ireplace '%', '%25' -ireplace '\n', '%0A' -ireplace '\r', '%0D')
}
<#
.SYNOPSIS
GitHub Actions - Internal - Format StdOut Command Parameter Value
.DESCRIPTION
Format GitHub Actions stdout command parameter value.
.PARAMETER InputObject
Value.
.OUTPUTS
[String] A formatted GitHub Actions stdout command parameter value.
#>
Function Format-StdOutCommandParameterValue {
	[OutputType([String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][AllowEmptyString()][AllowNull()][Alias('Input', 'Object', 'Value')][String]$InputObject
	)
	Return ((Format-StdOutCommandValue -InputObject $InputObject) -ireplace ',', '%2C' -ireplace ':', '%3A')
}
<#
.SYNOPSIS
GitHub Actions - Internal - Test StdOut Command End Token
.DESCRIPTION
Test whether is a valid GitHub Actions stdout command end token.
.PARAMETER InputObject
GitHub Actions stdout command end token that need to test.
.OUTPUTS
[Boolean] Test result.
#>
Function Test-StdOutCommandEndToken {
	[OutputType([Boolean])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('EndKey', 'EndValue', 'Input', 'Key', 'Object', 'Token', 'Value')][String]$InputObject
	)
	Return ($InputObject -imatch '^(?:[\da-z][\da-z_-]*)?[\da-z]$' -and $InputObject.Length -ge 4 -and $InputObject -inotin $StdOutCommandsType)
}

Set-Alias -Name 'Write-Command' -Value 'Write-StdOutCommand' -Option 'ReadOnly' -Scope 'Local'
Export-ModuleMember -Function @(
	'Disable-StdOutCommandEcho',
	'Disable-StdOutCommandProcess',
	'Enable-StdOutCommandEcho',
	'Enable-StdOutCommandProcess',
	'Write-StdOutCommand'
) -Alias @(
	'Disable-CommandEcho',
	'Disable-CommandProcess',
	'Enable-CommandEcho',
	'Enable-CommandProcess',
	'Resume-CommandProcess',
	'Resume-StdOutCommandProcess',
	'Start-CommandEcho',
	'Start-CommandProcess',
	'Start-StdOutCommandEcho',
	'Start-StdOutCommandProcess',
	'Stop-CommandEcho',
	'Stop-CommandProcess',
	'Stop-StdOutCommandEcho',
	'Stop-StdOutCommandProcess',
	'Suspend-CommandProcess',
	'Suspend-StdOutCommandProcess',
	'Write-Command'
)
