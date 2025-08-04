# Nearest colors and color names

# From https://github.com/joshbeckman/thecolorapi/tree/master
$ColorNames = Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/joshbeckman/thecolorapi/refs/heads/master/static/colorNames.json' | Select-Object -ExpandProperty colors
$ColorNames | ForEach-Object {
    $PSItem.hex = $PSItem.hex -replace '^#?','#'
    $PSItem.name = $PSItem.name -replace " |'",''
    $PSItem | Add-Member -NotePropertyMembers @{
        Collection = 'ColorNames'
    }
}

$CrayolaNames = Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/joshbeckman/thecolorapi/refs/heads/master/static/crayola2.json' | Select-Object -ExpandProperty colors
$CrayolaNames | ForEach-Object {
    $PSItem.hex = $PSItem.hex -replace '^#?','#'
    $PSItem.name = $PSItem.name -replace " |'",''
    $PSItem | Add-Member -NotePropertyMembers @{
        Collection = 'CrayolaNames'
    }
}

# https://colorbrewer2.org/
Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/joshbeckman/thecolorapi/refs/heads/master/static/colorbrewerIndex.json' | Select-Object -ExpandProperty Index | Select-Object -First 10 | Format-Table
$ColorBrewerColors = Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/joshbeckman/thecolorapi/refs/heads/master/static/colorbrewerIndex.json' | Select-Object -ExpandProperty Index
$ColorBrewerColors | Group-Object class -NoElement
$ColorBrewerColors.Count
$ColorBrewerColors.hex | Sort-Object -Unique | Measure-Object
$ColorBrewerColors | Group-Object hex | Sort-Object Count
$ColorBrewerColors[0]

$ColorBrewerSets = Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/joshbeckman/thecolorapi/refs/heads/master/static/colorbrewer.json'
$ColorBrewerSets.Set3.12
$Sets = @{
    # Color1 > Color2
    Sequential  = 'OrRd','PuBu','BuPu','Oranges','BuGn','YlOrBr','YlGn','Reds','RdPu','Greens','YlGnBu','Purples','GnBu','Greys','YlOrRd','PuRd','Blues','PuBuGn'
    # Color1 > pale > Color2
    Diverging   = 'Spectral','RdYlGn','RdBu','PiYG','PRGn','RdYlBu','BrBG','RdGy','PuOr'
    # Color1, Color2, ...
    Qualitative = 'Set2','Accent','Set1','Set3','Dark2','Paired','Pastel2','Pastel1'
}














# Hacked from https://www.thecolorapi.com/

function Confirm-Hex {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromRemainingArguments=$true)]
        [ValidatePattern('^#?([0-9a-f]{3}){1,2}$')]
        [String[]]
        $Hex
    )

    begin {}

    process {
        foreach ($ThisHex in $Hex) {
            # Format hex code as #xxxxxx
            $UseHex = $ThisHex -replace '^#?','#'
            # Write-Host '$ThisHex:' $ThisHex -ForegroundColor DarkBlue
            # Write-Host '$UseHex: ' $UseHex  -ForegroundColor DarkCyan
            if ($UseHex.Length -notin 4,7) {
                Write-Verbose "$ThisHex is not a valid hex value"
                continue
            } elseif ($UseHex.Length -eq 4) {
                $UseHex = '#{0}{0}{1}{1}{2}{2}' -f $UseHex[1],$UseHex[2],$UseHex[3]
                # Write-Host '$UseHex: ' $UseHex -ForegroundColor Cyan
            }
            $UseHex
        }
    }

    end {}
}

function Convert-HexToRGBPlus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromRemainingArguments=$true)]
        [ValidatePattern('^#?([0-9a-f]{3}){1,2}$')]
        [String[]]
        $Hex
    )

    begin {}

    process {
        foreach ($ThisHex in $Hex) {
            $ThisColor = [system.Drawing.Color]::FromArgb( $ThisHex )
            [PSCustomObject]@{
                Color = $ThisHex
                R     = $ThisColor.R
                G     = $ThisColor.G
                B     = $ThisColor.B
                # H     = $ThisColor.GetHue()
                # S     = $ThisColor.GetSaturation()
                # L     = $ThisColor.GetBrightness()
            }
        }
    }

    end {}
}

