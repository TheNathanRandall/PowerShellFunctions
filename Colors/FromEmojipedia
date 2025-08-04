$AsList = ConvertFrom-HTML -Content (Get-Clipboard)
$AsList | Get-Member -MemberType Properties
$AsList.ChildNodes | Get-Member -MemberType Methods
$AsList.ChildNodes.ChildNodes | Format-Table

$Nav = $AsList.ChildNodes.CreateNavigator()
$Nav.Select("//div[@class='mb-4']")
$Nav.Select("//div[contains(@class,'mb-4')]")

$Categories = @{
    Smileys = 'https://emojipedia.org/smileys#list'
    People = 'https://emojipedia.org/people#list'
    AnimalsNature = 'https://emojipedia.org/nature#list'
    FoodDrink = 'https://emojipedia.org/FoodDrink#list'
    Activity = 'https://emojipedia.org/activity#list'
    TravelPlaces = 'https://emojipedia.org/travel-places#list'
    Objects = 'https://emojipedia.org/objects#list'
    Symbols = 'https://emojipedia.org/symbols#list'
    Flags = 'https://emojipedia.org/flags#list'
}
$AllEmoji = [System.Collections.Generic.List[pscustomobject]]::new()
foreach ($Category in $Categories.Keys) {
    Write-Host -ForegroundColor Green $Category
    $AsList = ConvertFrom-HTML -Url $Categories.$Category
    $AsList.SelectNodes("//div[contains(@class,'mb-4') and @id != '']") | ForEach-Object {
        $SubCategory = $PSItem.ChildNodes[0].InnerText.Replace('&amp;','&')
        Write-Host -ForegroundColor Blue $SubCategory
        foreach ($Node in $PSItem.ChildNodes[1].ChildNodes) {
            $Name  = $Node.ChildNodes[1].InnerText
            $Emoji = $Node.ChildNodes[0].InnerText
            $AllEmoji.Add((
                [PSCustomObject]@{
                    Category    = $Category
                    SubCategory = $SubCategory
                    Name        = $Name
                    Emoji       = $Emoji
                }
            ))
        }

    }
}
