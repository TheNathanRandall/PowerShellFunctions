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
                # if ($PSItem.Duration.TotalHours -ge 10) {
                #     return '{0}:{1:mm}:{1:ss}.{1:fff}' -f [int]$PSItem.Duration.TotalHours, $PSItem.Duration
                # } else
                if ($PSItem.Duration.TotalHours -ge 1) {
                    $FormatString = 'h\:mm\:ss\.fff'
                } elseif ($PSItem.Duration.TotalMinutes -ge 1) {
                    $FormatString = 'm\:ss\.fff'
                } else {
                    $FormatString = 's\.fff'
                }
                "{0,12:$FormatString}" -f $PSItem.Duration #.ToString($FormatString)
            }
        }, CommandLine
    }
}
