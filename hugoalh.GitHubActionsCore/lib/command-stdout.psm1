#Requires -PSEdition Core -Version 7.2
[System.String[]]$CommandsStdOutCurrent = @(
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
[System.String[]]$CommandsStdOutForbid = @(
	'add-path',
	'save-state',
	'set-env',
	'set-output'
)
[RegEx]$RegExCommandStdout = '^(?:[\da-z][\da-z._-]*)?[\da-z]$'
<#
.DESCRIPTION
	Escape GitHub Actions runner stdout command value.
.OUTPUTS
	[System.String]
.NOTES
	Only use internally.
#>
Function Format-StdOutCommandValue {
	[OutputType([System.String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][AllowEmptyString()][AllowNull()][System.String]$InputObject
	)
	Return ($InputObject -ireplace '%', '%25' -ireplace '\n', '%0A' -ireplace '\r', '%0D')
}
<#
.DESCRIPTION
	Escape GitHub Actions runner stdout command property value.
.OUTPUTS
	[System.String]
.NOTES
	Only use internally.
#>
Function Format-StdOutCommandPropertyValue {
	[OutputType([System.String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][AllowEmptyString()][AllowNull()][System.String]$InputObject
	)
	Return ((Format-StdOutCommandValue -InputObject $InputObject) -ireplace ',', '%2C' -ireplace ':', '%3A')
}
<#
.DESCRIPTION
	Create new stdout command to communicate with the GitHub Actions runner.
.PARAMETER Command
	StdOut command.
.PARAMETER Properties
	Properties of the stdout command.
.PARAMETER Message
	Message of the stdout command.
.OUTPUTS
	[System.String]
.NOTES
	Advanced.
#>
Function New-StdOutCommand {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_newstdoutcommand')]
	[OutputType([System.String])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][System.String]$Command,
		[ValidateScript({ $_ -is [Hashtable] -or $_ -is [Ordered] -or $_ -is [PSCustomObject] }, ErrorMessage = 'Value is not a Hashtable, PSCustomObject, or OrderedDictionary')]$Properties = @{},
		[AllowEmptyString()][AllowNull()][System.String]$Message
	)
	If (!(
		$CommandsStdOutCurrent -ccontains $Command -or
		$Command -cmatch $RegExCommandStdout
	)) {
		$PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new([System.Exception]::new("``$Command`` is not a valid GitHub Actions stdout command!"), 'GitHubActionsCore.SyntaxError', [System.Management.Automation.ErrorCategory]::InvalidArgument, $Command))
	}
	if ($CommandsStdOutForbid -ccontains $Command) {
		$PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new([System.Exception]::new("``$Command`` is a forbidden GitHub Actions stdout command!"), 'GitHubActionsCore.Error', [System.Management.Automation.ErrorCategory]::InvalidArgument, $Command))
	}
	$PropertiesFmt=([PSCustomObject]$Properties).PSObject.Properties
	Return "::$Command$(($PropertiesFmt.Count -gt 0) ? ' ' : '')$(
		$PropertiesFmt |
			ForEach-Object -Process { "$($_.Name)=$(Format-StdOutCommandPropertyValue -InputObject $_.Value ?? '')" } |
			Join-String -Separator ','
	)::$(Format-StdOutCommandValue -InputObject ($Message ?? ''))"
}
<#
.DESCRIPTION
	Write stdout command to communicate with the GitHub Actions runner.
.PARAMETER Command
	StdOut command.
.PARAMETER Properties
	Properties of the stdout command.
.PARAMETER Message
	Message of the stdout command.
.OUTPUTS
	[System.Void]
.NOTES
	Advanced.
