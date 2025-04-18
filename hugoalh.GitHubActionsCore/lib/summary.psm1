#Requires -PSEdition Core -Version 7.2
Import-Module -Name @(
	(Join-Path -Path $PSScriptRoot -ChildPath 'command-file.psm1')
) -Prefix 'GitHubActions' -Scope 'Local'
#>
<#
.SYNOPSIS
GitHub Actions - Add Summary (Raw)
.DESCRIPTION
Add some GitHub flavored Markdown for the current step to display on the summary page of a run.

Can use to display and group unique content, such as test result summaries, so that viewing the result of a run does not need to go into the logs to see important information related to the run, such as failures.

When a run's job finished, the summaries for all steps in a job are grouped together into a single job summary and are shown on the run summary page. If multiple jobs generate summaries, the job summaries are ordered by job completion time.
.PARAMETER Value
Contents of the summary.
.PARAMETER NoNewLine
Whether to not add a new line or carriage return to the content; The string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
[Void]
#>
Function Add-Summary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_addsummary')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][AllowEmptyCollection()][AllowEmptyString()][AllowNull()][Alias('Content')][Object[]]$Value,
		[Parameter(ValueFromPipelineByPropertyName = $True)][Switch]$NoNewLine
	)
	Begin {
		[Boolean]$ShouldProceed = $True
		Try {
			Test-SummaryPath
		}
		Catch {
			$ShouldProceed = $False
			Write-Error -Message "Unable to write the GitHub Actions summary: $_" -Category 'ResourceUnavailable'
		}
	}
	Process {
		If (!$ShouldProceed) {
			Return
		}
		If ($Value.Count -gt 0) {
			Add-Content -LiteralPath $Env:GITHUB_STEP_SUMMARY -Value $Value -Confirm:$False -NoNewline:($NoNewLine.IsPresent) -Encoding 'UTF8NoBOM'
		}
	}
}
Set-Alias -Name 'Add-SummaryRaw' -Value 'Add-Summary' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Summary Header
.DESCRIPTION
Add header for the current step to display on the summary page of a run.
.PARAMETER Level
Level of the header.
.PARAMETER Header
Title of the header.
.OUTPUTS
[Void]
#>
Function Add-SummaryHeader {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_addsummaryheader')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][ValidateRange(1, 6)][Byte]$Level,
		[Parameter(Mandatory = $True, Position = 1)][ValidatePattern('^.+$', ErrorMessage = 'Value is not a single line string!')][Alias('Title', 'Value')][String]$Header
	)
	Add-Summary -Value "$('#' * $Level) $Header"
}
<#
.SYNOPSIS
GitHub Actions - Add Summary Image
.DESCRIPTION
Add image for the current step to display on the summary page of a run.

IMPORTANT: Not support reference image!
.PARAMETER Uri
URI of the image.
.PARAMETER Title
Title of the image.
.PARAMETER AlternativeText
Alternative text of the image.
.PARAMETER Width
Width of the image, by pixels (px).
.PARAMETER Height
Height of the image, by pixels (px).
.PARAMETER NoNewLine
Whether to not add a new line or carriage return to the content; The string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
[Void]
#>
Function Add-SummaryImage {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_addsummaryimage')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('Url')][String]$Uri,
		[AllowEmptyString()][AllowNull()][String]$Title,
		[AllowEmptyString()][AllowNull()][Alias('Alt', 'AltText')][String]$AlternativeText,
		[ValidateRange(0, [Int32]::MaxValue)][Int32]$Width = -1,
		[ValidateRange(0, [Int32]::MaxValue)][Int32]$Height = -1,
		[Switch]$NoNewLine
	)
	If (
		$Width -gt -1 -or
		$Height -gt -1
	) {
		[String]$ResultHtml = "<img src=`"$([Uri]::EscapeUriString($Uri))`""
		If ($Title.Length -gt 0) {
			$ResultHtml += " title=`"$([System.Web.HttpUtility]::HtmlAttributeEncode($Title))`""
		}
		If ($AlternativeText.Length -gt 0) {
			$ResultHtml += " alt=`"$([System.Web.HttpUtility]::HtmlAttributeEncode($AlternativeText))`""
		}
		If ($Width -gt -1) {
			$ResultHtml += " width=`"$Width`""
		}
		If ($Height -gt -1) {
			$ResultHtml += " height=`"$Height`""
		}
		$ResultHtml += ' />'
		Add-Summary -Value $ResultHtml -NoNewLine:($NoNewLine.IsPresent)
	}
	Else {
		[String]$ResultMarkdown = "![$([System.Web.HttpUtility]::HtmlAttributeEncode($AlternativeText))]($([Uri]::EscapeUriString($Uri))"
		If ($Title.Length -gt 0) {
			$ResultMarkdown += " `"$([System.Web.HttpUtility]::HtmlAttributeEncode($Title))`""
		}
		$ResultMarkdown += ')'
		Add-Summary -Value $ResultMarkdown -NoNewLine:($NoNewLine.IsPresent)
	}
}
Set-Alias -Name 'Add-SummaryPicture' -Value 'Add-SummaryImage' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Summary Link
.DESCRIPTION
Add link for the current step to display on the summary page of a run.

