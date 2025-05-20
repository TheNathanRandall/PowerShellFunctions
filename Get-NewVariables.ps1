<#PSScriptInfo

.VERSION 1.0.0.0

.GUID a6b10b41-c558-4375-b399-3449758a791e

.AUTHOR TheNathanRandall

.COMPANYNAME

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI https://github.com/TheNathanRandall/PowerShellFunctions

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA


#>
function Get-NewVariables {
    <#
    .SYNOPSIS
    Gets a list of the new variables created during the current session.

    .DESCRIPTION
    Gets a list of the new variables created during the current session. This includes all variables that are not part of the automatic variables.

    .PARAMETER IncludeAll
    Include variables beginning with __*. These are excluded by default as they are usually for internal purposes.

    .EXAMPLE
    Get-NewVariables
    Gets a list of the new variables created during the current session.
    .EXAMPLE
    Get-NewVariables -IncludeAll
    Gets a list of the new variables created during the current session including those beginning with __*.
    .EXAMPLE
    Get-NewVariables | Remove-Variable
    Removes all the new variables created during the current session.

    #>
    param (
        [Parameter()]
        [Switch]
        $IncludeAll
    )
    $__AutomaticVariables = @(
        '$', '?', '^', '_', 'args', '__AutomaticVariables', 'ConfirmPreference', 'ConsoleFileName',
        'ContinuationPrompt', 'DebugPreference', 'EnabledExperimentalFeatures', 'Error', 'ErrorActionPreference',
        'ErrorView', 'Event', 'EventArgs', 'EventSubscriber', 'ExecutionContext', 'false', 'foreach',
        'FormatEnumerationLimit', 'HOME', 'Host', 'InformationPreference', 'input', 'IsCoreCLR', 'IsLinux', 'IsMacOS',
        'IsStable', 'IsWindows', 'IsWindows10', 'LASTEXITCODE', 'LogCommandHealthEvent', 'LogCommandLifecycleEvent',
        'LogEngineHealthEvent', 'LogEngineLifecycleEvent', 'LogProviderHealthEvent', 'LogProviderLifecycleEvent',
        'Matches', 'MaximumAliasCount', 'MaximumDriveCount', 'MaximumErrorCount', 'MaximumFunctionCount',
        'MaximumHistoryCount', 'MaximumVariableCount', 'MyInvocation', 'NestedPromptLevel', 'Nonce', 'null', 'OFS',
        'osVersion', 'OutputEncoding', 'PID', 'PROFILE', 'ProgressPreference', 'PSBoundParameters', 'PSCmdlet',
        'PSCommandPath', 'PSCulture', 'PSDebugContext', 'PSDefaultParameterValues', 'PSEdition', 'psEditor',
        'PSEmailServer', 'PSGetPath', 'PSHOME', 'PSItem', 'PSModuleAutoLoadingPreference',
        'PSNativeCommandArgumentPassing', 'PSNativeCommandUseErrorActionPreference', 'PSScriptRoot', 'PSSenderInfo',
        'PSSessionApplicationName', 'PSSessionConfigurationName', 'PSSessionOption', 'PSStyle', 'PSUICulture',
        'PSVersionTable', 'PWD', 'Sender', 'ShellId', 'StackTrace', 'switch', 'this', 'Transcript', 'true',
        'VerbosePreference', 'WarningPreference', 'WhatIfPreference'
    )
    if ($IncludeAll) {
        Get-Variable | Where-Object Name -NotIn $__AutomaticVariables
    } else {
        Get-Variable -Exclude '__*' | Where-Object Name -NotIn $__AutomaticVariables
    }
}
