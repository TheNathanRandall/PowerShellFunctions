<#PSScriptInfo

.VERSION 1.0.0.0

.GUID bd60877a-0fb1-4ffd-879c-e6d04e24c2e6

.AUTHOR TheNathanRandall

.COMPANYNAME

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI https://github.com/TheNathanRandall/PowerShellFunctions

.ICONURI

.EXTERNALMODULEDEPENDENCIES PowerShellHumanizer

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA


#>

#Requires -Module @{ ModuleName = 'PowerShellHumanizer'; ModuleVersion = '3.2.0.0' }

<#

.SYNOPSIS
Divides a dataset into equal-sized groups (quantiles).

.PARAMETER DataSet
Array of objects to sort then group into quantiles.

.PARAMETER Property
Optional sort property or properties; otherwise is sorted by whole object.

.PARAMETER SortReverse
Reverse the sort order.

.PARAMETER Quantile
Number of groups to split into.
Defaults to 5 (quintiles).

.PARAMETER Top
Return only the top quantile.

.PARAMETER Bottom
Return only the bottom quantile

#>

function Get-Quantile {
    [CmdletBinding()]
    param (
        # Data to group
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [Alias('Data')]
        [Object[]]
        $DataSet,
        # Optional property to group on
        [Parameter()]
        [string[]]
        $Property,
        # Sort in reverse order
        [Parameter()]
        [Alias('Reverse')]
        [switch]
        $SortReverse,
        # Number of groups to sort into
        [Parameter()]
        [Alias(
            'Count','Number','Groups','Sets',
            'Tercile','Quartile','Quintile','Sextile','Septile','Octile','Nonile','Decile','Percentile'
            # Optional nerdy words for specific quantiles from https://stats.stackexchange.com/questions/235330/iles-terminology-for-the-top-half-a-percent
            )]
        [ValidateRange(2,1000)]
        [Int]
        $Quantile = 5,
        # Return only top group
        [Parameter()]
        [switch]
        $Top,
        # Return only bottom group
        [Parameter()]
        [switch]
        $Bottom
    )

    begin {
        $AllDataItems = [System.Collections.Generic.List[Object]]::new()
    }

    process {
        $DataSet | ForEach-Object {
            $AllDataItems.Add($PSItem)
        }
    }

    end {

        if ($MyInvocation.BoundParameters.Property) {
            $SortedData = $AllDataItems | Sort-Object -Property $Property -Descending:$SortReverse
        } else {
            $SortedData = $AllDataItems | Sort-Object -Descending:$SortReverse
        }
        $ReturnSet = [ordered]@{}


        $TotalCount = $SortedData.Count
        $QuantileSize = $TotalCount/$Quantile
        Write-Verbose "Getting $Quantile groups of about size $QuantileSize of total $TotalCount"

        for ($i = 1; $i -le $Quantile; $i++) {

            $StartIndex = [math]::Floor( ($i - 1) * $QuantileSize )
            $EndIndex   = [math]::Floor( $i * $QuantileSize ) - 1

            if ($i -eq $Quantile) {
                $EndIndex = $TotalCount - 1
            }

            $QuantileSet = $SortedData[$StartIndex..$EndIndex]
            Write-Verbose ("Quantile $i from $StartIndex to $EndIndex contains {0} items from {1} to {2}" -f $QuantileSet.Count, $QuantileSet[0], $QuantileSet[-1])

            $ReturnSet.((ConvertTo-OrdinalWords -Target $i).Dehumanize()) = $QuantileSet

        }


        if ($MyInvocation.BoundParameters.Top) {
            $ReturnSet[-1]
        } elseif ($MyInvocation.BoundParameters.Bottom) {
            $ReturnSet[0]
        } else {
            [PSCustomObject]$ReturnSet
        }
    }
}