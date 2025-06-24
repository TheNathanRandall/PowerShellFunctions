
function Find-Verb {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromRemainingArguments=$true)]
        [string[]]
        $Verb
    )
    
    begin {
        $Key = 'fkS0rTuZ62Duag0bYgwn'
    }
    
    process {
        $Verb | ForEach-Object {
            $ThisVerb = $PSItem
            $ThesaurusData = Invoke-RestMethod -Uri "http://thesaurus.altervista.org/thesaurus/v1?word=$ThisVerb&language=en_US&key=$Key&output=json"
            $Synonyms = $ThesaurusData.response.list.synonyms -split '\|' -replace ' \(.*' | Where-Object {$ThisVerb -NotMatch '\W'} | Sort-Object -Unique
            
            $ValidSynonyms = @()
            $ValidSynonyms += $ThisVerb | Get-Verb
            $ValidSynonyms += $Synonyms | Get-Verb
    
            if (-not $ValidSynonyms) {
                Write-Warning -Message "No allowed Verb synonyms found for $ThisVerb"
            } else {
                $ValidSynonyms | Select-Object *, @{
                    Name = 'SearchedVerb'
                    Expression = {$ThisVerb}
                }
            }
        }
        
    }
    
    end {}
}
