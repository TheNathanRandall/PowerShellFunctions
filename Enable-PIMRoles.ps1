<#PSScriptInfo

.VERSION 1.0.0.0

.GUID 830c55fd-0320-4dbc-9bea-f8a2679d62f3

.AUTHOR TheNathanRandall

.COMPANYNAME

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI https://github.com/TheNathanRandall/PowerShellFunctions

.ICONURI

.EXTERNALMODULEDEPENDENCIES Microsoft.Graph

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA


#>


function Enable-PIMRoles {
    <#

    .SYNOPSIS
    Enables PIM roles for the current user.

    .DESCRIPTION
    Enables PIM roles for the current user. If no roles are specified, all eligible roles are enabled. If no expiration is specified, the role is enabled for 8 hours. If a start time is specified, the role is enabled at that time. If an end time is specified, the role is enabled until that time.

    .PARAMETER Hours
    The number of hours to enable the role for. Default is 8 hours. This parameter is ignored if the StartTime or EndTime parameters are specified.
    .PARAMETER EndTime
    The time to stop the role. This parameter is ignored if the Hours parameter is specified.
    .PARAMETER StartTime
    The time to start the role. Defaults to now.
    .PARAMETER Roles
    The roles to enable. If not specified, all eligible roles are enabled.
    .PARAMETER RoleID
    The ID(s) of the role(s) to enable.
    .PARAMETER Justification
    The justification for enabling the role. Default is 'Termination script work'.

    .EXAMPLE
    Enable-PIMRoles -Justification 'Testing'
    Enables all eligible roles for the current user with the specified justification.
    .EXAMPLE
    Enable-PIMRoles -Hours 4
    Enables all eligible roles for the current user for 4 hours.
    .EXAMPLE
    Enable-PIMRoles -StartTime (Get-Date).AddHours(1) -EndTime (Get-Date).AddHours(2)
    Enables all eligible roles for the current user starting in 1 hour and ending in 2 hours.
    .EXAMPLE
    Enable-PIMRoles -RoleID 'b1c2d3e4-f5g6-h7i8-j9k0-l1m2n3o4p5q6'
    Enables the role with the specified ID for the current user.
    .EXAMPLE
    $PrincipalId = (Invoke-MgGraphRequest -Method get -Uri 'https://graph.microsoft.com/v1.0/me').Id
    $RolesToActive = Get-MGRoleManagementDirectoryRoleEligibilitySchedule -Filter "principalId eq '$PrincipalId'" -ExpandProperty RoleDefinition | Where-Object { $_.RoleDefinition.DisplayName -notlike 'Exchange*' }
    $RolesToActive | Enable-PIMRoles -Justification 'Testing'
    Enables all non-Exchange roles for the current user with the specified justification.

    #>
    [CmdletBinding(DefaultParameterSetName='Length')]
    param (
        [Parameter(ParameterSetName='Length')]
        [ValidateRange(1, 23)]
        [int]
        $Hours = 8,
        [Parameter(ParameterSetName='StartStop')]
        [DateTime]
        $EndTime,
        [Parameter(ParameterSetName='StartStop')]
        [DateTime]
        $StartTime,
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Microsoft.Graph.PowerShell.Models.MicrosoftGraphUnifiedRoleEligibilitySchedule[]]
        $Roles,
        [Parameter()]
        [String[]]
        $RoleID,
        [Parameter()]
        [Alias('Reason')]
        [string]
        $Justification = 'Termination script work'
    )

    begin {
        try {
            Write-Verbose 'Validating Graph is connected'
            $null = Get-MgContext
        } catch {
            throw 'Graph not connected'
        }
        $PrincipalId = (Invoke-MgGraphRequest -Method get -Uri 'https://graph.microsoft.com/v1.0/me').Id
        $ScheduleInfo = @{
            StartDateTime = if ($StartTime) {$StartTime} else {Get-Date}
            Expiration    = @{
                Type = 'AfterDuration'
            }
        }
        if ($EndTime) {
            $ScheduleInfo.Expiration.Type = 'afterDateTime'
            $ScheduleInfo.Expiration.EndDateTime = $EndTime.ToUniversalTime()
        } else {
            $ScheduleInfo.Expiration.Duration = 'PT{0}H' -f $Hours
        }
        if (-not $Roles -and -not $RoleID) {
            Write-Verbose "Getting eligible roles for ID $PrincipalId"
            $Roles = Get-MgRoleManagementDirectoryRoleEligibilitySchedule -ExpandProperty RoleDefinition -All -Filter "principalId eq '$PrincipalId'"
            if ($Roles) {
                $VerboseString = "Found roles:`nId                                   DisplayName`n--                                   -----------"
                $Roles | ForEach-Object {
                    $VerboseString += "`n{0} {1}" -f $PSItem.Id, $PSItem.RoleDefinition.DisplayName
                }
                Write-Verbose $VerboseString
            }
        }
    }

    process {
        # Write-Host -ForegroundColor 8 -BackgroundColor 15 '  Process  '
        $RequestBodyParams = @{
            DirectoryScopeId = '/'
            PrincipalId      = $PrincipalId
            RoleDefinitionId = $null
            Action           = 'selfActivate'
            Justification    = $Justification
            # IsValidationOnly = $true
            ScheduleInfo     = $ScheduleInfo
        }
        Write-Verbose 'Base request params'
        $RequestBodyParams | ConvertTo-Json | Write-Verbose
        if ($RoleID) {
            $RoleID | ForEach-Object {
                $RequestBodyParams.RoleDefinitionId = $PSItem
                Write-Verbose "Requesting activation of PIM role $PSItem"
                try {
                    New-MgRoleManagementDirectoryRoleAssignmentScheduleRequest -BodyParameter $RequestBodyParams
                } catch {
                    Write-Host $PSItem.Exception
                }
            }
        } elseif ($Roles) {
            $Roles | ForEach-Object {
                $RequestBodyParams.RoleDefinitionId = $PSItem.RoleDefinitionId
                $RequestBodyParams.DirectoryScopeId = $PSItem.DirectoryScopeId
                Write-Verbose ('Requesting activation of PIM role {0} ({1})' -f $PSItem.RoleDefinition.DisplayName, $PSItem.Id)
                try {
                    New-MgRoleManagementDirectoryRoleAssignmentScheduleRequest -BodyParameter $RequestBodyParams
                } catch {
                    Write-Host $PSItem.Exception
                }
            }
        }
    }

    end {}
}
