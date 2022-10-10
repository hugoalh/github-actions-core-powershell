#Requires -PSEdition Core
#Requires -Version 7.2
[Char[]]$PoolLowerCase = [Char[]]@(97..122)
[Char[]]$PoolNumber = [String[]]@(0..9)
[Char[]]$PoolUpperCase = [Char[]]@(65..90)
<#
.SYNOPSIS
GitHub Actions - Internal - New Random Token
.DESCRIPTION
Generate a new random token.
.PARAMETER Length
Length of the token.
.PARAMETER WithUpperCase
Contain upper case letters in the token.
.OUTPUTS
[String] A new random token.
#>
Function New-RandomToken {
	[CmdletBinding()]
	[OutputType([String])]
	Param (
		[Parameter(Position = 0)][ValidateRange(1, [UInt32]::MaxValue)][UInt32]$Length = 8,
		[Alias('UpperCase')][Switch]$WithUpperCase
	)
	[Char[]]$Pool = $PoolLowerCase + $PoolNumber + ($WithUpperCase.IsPresent ? $PoolUpperCase : @())
	@(1..$Length) |
		ForEach-Object -Process {
			$Pool |
				Get-Random -Count 1
		} |
		Join-String -Separator '' |
		Write-Output
}
Export-ModuleMember -Function @(
	'New-RandomToken'
)
