<#PSScriptInfo

.VERSION 1.0.0.0

.GUID 32634b9b-7738-46eb-985f-95b709f46114

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

if ( $PSVersionTable.PSVersion -like '5*' ) {
    <#

    .SYNOPSIS
     Gets a list of the commands entered during the current session including the duration of each command.

    .DESCRIPTION
    Gets a list of the commands entered during the current session including the duration of each command.
    While this is available in PowerShell 6+, it is not available in Windows PowerShell. This function adds the Duration property to the history objects.

    .PARAMETER Count
    The number of commands to return. Default is 10.
    .PARAMETER AsObject
    Return the history as objects instead of a formatted table.
    .PARAMETER Wrap
    Wrap the output in a table. Default is $false.

    .EXAMPLE
    Get-LastCommandTime -Count 5
    Gets the last 5 commands entered during the current session including the duration of each command.
    .EXAMPLE
    Get-LastCommandTime -Count 5 -AsObject
    Gets the last 5 commands entered during the current session including the duration of each command as objects.

    #>
    function Get-LastCommandTime {
        # WindowsPowerShell does not include Duration in [Microsoft.PowerShell.Commands.HistoryInfo] objects returned by Get-Histoy
        # This function gets the duration from StartExecutionTime and EndExecutionTime
        param (
            [int]$Count = 10,
            [switch]$AsObject,
            [switch]$Wrap
        )

        $ThisHistory = Get-History -Count $Count | ForEach-Object {
            $Duration = $PSItem.EndExecutionTime - $PSItem.StartExecutionTime
            $ThisHistory = $PSItem.PsObject.Copy()
            $ThisHistory | Add-Member -PassThru -NotePropertyMembers @{Duration = $Duration } -ErrorAction SilentlyContinue
        }

        if ($AsObject) {
            $ThisHistory
        } else {
            $ThisHistory | Format-Table -Wrap:$Wrap Id, @{
                Name       = 'Duration    '
                Expression = {
                    if ($PSItem.Duration.TotalHours -ge 1) {
                        $FormatString = 'h\:mm\:ss\.fff'
                    } elseif ($PSItem.Duration.TotalMinutes -ge 1) {
                        $FormatString = 'm\:ss\.fff'
                    } else {
                        $FormatString = 's\.fff'
                    }
                    "{0,12:$FormatString}" -f $PSItem.Duration
                }
            }, CommandLine
        }
    }
}
