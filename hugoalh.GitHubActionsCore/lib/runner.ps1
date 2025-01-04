#Requires -PSEdition Core -Version 7.2
[System.String[]]$RunnerArchitectures = @(
	'ARM',
	'ARM64',
	'X64',
	'X86'
)
<#
.DESCRIPTION
	Get the architecture of the GitHub Actions runner.
.OUTPUTS
	[System.String] Architecture of the GitHub Actions runner.
#>
Function Get-RunnerArchitecture {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_getrunnerarchitecture')]
	[OutputType([System.String])]
	Param ()
	If ($Null -eq $Env:RUNNER_ARCH) {
		$PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new([System.Exception]::new("Unable to get the GitHub Actions runner architecture, environment variable ``RUNNER_ARCH`` is not defined!"), 'GitHubActionsCore.ReferenceError', [System.Management.Automation.ErrorCategory]::InvalidResult, $Env:RUNNER_ARCH))
	}
	If ($Env:RUNNER_ARCH -notin $RunnerArchitectures) {
		$PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new([System.Exception]::new("``$($Env:RUNNER_ARCH)`` (environment variable ``RUNNER_ARCH``) is not a known GitHub Actions runner architecture!"), 'GitHubActionsCore.ReferenceError', [System.Management.Automation.ErrorCategory]::InvalidResult, $Env:RUNNER_ARCH))
	}
	Return $Env:RUNNER_ARCH
}
Set-Alias -Name 'Get-RunnerArch' -Value 'Get-RunnerArchitecture' -Option 'ReadOnly' -Scope 'Local'
<#
.DESCRIPTION
	Get the debug status of the GitHub Actions runner.
.OUTPUTS
	[System.Boolean] Debug status of the GitHub Actions runner.
#>
Function Get-RunnerDebugStatus {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_getrunnerdebugstatus')]
	[OutputType([System.Boolean])]
	Param ()
	Return ($Env:RUNNER_DEBUG -eq '1')
}
<#
.DESCRIPTION
	Get the name of the GitHub Actions runner.
.OUTPUTS
	[System.String] Name of the GitHub Actions runner.
#>
Function Get-RunnerName {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_getrunnername')]
	[OutputType([System.String])]
	Param ()
	If ($Null -eq $Env:RUNNER_NAME) {
		$PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new([System.Exception]::new("Unable to get the GitHub Actions runner name, environment variable ``RUNNER_NAME`` is not defined!"), 'GitHubActionsCore.ReferenceError', [System.Management.Automation.ErrorCategory]::InvalidResult, $Env:RUNNER_NAME))
	}
	Return $Env:RUNNER_NAME
}
[System.String[]]$RunnerOSes = @(
	'Linux',
	'macOS',
	'Windows'
)
<#
.DESCRIPTION
	Get the OS of the GitHub Actions runner.
.OUTPUTS
	[System.String] OS of the GitHub Actions runner.
#>
Function Get-RunnerOS {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_getrunneros')]
	[OutputType([System.String])]
	Param ()
	If ($Null -eq $Env:RUNNER_OS) {
		$PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new([System.Exception]::new("Unable to get the GitHub Actions runner OS, environment variable ``RUNNER_OS`` is not defined!"), 'GitHubActionsCore.ReferenceError', [System.Management.Automation.ErrorCategory]::InvalidResult, $Env:RUNNER_OS))
	}
	If ($Env:RUNNER_OS -notin $RunnerOSes) {
		$PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new([System.Exception]::new("``$($Env:RUNNER_OS)`` (environment variable ``RUNNER_OS``) is not a known GitHub Actions runner OS!"), 'GitHubActionsCore.ReferenceError', [System.Management.Automation.ErrorCategory]::InvalidResult, $Env:RUNNER_OS))
	}
	Return $Env:RUNNER_OS
}
<#
.DESCRIPTION
	Get the absolute path of the `TEMP` directory of the GitHub Actions runner.
	
	`TEMP` directory is emptied at the beginning and end of each job, files will not be removed if the runner's user account does not have permission to delete them.
.OUTPUTS
	[System.String] Absolute path of the `TEMP` directory of the GitHub Actions runner.
#>
Function Get-RunnerTempPath {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_getrunnertemppath')]
	[OutputType([System.String])]
	Param ()
	If ($Null -eq $Env:RUNNER_TEMP) {
		$PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new([System.Exception]::new("Unable to get the GitHub Actions runner TEMP path, environment variable ``RUNNER_TEMP`` is not defined!"), 'GitHubActionsCore.ReferenceError', [System.Management.Automation.ErrorCategory]::InvalidResult, $Env:RUNNER_TEMP))
	}
	If (!(Test-Path $Env:RUNNER_TEMP -PathType 'Container')) {
		$PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new([System.Exception]::new("``$($Env:RUNNER_TEMP)`` (environment variable ``RUNNER_TEMP``) is not a valid absolute path!"), 'GitHubActionsCore.ReferenceError', [System.Management.Automation.ErrorCategory]::InvalidResult, $Env:RUNNER_TEMP))
	}
	Return $Env:RUNNER_TEMP
}
<#
.DESCRIPTION
	Get the absolute path of the tool cache directory of the GitHub hosted GitHub Actions runner.
	
	For self hosted GitHub Actions runner, the tool cache directory may not exist and will return `$Null`.
