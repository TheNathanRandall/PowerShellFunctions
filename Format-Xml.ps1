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
