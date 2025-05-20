<#PSScriptInfo

.VERSION 1.0.0.0

.GUID 3d27bc89-d692-466b-b935-4e5ef319bbb0

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
I was converting some metric woodworking plans to imperial and got tired of doing the math. I wrote this function to spit a bunch of them out for me quickly. I thought it might be useful to others.

.PRIVATEDATA


#>


function ConvertFrom-MetricLength {
    <#

    .SYNOPSIS
    Converts metric length to imperial length.

    .DESCRIPTION
    Converts metric length to imperial length. The input can be in millimeters or centimeters. The output can be in a custom format or as a PowerShell object.
    An object is returned with the following properties:
        Millimeters   : Total length in millimeters
        Centimeters   : Total length in centimeters
        Feet          : Total whole feet
        Inches        : Whole inches remaining
        InchFraction  : Fractional part of the inch remaining, to nearest 1/6
        InchSixteenth : Closest sixteenth of an inch remaining
        InchRemainder : Inch remaining as a decimal
        TotalFeet     : Total length in feet as a decimal
        TotalInches   : Total length in inches as a decimal

    .PARAMETER Millimeters
    The length in millimeters to convert to imperial. This parameter is mandatory.
    .PARAMETER Centimeters
    The length in centimeters to convert to imperial. This parameter is mandatory.
    .PARAMETER OutputType
    The type of output to return. The default is 'Write', which writes the output to the console. 'Object' returns a PowerShell object. 'Both' returns both.

    .EXAMPLE
    ConvertFrom-MetricLength -Millimeters 178

    178 mm to Imperial:
    Inches     : 7.00787"
    Fractional : 7"  +0.00787"

    Converts 178 millimeters to imperial length and writes the output to the console.
    .EXAMPLE
    ConvertFrom-MetricLength -Centimeters 11.8 -OutputType Object

    Millimeters   : 118
    Centimeters   : 11.8
    Feet          : 0
    Inches        : 4
    InchFraction  : 5/8
    InchSixteenth : 10
    InchRemainder : 0.645669291338583
    TotalFeet     : 0.387139107611549
    TotalInches   : 4.64566929133858



    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName='mm',ValueFromPipeline=$true,Position=0,ValueFromRemainingArguments=$true)]
            [Alias('MM')]
            [int]
            $Millimeters,
        [Parameter(Mandatory=$true,ParameterSetName='cm')]
            [Alias('CM')]
            [double]
            $Centimeters,
        [Parameter(Position=1)]
            [ValidateSet('Write','Object','Both')]
            [string]
            $OutputType = 'Write'
    )
    begin {
        if ($Centimeters) {
            $Millimeters = $Centimeters * 10
        }
    }
    process {
        # $Millimeters = 178
        $LenInches = $Millimeters / 25.4
        $LenFeet = $LenInches / 12
        $Feet = [math]::Truncate($LenFeet)
        $Inches = $LenInches % 12
        $SubInches = [math]::Truncate($Inches)
        # $AllInches = [math]::Truncate($SubInches)
        $NearestFraction = [math]::Round($Inches % 1 * 16)
        $Fraction = switch ($NearestFraction) {
            0 {''}
            1 {'1/16'}
            2 {'1/8'}
            3 {'3/16'}
            4 {'1/4'}
            5 {'5/16'}
            6 {'3/8'}
            7 {'7/16'}
            8 {'1/2'}
            9 {'9/16'}
            10 {'5/8'}
            11 {'11/16'}
            12 {'3/4'}
            13 {'13/16'}
            14 {'7/8'}
            15 {'15/16'}
            16 {''}
        }
        # if ($Fraction) {" $Fraction"} else {''}
        $Variance = if ($Fraction) {
            $NearestFraction / 16 - $LenInches % 1
        } elseif ($NearestFraction -eq 16) {
            $LenInches % 1 - 1
        } else {
            $LenInches % 1
        }

        if ($OutputType -in ('Write','Both')) {
            if ($Centimeters) {
                "{0}{1} cm ({2} mm) to Imperial:{2}" -f $PSStyle.Bold, $Centimeters, $Millimeters, $PSStyle.Reset | Write-Host
            } else {
                "{0}{1} mm to Imperial:{2}" -f $PSStyle.Bold, $Millimeters, $PSStyle.Reset | Write-Host
            }

            $Space = if ($Fraction) {' '} else {''}
            $Frac  = if ($Fraction) {$Fraction} else {''}
            $Plus  = if ($Variance -gt 0) {$PSStyle.Italic + '+'} else {$PSStyle.Italic}
            if ($Feet) {
                "Feet        : {0:n5}`"" -f $LenFeet | Write-Host
                'Feet+Inches : {0}''  {1:n5}"' -f $Feet, $Inches | Write-Host
                'Fractional  : {0}''  {1}{2}{3}"  {4}{5:n5}"{6}' -f $Feet, $SubInches, $Space, $Frac, $Plus, $Variance, $PSStyle.Reset | Write-Host
            } else {
                'Inches     : {0:n5}"' -f $Inches | Write-Host
                'Fractional : {0}{1}{2}"  {3}{4:n5}"{5}' -f $SubInches, $Space, $Frac, $Plus, $Variance, $PSStyle.Reset | Write-Host
            }
        }
        if ($OutputType -in ('Object','Both')) {
            [PSCustomObject]@{
                Millimeters     = $Millimeters -as [int]
                Centimeters     = if ($Centimeters) {$Centimeters -as [double]} else {$Millimeters / 10 -as [double]}
                Feet            = $Feet -as [int]
                Inches          = $SubInches -as [int]
                InchFraction    = if ($Fraction.Length) {$Fraction}
                InchSixteenth   = if ($NearestFraction -eq 16) {[int]0} else {[int]$NearestFraction}
                InchRemainder   = $Inches % 1
                TotalFeet       = $LenFeet
                TotalInches     = $LenInches
            }
        }
    }
    end {}
}