function Get-NewVariables {
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