.OUTPUTS
	[System.String] Absolute path of the tool cache directory of the GitHub hosted GitHub Actions runner.
	[System.Null]
#>
Function Get-RunnerToolCachePath {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_getrunnertoolcachepath')]
	[OutputType([System.String])]
	Param ()
	If ($Null -ne $Env:RUNNER_TOOL_CACHE -and !(Test-Path $Env:RUNNER_TOOL_CACHE -PathType 'Container')) {
		$PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new([System.Exception]::new("``$($Env:RUNNER_TOOL_CACHE)`` (environment variable ``RUNNER_TOOL_CACHE``) is not a valid absolute path!"), 'GitHubActionsCore.ReferenceError', [System.Management.Automation.ErrorCategory]::InvalidResult, $Env:RUNNER_TOOL_CACHE))
	}
	Return $Env:RUNNER_TOOL_CACHE
}
<#
.DESCRIPTION
	Get the absolute path of the workspace of the GitHub Actions runner; The default working directory on the runner for steps.
.OUTPUTS
	[System.String] Absolute path of the workspace of the GitHub Actions runner.
#>
Function Get-RunnerWorkspacePath {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_getrunnerworkspacepath')]
	[OutputType([System.String])]
	Param ()
	If ($Null -eq $Env:GITHUB_WORKSPACE) {
		$PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new([System.Exception]::new("Unable to get the GitHub Actions runner workspace path, environment variable ``GITHUB_WORKSPACE`` is not defined!"), 'GitHubActionsCore.ReferenceError', [System.Management.Automation.ErrorCategory]::InvalidResult, $Env:GITHUB_WORKSPACE))
	}
	If (!(Test-Path $Env:GITHUB_WORKSPACE -PathType 'Container')) {
		$PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new([System.Exception]::new("``$($Env:GITHUB_WORKSPACE)`` (environment variable ``GITHUB_WORKSPACE``) is not a valid absolute path!"), 'GitHubActionsCore.ReferenceError', [System.Management.Automation.ErrorCategory]::InvalidResult, $Env:GITHUB_WORKSPACE))
	}
	Return $Env:GITHUB_WORKSPACE
}
[PSCustomObject[]]$RunnerEnvsDefault = @(
	[PSCustomObject]@{ Key = 'CI'; Value = 'true' },
	[PSCustomObject]@{ Key = 'GITHUB_ACTION' },
	[PSCustomObject]@{ Key = 'GITHUB_ACTIONS'; Value = 'true' },
	[PSCustomObject]@{ Key = 'GITHUB_ACTOR' },
	[PSCustomObject]@{ Key = 'GITHUB_ACTOR_ID' },
	[PSCustomObject]@{ Key = 'GITHUB_API_URL' },
	[PSCustomObject]@{ Key = 'GITHUB_ENV' },
	[PSCustomObject]@{ Key = 'GITHUB_EVENT_NAME' },
	[PSCustomObject]@{ Key = 'GITHUB_EVENT_PATH' },
	[PSCustomObject]@{ Key = 'GITHUB_GRAPHQL_URL' },
	[PSCustomObject]@{ Key = 'GITHUB_JOB' },
	[PSCustomObject]@{ Key = 'GITHUB_OUTPUT' },
	[PSCustomObject]@{ Key = 'GITHUB_PATH' },
	[PSCustomObject]@{ Key = 'GITHUB_REF_NAME' },
	[PSCustomObject]@{ Key = 'GITHUB_REF_TYPE' },
	[PSCustomObject]@{ Key = 'GITHUB_REPOSITORY' },
	[PSCustomObject]@{ Key = 'GITHUB_REPOSITORY_ID' },
	[PSCustomObject]@{ Key = 'GITHUB_REPOSITORY_OWNER' },
	[PSCustomObject]@{ Key = 'GITHUB_REPOSITORY_OWNER_ID' },
	[PSCustomObject]@{ Key = 'GITHUB_RETENTION_DAYS' },
	[PSCustomObject]@{ Key = 'GITHUB_RUN_ATTEMPT' },
	[PSCustomObject]@{ Key = 'GITHUB_RUN_ID' },
	[PSCustomObject]@{ Key = 'GITHUB_RUN_NUMBER' },
	[PSCustomObject]@{ Key = 'GITHUB_SERVER_URL' },
	[PSCustomObject]@{ Key = 'GITHUB_SHA' },
	[PSCustomObject]@{ Key = 'GITHUB_STATE' },
	[PSCustomObject]@{ Key = 'GITHUB_STEP_SUMMARY' },
	[PSCustomObject]@{ Key = 'GITHUB_WORKFLOW' },
	[PSCustomObject]@{ Key = 'GITHUB_WORKFLOW_REF' },
	[PSCustomObject]@{ Key = 'GITHUB_WORKFLOW_SHA' },
	[PSCustomObject]@{ Key = 'GITHUB_WORKSPACE' },
	[PSCustomObject]@{ Key = 'RUNNER_ARCH' },
	[PSCustomObject]@{ Key = 'RUNNER_NAME' },
	[PSCustomObject]@{ Key = 'RUNNER_OS' },
	[PSCustomObject]@{ Key = 'RUNNER_TEMP' }
)
<#
.DESCRIPTION
	Test the current process whether is executing inside the GitHub Actions runner.
