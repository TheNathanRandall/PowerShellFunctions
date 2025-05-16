function Enable-PIMRoles {
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