IMPORTANT: Not support reference link!
.PARAMETER Text
Text of the link.
.PARAMETER Uri
URI of the link.
.PARAMETER Title
Title of the link.
.PARAMETER NoNewLine
Whether to not add a new line or carriage return to the content; The string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
[Void]
#>
Function Add-SummaryLink {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_addsummarylink')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][String]$Text,
		[Parameter(Mandatory = $True, Position = 1)][Alias('Url')][String]$Uri,
		[AllowEmptyString()][AllowNull()][String]$Title,
		[Switch]$NoNewLine
	)
	[String]$ResultMarkdown = "[$([System.Web.HttpUtility]::HtmlAttributeEncode($Text))]($([Uri]::EscapeUriString($Uri))"
	If ($Title.Length -gt 0) {
		$ResultMarkdown += " `"$([System.Web.HttpUtility]::HtmlAttributeEncode($Title))`""
	}
	$ResultMarkdown += ')'
	Add-Summary -Value $ResultMarkdown -NoNewLine:($NoNewLine.IsPresent)
}
Set-Alias -Name 'Add-SummaryHyperlink' -Value 'Add-SummaryLink' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Summary Subscript Text
.DESCRIPTION
Add subscript text for the current step to display on the summary page of a run.
.PARAMETER Text
A string that need to subscript text.
.PARAMETER NoNewLine
Whether to not add a new line or carriage return to the content; The string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
[Void]
#>
Function Add-SummarySubscriptText {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_addsummarysubscripttext')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('Input', 'InputObject', 'Object')][String]$Text,
		[Switch]$NoNewLine
	)
	Add-Summary -Value "<sub>$([System.Web.HttpUtility]::HtmlEncode($Text))</sub>" -NoNewLine:($NoNewLine.IsPresent)
}
Set-Alias -Name 'Add-SummarySubscript' -Value 'Add-SummarySubscriptText' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Add Summary Superscript Text
.DESCRIPTION
Add superscript text for the current step to display on the summary page of a run.
.PARAMETER Text
A string that need to superscript text.
.PARAMETER NoNewLine
Whether to not add a new line or carriage return to the content; The string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
[Void]
#>
Function Add-SummarySuperscriptText {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_addsummarysuperscripttext')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0)][Alias('Input', 'InputObject', 'Object')][String]$Text,
		[Switch]$NoNewLine
	)
	Add-Summary -Value "<sup>$([System.Web.HttpUtility]::HtmlEncode($Text))</sup>" -NoNewLine:($NoNewLine.IsPresent)
}
Set-Alias -Name 'Add-SummarySuperscript' -Value 'Add-SummarySuperscriptText' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Clear Summary
.DESCRIPTION
Clear the summary that set in the current step.
.OUTPUTS
[Void]
#>
Function Clear-Summary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_clearsummary')]
	[OutputType([Void])]
	Param ()
	Clear-GitHubActionsFileCommand -FileCommand 'GITHUB_STEP_SUMMARY'
}
Set-Alias -Name 'Remove-Summary' -Value 'Clear-Summary' -Option 'ReadOnly' -Scope 'Local'
<#
.SYNOPSIS
GitHub Actions - Get Summary
.DESCRIPTION
Get the summary that set in the current step.
.PARAMETER Raw
Whether to ignore newline characters and output the entire contents of a file in one string with the newlines preserved; By default, newline characters in a file are used as delimiters to separate the input into an array of strings.
.PARAMETER Size
Whether to get the size of the summary instead of the contents of the summary.
.OUTPUTS
[String] Summary with the entire contents in one string.
[String[]] Summary with the entire contents in multiple strings separated by newline characters.
[UInt32] Size of the summary.
#>
Function Get-Summary {
	[CmdletBinding(DefaultParameterSetName = 'Content', HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_getsummary')]
	[OutputType([String], ParameterSetName = 'ContentRaw')]
	[OutputType([String[]], ParameterSetName = 'Content')]
	[OutputType([UInt32], ParameterSetName = 'Size')]
	Param (
		[Parameter(Mandatory = $True, ParameterSetName = 'ContentRaw')][Switch]$Raw,
		[Parameter(Mandatory = $True, ParameterSetName = 'Size')][Alias('Sizes')][Switch]$Size
	)
	Try {
		If ([String]::IsNullOrEmpty($Env:GITHUB_STEP_SUMMARY)) {
			Throw 'Environment path `GITHUB_STEP_SUMMARY` is not defined!'
		}
		If (![System.IO.Path]::IsPathFullyQualified($Env:GITHUB_STEP_SUMMARY)) {
			Throw "``$Env:GITHUB_STEP_SUMMARY`` (environment path ``GITHUB_STEP_SUMMARY``) is not a valid absolute path!"
		}
		If (!(Test-Path -LiteralPath $Env:GITHUB_STEP_SUMMARY -PathType 'Leaf')) {
			Throw 'File is not exist!'
		}
		If ($PSCmdlet.ParameterSetName -ieq 'Size') {
			Get-Item -LiteralPath $Env:GITHUB_STEP_SUMMARY |
				Select-Object -ExpandProperty 'Length' |
				Write-Output
		}
		Else {
			Get-Content -LiteralPath $Env:GITHUB_STEP_SUMMARY -Raw:($PSCmdlet.ParameterSetName -ieq 'ContentRaw') -Encoding 'UTF8NoBOM' |
				Write-Output
		}
	}
	Catch {
		Write-Error -Message "Unable to get the GitHub Actions summary: $_" -Category 'ResourceUnavailable'
	}
}
<#
.SYNOPSIS
GitHub Actions - Internal - Test Summary Path
.DESCRIPTION
Test summary path.
.OUTPUTS
[Void]
#>
Function Test-SummaryPath {
	[OutputType([Void])]
	Param ()
	If ([String]::IsNullOrEmpty($Env:GITHUB_STEP_SUMMARY)) {
		Throw 'Environment path `GITHUB_STEP_SUMMARY` is not defined!'
	}
	If (![System.IO.Path]::IsPathFullyQualified($Env:GITHUB_STEP_SUMMARY)) {
		Throw "``$Env:GITHUB_STEP_SUMMARY`` (environment path ``GITHUB_STEP_SUMMARY``) is not a valid absolute path!"
	}
	If (!(Test-Path -LiteralPath $Env:GITHUB_STEP_SUMMARY -PathType 'Leaf')) {
		Throw 'File is not exist!'
	}
}
<#
.SYNOPSIS
GitHub Actions - Set Summary
.DESCRIPTION
Set some GitHub flavored Markdown for the current step to display on the summary page of a run.

Can use to display and group unique content, such as test result summaries, so that viewing the result of a run does not need to go into the logs to see important information related to the run, such as failures.

When a run's job finished, the summaries for all steps in a job are grouped together into a single job summary and are shown on the run summary page. If multiple jobs generate summaries, the job summaries are ordered by job completion time.
.PARAMETER Value
Contents of the summary.
.PARAMETER NoNewLine
Whether to not add a new line or carriage return to the content; The string representations of the input objects are concatenated to form the output, no spaces or newlines are inserted between the output strings, no newline is added after the last output string.
.OUTPUTS
[Void]
#>
Function Set-Summary {
	[CmdletBinding(HelpUri = 'https://github.com/hugoalh/github-actions-core-powershell/wiki/api_function_setsummary')]
	[OutputType([Void])]
	Param (
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)][AllowEmptyCollection()][AllowEmptyString()][AllowNull()][Alias('Content')][String[]]$Value,
		[Switch]$NoNewLine
	)
	Begin {
		[Boolean]$ShouldProceed = $True
		Try {
			Test-SummaryPath
		}
		Catch {
			$ShouldProceed = $False
			Write-Error -Message "Unable to write the GitHub Actions summary: $_" -Category 'ResourceUnavailable'
		}
		[String[]]$Result = @()
	}
	Process {
		If (!$ShouldProceed) {
			Return
		}
		If ($Value.Count -gt 0) {
			$Result += $Value |
				Join-String -Separator "`n"
		}
	}
	End {
		If ($Result.Count -gt 0) {
			$Result |
				Join-String -Separator "`n" |
				Set-Content -LiteralPath $Env:GITHUB_STEP_SUMMARY -Confirm:$False -NoNewline:($NoNewLine.IsPresent) -Encoding 'UTF8NoBOM'
		}
	}
}
Export-ModuleMember -Function @(
	'Add-Summary',
	'Add-SummaryHeader',
	'Add-SummaryImage',
	'Add-SummaryLink',
	'Add-SummarySubscriptText'
	'Add-SummarySuperscriptText'
	'Clear-Summary',
	'Get-Summary',
	'Set-Summary'
) -Alias @(
	'Add-SummaryHyperlink',
	'Add-SummaryPicture',
	'Add-SummaryRaw',
	'Add-SummarySubscript',
	'Add-SummarySuperscript',
	'Remove-Summary'
)
