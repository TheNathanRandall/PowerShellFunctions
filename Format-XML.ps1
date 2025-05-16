function Format-XML {
    [CmdletBinding()]
    param (
        # XML to format
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
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