.PARAMETER Artifact
	Also test whether have artifact resources.
.PARAMETER Cache
	Also test whether have cache resources.
.PARAMETER Oidc
	Also test whether have OpenID Connect (OIDC) resources.
.PARAMETER ToolCache
	Also test whether have tool cache resources.
.PARAMETER Mandatory
	Whether the test is mandatory.
#>
Function Test-InRunner {
	[CmdletBinding(DefaultParameterSetName = 'Optional', HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_testinrunner')]
	[OutputType([System.Boolean])]
	Param (
		[Switch]$Artifact,
		[Switch]$Cache,
		[Switch]$Oidc,
		[Switch]$ToolCache,
		[Parameter(Mandatory = $True, ParameterSetName = 'Mandatory')][Switch]$Mandatory
	)
	[PSCustomObject[]]$RunnerEnvs = $RunnerEnvsDefault + @(
		[PSCustomObject]@{ Key = 'ACTIONS_RESULTS_URL'; Need = $Artifact },
		[PSCustomObject]@{ Key = 'ACTIONS_RUNTIME_TOKEN'; Need = $Artifact -or $Cache },
		[PSCustomObject]@{ Key = 'ACTIONS_RUNTIME_URL'; Need = $Artifact },
		[PSCustomObject]@{ Key = 'ACTIONS_CACHE_URL'; Need = $Cache },
		[PSCustomObject]@{ Key = 'ACTIONS_ID_TOKEN_REQUEST_TOKEN'; Need = $Oidc },
		[PSCustomObject]@{ Key = 'ACTIONS_ID_TOKEN_REQUEST_URL'; Need = $Oidc },
		[PSCustomObject]@{ Key = 'RUNNER_TOOL_CACHE'; Need = $ToolCache }
	)
	[System.Boolean]$Failed = $False
	ForEach ($RunnerEnv In (
			$RunnerEnvs |
				Where-Object -FilterScript { Return ($_.Need ?? $True) }
		)) {
		$ValueCurrent = Get-Content -Path "Env:\$($RunnerEnv.Key)" -ErrorAction 'SilentlyContinue'
		If (
			$Null -eq $ValueCurrent -or
			($Null -ne $RunnerEnv.Value -and $ValueCurrent -ne $RunnerEnv.Value)
		) {
			$PSCmdlet.WriteWarning("Unable to get the GitHub Actions resources, environment variable ``$($RunnerEnv.Key)`` is not defined, or not contain an expected value!")
			$Failed = $True
		}
	}
	If ($Mandatory -and $Failed) {
		$PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new([System.Exception]::new('This process requires to invoke inside the GitHub Actions environment!'), 'GitHubActionsCore.ResourceUnavailable', [System.Management.Automation.ErrorCategory]::ResourceUnavailable))
	}
	Return !$Failed
}
<#
.DESCRIPTION
	Clear the `TEMP` directory of the GitHub Actions runner.
.OUTPUTS
	[System.Void]
#>
Function Clear-RunnerTemp {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_clearrunnertemp')]
	[OutputType([System.Void])]
	Param ()
	[System.String]$Path = Get-RunnerTempPath
	Get-ChildItem -LiteralPath $Path |
		ForEach-Object -Process {
			Remove-Item -Path $_.FullName -Recurse -Force
		}
}
Export-ModuleMember -Function @(
	'Clear-RunnerTemp',
	'Get-RunnerArchitecture',
	'Get-RunnerDebugStatus',
	'Get-RunnerName',
	'Get-RunnerOS',
	'Get-RunnerTempPath',
	'Get-RunnerToolCachePath',
	'Get-RunnerWorkspacePath',
	'Test-InRunner'
) -Alias @(
	'Get-RunnerArch'
)