function Convert-RGBToRGBHSL {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromRemainingArguments=$true)]
        [PSCustomObject[]]
        $Color
    )

    begin {}

    process {
        foreach ($ThisColor in $Color) {
            # [convert]::ToInt32( '0x' + $ThisHex.Substring(1,2) , 16 )
            # [convert]::ToInt32( '0x' + $ThisHex.Substring(3,2) , 16 )
            # [convert]::ToInt32( '0x' + $ThisHex.Substring(5,2) , 16 )

            $R = $ThisColor.R / 255
            $G = $ThisColor.G / 255
            $B = $ThisColor.B / 255

            $Min    = [math]::Min( $R , [math]::Min( $G , $B ) )
            $Max    = [math]::Max( $R , [math]::Max( $G , $B ) )
            $Delta  = $Max - $Min
            $L      = ($Min + $Max) / 2

            $S      = 0
            if ($L -gt 0 -and $L -lt 1) {
                $Divisor = if ($L -lt 0.5) {
                    2 * $L
                } else {
                    2 - 2 * $L
                }
                $S  = $Delta / $Divisor
            }

            $H      = 0
            if ($Delta -gt 0) {
                if ($Max -eq $R -and $Max -ne $G) {
                    $H += ($G - $B) / $Delta
                }
                if ($Max -eq $G -and $Max -ne $B) {
                    $H += 2 + ($B - $R) / $Delta
                }
                if ($Max -eq $B -and $Max -ne $R) {
                    $H += 4 + ($R - $G) / $Delta
                }
                $H /= 6
            }

            [PSCustomObject]@{
                Color = $ThisColor.Color
                R     = $ThisColor.R
                G     = $ThisColor.G
                B     = $ThisColor.B
                # H     = [math]::Truncate($H * 255)
                H     = [math]::Truncate($H * 359)
                S     = [math]::Truncate($S * 255)
                L     = [math]::Truncate($L * 255)
            }
        }
    }

    end {}
}
<#
[PSCustomObject]@{
    Name = 'Red'
    Hex  = '#FF0000'
    R    = $R
    G    = $G
    B    = $B
    Min  = $Min
    Max  = $Max
    Delta = $Delta
    Divisor = $Divisor
    H    = $H
    S    = $S
    L    = $L
} | Format-Table Name,Hex,R,G,B,Min,Max,Delta,Divisor,H,S,L -AutoSize
 #>
function Get-NearestColor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromRemainingArguments=$true)]
        [ValidatePattern('^#?([0-9a-f]{3}){1,2}$')]
        [String[]]
        $Color
    )

    begin {}

    process {
        foreach ($ThisColor in $Color) {
            $UseColor = Confirm-Hex $ThisColor | Convert-HexToRGBPlus | Convert-RGBToRGBHSL

            $NearDistance1 = $NearDistance2 = $NearDistance = 0
            $ColorIndex = $Distance = -1
            $WillReturn = $null

            for ($i = 0; $i -lt $ColorNames.Count; $i++) {

                if ($UseColor.Color.Replace('#','') -eq $ColorNames[$i].hex) {
                    $WillReturn = [PSCustomObject]@{
                        Name = $ColorNames[$i].name
                        ExactMatch = $true
                        Distance = 0
                    }
                    break
                }

                $NearDistance1 = [math]::Pow($UseColor.R - $ColorNames[$i].r, 2) + [math]::Pow($UseColor.G - $ColorNames[$i].g, 2) + [math]::Pow($UseColor.B - $ColorNames[$i].b, 2)
                $NearDistance2 = [math]::Pow($UseColor.H - $ColorNames[$i].h, 2) + [math]::Pow($UseColor.S - $ColorNames[$i].s, 2) + [math]::Pow($UseColor.L - $ColorNames[$i].l, 2)
                $NearDistance = $NearDistance1 + $NearDistance2 * 2

                if ($Distance -lt 0 -or $Distance -gt $NearDistance) {
                    $Distance = $NearDistance
                    $ColorIndex = $i
                }
            }

            if ($WillReturn) {
                $WillReturn
            } else {
                if ($ColorIndex -lt 0) {
                    [PSCustomObject]@{
                        Name = 'Invalid Color: ' + $UseColor.Color
                        ExactMatch = $false
                        Distance = 0
                    }
                } else {
                    [PSCustomObject]@{
                        Name = $ColorNames[$ColorIndex].name
                        ExactMatch = $false
                        Distance = $Distance
                    }
                }
            }
        }
    }

    end {}
}



$Color = (Invoke-RestMethod -Uri "https://www.thecolorapi.com/id?format=json&hsl=(240,100,50)")

0..11 | ForEach-Object {$PSItem * 30} | ForEach-Object {
    $Color = (Invoke-RestMethod -Uri "https://www.thecolorapi.com/id?format=json&hsl=($_,100,50)")

    "`e[38;2;{0};{1};{2}m {3,-3} {4} {5}`e[0m" -f $Color.rgb.r, $Color.rgb.g, $Color.rgb.b, $PSItem, $Color.Hex.value, $Color.Name.value
}


<#
Priority	Hexidecimal Code	Name

0	FF0000	Red
30	FF4000	Vermilion
60	FF8000	Orange
90	FFBF00	Amber
120	FFFF00	Yellow
150	80FF00	Chartreuse
180	00FF00	Green
210	008080	Teal
240	0000FF	Blue
270	400080	Violet
300	800080	Purple
330	C71585	Magenta

#>