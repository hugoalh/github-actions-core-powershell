# GitHub Actions - Core (PowerShell)

> [!IMPORTANT]
> - This project is transferred ownership from hugoalh Studio (`hugoalh-studio`) to hugoalh (`hugoalh`) and refactoring, some of the files may not modified/updated yet.
> - Looking the source code of the old PowerShell module `hugoalh.GitHubActionsToolkit`? Please visit the [versions list](https://github.com/hugoalh/github-actions-core-powershell/tags) and select the correct version.

[**⚖️** MIT](./LICENSE.md)

[![GitHub: hugoalh/github-actions-core-powershell](https://img.shields.io/github/v/release/hugoalh/github-actions-core-powershell?label=hugoalh/github-actions-core-powershell&labelColor=181717&logo=github&logoColor=ffffff&sort=semver&style=flat "GitHub: hugoalh/github-actions-core-powershell")](https://github.com/hugoalh/github-actions-core-powershell)
[![PowerShell Gallery: hugoalh.GitHubActionsCore](https://img.shields.io/powershellgallery/v/hugoalh.GitHubActionsCore?label=hugoalh.GitHubActionsCore&labelColor=5391FE&logo=powershell&logoColor=ffffff&style=flat "PowerShell Gallery: hugoalh.GitHubActionsCore")](https://www.powershellgallery.com/packages/hugoalh.GitHubActionsCore)

A PowerShell module to provide a better and easier way for GitHub Actions to communicate with the runner, and the toolkit for developing GitHub Actions.

## ⚠️ Important

[official-toolkit]: https://github.com/actions/toolkit

This is a partial refactor of [the official toolkit][official-toolkit], not all of the features in [the official toolkit][official-toolkit] are available in here, and not all of the features in here are available in [the official toolkit][official-toolkit].

## 🌟 Features

- Ability to use directly on GitHub Actions with PowerShell runtime without complex setup.

## 🔰 Begin

### 🎯 Targets

|  | **PowerShell Gallery** |
|:--|:--|
| **[PowerShell](https://microsoft.com/PowerShell)** >= v7.2.0 | ✔️ |

> [!NOTE]
> - It is possible to use this module in other methods/ways which not listed in here, however those methods/ways are not officially supported, and should beware maybe cause security issues.

### #️⃣ Resources Identifier

- **PowerShell Gallery:**
  ```
  hugoalh.GitHubActionsCore
  ```

## 🧩 APIs

**Default Prefix:** `GitHubActions`

- `Add-PATH`
- `Add-ProblemMatcher`
- `Add-SecretMask`
- `Add-Summary`
- `Disable-StdOutCommandEcho`
- `Disable-StdOutCommandProcess`
- `Enable-StdOutCommandEcho`
- `Enable-StdOutCommandProcess`
- `Enter-LogGroup`
- `Exit-LogGroup`
- `Get-DebugStatus`
- `Get-Input`
- `Get-State`
- `Get-WebhookEventPayload`
- `Get-WorkflowRunUri`
- `Remove-ProblemMatcher`
- `Set-EnvironmentVariable`
- `Set-Output`
- `Set-State`
- `Set-Summary`
- `Test-Environment`
- `Write-Debug`
- `Write-Error`
- `Write-Fail`
- `Write-Notice`
- `Write-Warning`

> [!NOTE]
> - For the full or prettier documentation, can visit via:
>   - [GitHub Repository Wiki](https://github.com/hugoalh/github-actions-core-powershell/wiki)

## ✍️ Examples

- ```ps1
  Set-Output -Name 'foo' -Value 'bar'
  ```
- ```ps1
  Write-GitHubActionsNotice -Message 'Hello, world!'
  ```