#>
Function Write-StdOutCommand {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_writestdoutcommand')]
	[OutputType([System.Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][System.String]$Command,
		[ValidateScript({ $_ -is [Hashtable] -or $_ -is [Ordered] -or $_ -is [PSCustomObject] }, ErrorMessage = 'Value is not a Hashtable, PSCustomObject, or OrderedDictionary')]$Properties = @{},
		[AllowEmptyString()][AllowNull()][System.String]$Message
	)
	Write-Host -Object (New-StdOutCommand -Command $Command -Properties $Properties -Message $Message)
}
[System.String]$CommandEchoDisable = New-StdOutCommand -Command 'echo' -Message 'off'
<#
.DESCRIPTION
	Disable echo most of the stdout commands, the log will not print the stdout command itself unless there has any issue.
	
	Environment variable `ACTIONS_STEP_DEBUG` will ignore this setting.
.OUTPUTS
	[System.Void]
#>
Function Disable-StdOutCommandEcho {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_disablestdoutcommandecho')]
	[OutputType([System.Void])]
	Param ()
	Write-Host -Object $CommandEchoDisable
}
Set-Alias -Name 'Stop-StdOutCommandEcho' -Value 'Disable-StdOutCommandEcho' -Option 'ReadOnly' -Scope 'Local'
[System.String]$CommandEchoEnable = New-StdOutCommand -Command 'echo' -Message 'on'
<#
.DESCRIPTION
	Enable echo most of the stdout commands, the log will print the stdout command itself.
	
	Environment variable `ACTIONS_STEP_DEBUG` will ignore this setting.
.OUTPUTS
	[System.Void]
#>
Function Enable-StdOutCommandEcho {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_enablestdoutcommandecho')]
	[OutputType([System.Void])]
	Param ()
	Write-Host -Object $CommandEchoEnable
}
Set-Alias -Name 'Start-StdOutCommandEcho' -Value 'Enable-StdOutCommandEcho' -Option 'ReadOnly' -Scope 'Local'
<#
.DESCRIPTION
	Test the item is a valid GitHub Actions stdout command end token.
.OUTPUTS
	[System.Boolean]
.NOTES
	Only use internally.
#>
Function Test-StdOutCommandEndToken {
	[OutputType([System.Boolean])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][System.String]$InputObject
	)
	Return ($CommandsStdOutCurrent -cnotcontains $InputObject -and $CommandsStdOutForbid -cnotcontains $InputObject -and $InputObject -cmatch $RegExCommandStdout -and $InputObject.Length -ge 4)
}
<#
.DESCRIPTION
	Disable process all of the stdout commands, to allow log anything without accidentally execute any stdout command.
.PARAMETER EndToken
	An end token for re-enable stdout command process.
.OUTPUTS
	[System.String]
#>
Function Disable-StdOutCommandProcess {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_disablestdoutcommandprocess')]
	[OutputType([System.String])]
	Param (
		[Parameter(Position = 0)][ValidateScript({ Test-StdOutCommandEndToken -InputObject $_ }, ErrorMessage = 'Value is not a string which is single line, more than or equal to 4 characters, and not match any GitHub Actions commands!')][System.String]$EndToken
	)
	If ($EndToken.Length -eq 0) {
		$EndToken = (New-Guid).Guid.ToLower() -ireplace '-', ''
	}
	Write-Host -Object (New-StdOutCommand -Command 'stop-commands' -Message $EndToken)
	Return $EndToken
}
Set-Alias -Name 'Stop-StdOutCommandProcess' -Value 'Disable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Suspend-StdOutCommandProcess' -Value 'Disable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
<#
.DESCRIPTION
	Enable process all of the stdout commands, to allow execute any stdout command.
.PARAMETER EndToken
	An end token from disable stdout command process.
.OUTPUTS
	[System.Void]
#>
Function Enable-StdOutCommandProcess {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_enablestdoutcommandprocess')]
	[OutputType([System.Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][ValidateScript({ Test-StdOutCommandEndToken -InputObject $_ }, ErrorMessage = 'Value is not a string which is single line, more than or equal to 4 characters, and not match any GitHub Actions commands!')][System.String]$EndToken
	)
	Write-Host -Object (New-StdOutCommand -Command $EndToken)
}
Set-Alias -Name 'Resume-StdOutCommandProcess' -Value 'Enable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
Set-Alias -Name 'Start-StdOutCommandProcess' -Value 'Enable-StdOutCommandProcess' -Option 'ReadOnly' -Scope 'Local'
Export-ModuleMember -Function @(
	'Disable-StdOutCommandEcho',
	'Disable-StdOutCommandProcess',
	'Enable-StdOutCommandEcho',
	'Enable-StdOutCommandProcess',
	'New-StdOutCommand',
	'Write-StdOutCommand'
) -Alias @(
	'Resume-StdOutCommandProcess',
	'Start-StdOutCommandEcho',
	'Start-StdOutCommandProcess',
	'Stop-StdOutCommandEcho',
	'Stop-StdOutCommandProcess',
	'Suspend-StdOutCommandProcess'
)
