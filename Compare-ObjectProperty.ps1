function Compare-ObjectProperty {
    <#
    .SYNOPSIS
        Compares two objects property by property.
    .DESCRIPTION
        Compares two objects property by property. A simple Compare-Object only compares those properties with the same name in the two objects.
    .PARAMETER ReferenceObject
        The first object to compare
    .PARAMETER DifferenceObject
        The second object to compare
    .EXAMPLE
        $a = New-Object psobject -Prop ([ordered] @{ One = 1; Two = 2})
        $b = New-Object psobject -Prop ([ordered] @{ One = 1; Two = 2; Three = 3})
    
        Compare-Object $a $b
    
        # would return $null because it only compares the properties that have common names but
    
        Compare-ObjectProperty $a $b
    
        # would return below because it compares the two objects property by property
    
        PropertyName StartValue EndValue
        ------------ -------- ---------
        Three                         3
    .OUTPUTS
        [psobject]
    .LINK
        Compare-Object
    #>
    # Stolen from https://github.com/riedyw/PoshFunctions and tweaked by Nathan
    
    [CmdletBinding(ConfirmImpact = 'None')]
    [OutputType('psobject')]
    Param(
        [Parameter(Mandatory, HelpMessage = 'First object to compare', Position = 0)]
        [PSObject] $ReferenceObject,
    
        [Parameter(Mandatory, HelpMessage = 'Second object to compare', Position = 1)]
        [PSObject] $DifferenceObject
    )
    
    begin {
        Write-Verbose -Message "Starting [$($MyInvocation.MyCommand)]"
        $objProps = New-Object -TypeName System.Collections.ArrayList
    }
    
    process {
        $null = $objProps.AddRange(($ReferenceObject | Get-Member -MemberType Property, NoteProperty).Name)
        $null = $objProps.AddRange(($DifferenceObject | Get-Member -MemberType Property, NoteProperty).Name)
        # Old way would consider property name uniqueness including capitalization
        # $objProps = $objProps | Sort-Object | Select-Object -Unique 
        # New way is case-insensitive
        $objProps = $objProps | Sort-Object -Unique
        $diffs = New-Object -TypeName System.Collections.ArrayList
        foreach ($objProp in $objProps) {
            $diff = Compare-Object -ReferenceObject $ReferenceObject -DifferenceObject $DifferenceObject -Property $objProp
            if ($diff) {
                $diffProps = @{
                    PropertyName = $objProp
                    StartValue   = ($diff | Where-Object { $_.SideIndicator -eq '<=' } | ForEach-Object $($objProp))
                    EndValue     = ($diff | Where-Object { $_.SideIndicator -eq '=>' } | ForEach-Object $($objProp))
                }
                $null = $diffs.Add((New-Object -TypeName PSObject -Property $diffProps))
            }
        }
        if ($diffs) {
            $diffs | Select-Object -Property PropertyName, StartValue, EndValue
        }
    }
    
    end {
        Write-Verbose -Message "Ending [$($MyInvocation.MyCommand)]"
    }
    
}
