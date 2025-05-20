<#PSScriptInfo

.VERSION 0.1.0.0

.GUID c76126a8-84aa-436b-9a23-d5933ed577e8

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
    This is not a complete function. It is a work in progress.
    It is not intended to be used in production.
    It is intended as my own "to-do" project.
    It will kinda work, but is ugly and not really worth using yet.

.PRIVATEDATA


#>

function Format-Xml {
    <#
    .SYNOPSIS
        Outputs System.Xml.XmlNode or System.Xml.XmlDocument object as formatted  Xml
    .PARAMETER InputObject
        Xml object by pipeline only
    .EXAMPLE
        $Xml | Format-XML
    #>
    [CmdletBinding()]
    param (
        # XML to format
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Xml]
        $InputObject
    )

    begin {}

    process {
        [System.Xml.Linq.XDocument]::Parse($InputObject.OuterXml).ToString()
    }

    end {}
}
