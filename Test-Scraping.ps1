# Testing Preview version of Selenium (4.0.0) as well as Monocle

<# Comparison of available commands between Selenium 4.0.0 (preview) and 3.141.0
InputObject              SideIndicator
-----------              -------------
Clear-SeSelectValue      <=
ConvertTo-SeSelenium     <=
Get-SeDriver             <=
Get-SeDriverTimeout      <=
Get-SeFrame              <=
Get-SeHtml               <=
Get-SeInput              <=
Get-SeSelectValue        <=
Get-SeUrl                <=
Invoke-SeJavascript      <=
Invoke-SeKeys            <=
Invoke-seMouseAction     <=
New-SeDriverOptions      <=
New-SeDriverService      <=
New-SeWindow             <=
Pop-SeUrl                <=
Push-SeUrl               <=
Remove-SeWindow          <=
Set-SeDriverTimeout      <=
Set-SeSelectValue        <=
Set-SeUrl                <=
Start-SeDriver           <=
Switch-SeDriver          <=
Update-SeDriver          <=
Wait-SeDriver            <=
Wait-SeElement           <=
Clear-SeAlert            ==
Get-SeCookie             ==
Get-SeElement            ==
Get-SeElementAttribute   ==
Get-SeElementCssValue    ==
Get-SeKeys               ==
Get-SeWindow             ==
Invoke-SeClick           ==
New-SeScreenshot         ==
Remove-SeCookie          ==
Save-SeScreenshot        ==
SeShouldHave             ==
Set-SeCookie             ==
Start-SeRemote           ==
Stop-SeDriver            ==
Switch-SeFrame           ==
Switch-SeWindow          ==
Get-SeSelectionOption    =>
Invoke-SeScreenshot      =>
Open-SeUrl               =>
Send-SeClick             =>
Send-SeKeys              =>
SeOpen                   =>
SeType                   =>
Start-SeChrome           =>
Start-SeEdge             =>
Start-SeFirefox          =>
Start-SeInternetExplorer =>
Start-SeNewEdge          =>
#>


Get-Command -Module Monocle | Sort-Object Noun, Verb | Format-Table Name, Verb, Noun, @{
    Name        = 'Syntax'
    Expression  = {
        (Get-Help $PSItem | Out-String ) -creplace '(.|\n)*SYNTAX\n' -creplace '\n+ALIASES(.|\n)*' -replace '(?m)(\S) *\n +([^\n])', '$1 $2' -replace '(?m)\n\s+$\n', "+`n" -replace '(?m)^\s+|\s+$'
    }
} -Wrap
<#  Result of above command
Name                         Verb    Noun                    Syntax
Get-Monocle2FACode           Get     Monocle2FACode          Get-Monocle2FACode [-Secret] <string> [[-DateTime] <datetime>]
Assert-MonocleBodyValue      Assert  MonocleBodyValue        Assert-MonocleBodyValue [-ExpectedValue] <string> [-Not]
Close-MonocleBrowser         Close   MonocleBrowser          Close-MonocleBrowser [-Browser] <RemoteWebDriver[]>
New-MonocleBrowser           New     MonocleBrowser          New-MonocleBrowser [-Type] {IE | Chrome | Edge | EdgeLegacy | Firefox} [[-Timeout] <int>] [[-Arguments] <string[]>] [[-Path] <string>] [[-BinaryPath] <string>] [-Hide]
Restart-MonocleBrowser       Restart MonocleBrowser          Restart-MonocleBrowser
Install-MonocleDriver        Install MonocleDriver           Install-MonocleDriver [-Type] {IE | Chrome | Firefox} [-Version] <string>
Get-MonocleElement           Get     MonocleElement          Get-MonocleElement -Id <string> [-Scope <IWebElement>] [-WaitVisible] [-All]
                                                             Get-MonocleElement -TagName <string> [-AttributeName <string>] [-AttributeValue <string>] [-ElementValue <string>] [-Scope <IWebElement>] [-WaitVisible] [-All]
                                                             Get-MonocleElement [-XPath <string>] [-Scope <IWebElement>] [-WaitVisible] [-All]
                                                             Get-MonocleElement [-Selector <string>] [-Scope <IWebElement>] [-WaitVisible] [-All]
Measure-MonocleElement       Measure MonocleElement          Measure-MonocleElement -Id <string> [-Scope <IWebElement>]
                                                             Measure-MonocleElement -TagName <string> [-AttributeName <string>] [-AttributeValue <string>] [-ElementValue <string>] [-Scope <IWebElement>]
                                                             Measure-MonocleElement [-XPath <string>] [-Scope <IWebElement>]
                                                             Measure-MonocleElement [-Selector <string>] [-Scope <IWebElement>]
Test-MonocleElement          Test    MonocleElement          Test-MonocleElement -Id <string> [-Scope <IWebElement>]
                                                             Test-MonocleElement -TagName <string> [-AttributeName <string>] [-AttributeValue <string>] [-ElementValue <string>] [-Scope <IWebElement>]
                                                             Test-MonocleElement [-XPath <string>] [-Scope <IWebElement>]
                                                             Test-MonocleElement [-Selector <string>] [-Scope <IWebElement>]
Wait-MonocleElement          Wait    MonocleElement          Wait-MonocleElement -Id <string> [-Scope <IWebElement>] [-Timeout <int>] [-WaitVisible] [-All]
                                                             Wait-MonocleElement -TagName <string> [-AttributeName <string>] [-AttributeValue <string>] [-ElementValue <string>] [-Scope <IWebElement>] [-Timeout <int>] [-WaitVisible] [-All]
                                                             Wait-MonocleElement [-XPath <string>] [-Scope <IWebElement>] [-Timeout <int>] [-WaitVisible] [-All]
                                                             Wait-MonocleElement [-Selector <string>] [-Scope <IWebElement>] [-Timeout <int>] [-WaitVisible] [-All]
Get-MonocleElementAttribute  Get     MonocleElementAttribute Get-MonocleElementAttribute [-Element] <IWebElement> [-Name] <string>
Set-MonocleElementAttribute  Set     MonocleElementAttribute Set-MonocleElementAttribute [-Element] <IWebElement> [-Name] <string> [-Value] <string>
Test-MonocleElementAttribute Test    MonocleElementAttribute Test-MonocleElementAttribute [-Element] <IWebElement> [-Name] <string> [[-Value] <string>]
Invoke-MonocleElementCheck   Invoke  MonocleElementCheck     Invoke-MonocleElementCheck [-Element] <IWebElement> [-Uncheck]
Test-MonocleElementChecked   Test    MonocleElementChecked   Test-MonocleElementChecked [-Element] <IWebElement>
Get-MonocleElementChild      Get     MonocleElementChild     Get-MonocleElementChild [-Element] <IWebElement> [-Type] {First | Last} [[-Depth] <int>]
Measure-MonocleElementChild  Measure MonocleElementChild     Measure-MonocleElementChild [-Element] <IWebElement>
Test-MonocleElementChild     Test    MonocleElementChild     Test-MonocleElementChild [-Element] <IWebElement>
Add-MonocleElementClass      Add     MonocleElementClass     Add-MonocleElementClass [-Element] <IWebElement> [-Name] <string>
Remove-MonocleElementClass   Remove  MonocleElementClass     Remove-MonocleElementClass [-Element] <IWebElement> [-Name] <string>
Test-MonocleElementClass     Test    MonocleElementClass     Test-MonocleElementClass [-Element] <IWebElement> [-Name] <string>
Invoke-MonocleElementClick   Invoke  MonocleElementClick     Invoke-MonocleElementClick [-Element] <IWebElement> [-WaitUrl]
Get-MonocleElementCSS        Get     MonocleElementCSS       Get-MonocleElementCSS [-Element] <IWebElement> [-Name] <string>
Remove-MonocleElementCSS     Remove  MonocleElementCSS       Remove-MonocleElementCSS [-Element] <IWebElement> [-Name] <string>
Set-MonocleElementCSS        Set     MonocleElementCSS       Set-MonocleElementCSS [-Element] <IWebElement> [-Name] <string> [[-Value] <string>]
Test-MonocleElementCSS       Test    MonocleElementCSS       Test-MonocleElementCSS [-Element] <IWebElement> [-Name] <string> [[-Value] <string>]
Get-MonocleElementParent     Get     MonocleElementParent    Get-MonocleElementParent [-Element] <IWebElement> [[-Depth] <int>]
Get-MonocleElementSibling    Get     MonocleElementSibling   Get-MonocleElementSibling [-Element] <IWebElement> [-Type] {Previous | Next} [[-Depth] <int>]
Assert-MonocleElementValue   Assert  MonocleElementValue     Assert-MonocleElementValue -Id <string>
                                                             Assert-MonocleElementValue -TagName <string> [-AttributeName <string>] [-AttributeValue <string>] [-ElementValue <string>]
                                                             Assert-MonocleElementValue [-XPath <string>]
Clear-MonocleElementValue    Clear   MonocleElementValue     Clear-MonocleElementValue [-Element] <IWebElement>
Get-MonocleElementValue      Get     MonocleElementValue     Get-MonocleElementValue [-Element] <IWebElement> [-Mask]
Set-MonocleElementValue      Set     MonocleElementValue     Set-MonocleElementValue [-Element] <IWebElement> [-Value] <string> [-Mask] [-NoClear]
Test-MonocleElementVisible   Test    MonocleElementVisible   Test-MonocleElementVisible [-Element] <IWebElement>
Wait-MonocleElementVisible   Wait    MonocleElementVisible   Wait-MonocleElementVisible [-Element] <IWebElement> [[-Timeout] <int>]
Start-MonocleFlow            Start   MonocleFlow             Start-MonocleFlow -Name <string> -ScriptBlock <scriptblock> [-ScreenshotPath <string>] [-Browser <RemoteWebDriver>] [-ScreenshotOnFail] [-CloseBrowser]
Submit-MonocleForm           Submit  MonocleForm             Submit-MonocleForm [-Element] <IWebElement> [-WaitUrl]
Enter-MonocleFrame           Enter   MonocleFrame            Enter-MonocleFrame [-Element] <IWebElement> [-ScriptBlock] <scriptblock>
Get-MonocleHtml              Get     MonocleHtml             Get-MonocleHtml [[-FilePath] <string>]
Save-MonocleImage            Save    MonocleImage            Save-MonocleImage [-Element] <IWebElement> [-FilePath] <string>
Invoke-MonocleJavaScript     Invoke  MonocleJavaScript       Invoke-MonocleJavaScript [-Script] <string> [[-Arguments] <Object[]>]
Move-MonoclePage             Move    MonoclePage             Move-MonoclePage [-To {Bottom | Middle | Top}]
                                                             Move-MonoclePage [-Position <int>]
                                                             Move-MonoclePage [-Element <IWebElement>]
Get-MonoclePageSize          Get     MonoclePageSize         Get-MonoclePageSize
Invoke-MonocleRetryScript    Invoke  MonocleRetryScript      Invoke-MonocleRetryScript [-Name] <string> [-ScriptBlock] <scriptblock> [[-Attempts] <int>]
Invoke-MonocleScreenshot     Invoke  MonocleScreenshot       Invoke-MonocleScreenshot [-Name] <string> [[-Path] <string>]
Start-MonocleSleep           Start   MonocleSleep            Start-MonocleSleep [-Seconds] <int>
Get-MonocleTimeout           Get     MonocleTimeout          Get-MonocleTimeout
Set-MonocleTimeout           Set     MonocleTimeout          Set-MonocleTimeout [[-Timeout] <int>]
Edit-MonocleUrl              Edit    MonocleUrl              Edit-MonocleUrl [-Pattern] <string> [-Value] <string> [-Force]
Get-MonocleUrl               Get     MonocleUrl              Get-MonocleUrl
Set-MonocleUrl               Set     MonocleUrl              Set-MonocleUrl [-Url] <string> [-Force]
Wait-MonocleUrl              Wait    MonocleUrl              Wait-MonocleUrl -Url <string> [-StartsWith]
                                                             Wait-MonocleUrl -Pattern <string>
Wait-MonocleUrlDifferent     Wait    MonocleUrlDifferent     Wait-MonocleUrlDifferent [-FromUrl] <string>
Wait-MonocleValue            Wait    MonocleValue            Wait-MonocleValue -Value <string>
                                                             Wait-MonocleValue -Pattern <string>
#>

Get-Command -Module Selenium | Get-Help | Format-Table Name,SYNOPSIS

Get-Command -Module Selenium| Sort-Object Noun, Verb | Format-Table Name, Verb, Noun, @{
    Name        = 'Synopsis'
    Expression  = {
        (Get-Help $PSItem).Synopsis
    }
}, @{
    Name        = 'Syntax'
    Expression  = {
        (Get-Help $PSItem | Out-String ) -creplace '(.|\n)*SYNTAX\n' -creplace '\n+[A-Z]{4}(.|\n)*' -replace '(?m)(\S) *\n +([^\n])', '$1 $2' -replace '(?m)\n\s+$\n', "+`n" -replace '(?m)^\s+|\s+$'
    }
} -Wrap | Out-String -Width 4096 | Set-Clipboard
<#   Result of above command
Name                   Verb   Noun               Synopsis                                                               Syntax
SeShouldHave                                                                                                            SeShouldHave [-Selection] <string[]> [-By <string>] [-PassThru] [-Timeout <double>] [<CommonParameters>]
                                                                                                                        SeShouldHave [-Selection] <string[]> [-With] <string> [[-Operator] {like | notlike | match | notmatch | contains | eq | ne | gt | lt}] [[-Value] <Object>] [-By <string>] [-PassThru] [-Timeout <double>] [<CommonParameters>]
                                                                                                                        SeShouldHave [[-Operator] {like | notlike | match | notmatch | contains | eq | ne | gt | lt}] [[-Value] <Object>] -Alert [-PassThru] [-Timeout <double>] [<CommonParameters>]
                                                                                                                        SeShouldHave -NoAlert [-Timeout <double>] [<CommonParameters>]
                                                                                                                        SeShouldHave [[-Operator] {like | notlike | match | notmatch | contains | eq | ne | gt | lt}] [-Value] <Object> -Title [-Timeout <double>] [<CommonParameters>]
                                                                                                                        SeShouldHave [[-Operator] {like | notlike | match | notmatch | contains | eq | ne | gt | lt}] [-Value] <Object> -URL [-Timeout <double>] [<CommonParameters>]
Clear-SeAlert          Clear  SeAlert            Clear alert popup by dismissing or accepting it.                       Clear-SeAlert [-Action {Accept | Dismiss}] [-Alert <Object>] [-PassThru] [<CommonParameters>]
Invoke-SeClick         Invoke SeClick            Perform a click in the browser window or specified element.            Invoke-SeClick [[-Action] <Object>] [[-Element] <IWebElement>] [-PassThru] [-Sleep <Double>] [<CommonParameters>]
Get-SeCookie           Get    SeCookie           List all cookies                                                       Get-SeCookie [<CommonParameters>]
Remove-SeCookie        Remove SeCookie           Delete the named cookie from the current domain                        Remove-SeCookie -All [<CommonParameters>]
                                                                                                                        Remove-SeCookie -Name <String> [<CommonParameters>]
Set-SeCookie           Set    SeCookie           Add a cookie to the current browsing context                           Set-SeCookie [[-Name] <String>] [[-Value] <String>] [[-Path] <String>] [[-Domain] <String>] [[-ExpiryDate] <DateTime>] [<CommonParameters>]
Get-SeDriver           Get    SeDriver           Get the list of all active drivers.                                    Get-SeDriver [-Browser <Object>] [<CommonParameters>]
                                                                                                                        Get-SeDriver [-Current] [<CommonParameters>]
                                                                                                                        Get-SeDriver [[-Name] <String>] [<CommonParameters>]
Start-SeDriver         Start  SeDriver           Launch the specified browser.                                          Start-SeDriver [[-StartURL] <String>] [-AcceptInsecureCertificates] [-Arguments <String[]>] [-BinaryPath <Object>] [-Browser <Object>] [-DefaultDownloadPath <FileInfo>] [-ImplicitWait <Double>] [-LogLevel {All | Debug | Info | Warning | Severe | Off}] [-Name <Object>] -Options <DriverOptions> [-Position <Point>] [-PrivateBrowsing] [-ProfilePath <Object>] [-Service <DriverService>] [-Size <Size>] [-State {Headless | Default | Minimized | Maximized | Fullscreen}] [-UserAgent <String>] [-WebDriverPath <Object>] [<CommonParameters>]
                                                                                                                        Start-SeDriver [[-StartURL] <String>] [-AcceptInsecureCertificates] [-Arguments <String[]>] [-BinaryPath <Object>] [-Browser <Object>] [-DefaultDownloadPath <FileInfo>] [-ImplicitWait <Double>] [-LogLevel {All | Debug | Info | Warning | Severe | Off}] [-Name <Object>] [-Position <Point>] [-PrivateBrowsing] [-ProfilePath <Object>] [-Size <Size>] [-State {Headless | Default | Minimized | Maximized | Fullscreen}] [-Switches <String[]>] [-UserAgent <String>] [-WebDriverPath <Object>] [<CommonParameters>]
Stop-SeDriver          Stop   SeDriver           Quits this driver, closing every associated window.                    Stop-SeDriver [[-Driver] <IWebDriver>] [<CommonParameters>]
Switch-SeDriver        Switch SeDriver           Select a driver, making it the default to be used with any ulterior    Switch-SeDriver [-Driver] <IWebDriver> [<CommonParameters>]
                                                     calls whenever the driver parameter is not specified.              Switch-SeDriver [-Name] <String> [<CommonParameters>]
Update-SeDriver        Update SeDriver                                                                                  Update-SeDriver [[-Browser] <Object>] [[-OS] {Linux | Mac | Windows}] [[-Path] <Object>] [<CommonParameters>]
Wait-SeDriver          Wait   SeDriver           Wait for the driver to be in the desired state.                        Wait-SeDriver [-Condition] <Object> [-Value] <Object> [[-Timeout] <Double>] [<CommonParameters>]
New-SeDriverOptions    New    SeDriverOptions    Create a driver options object that can be used with `Start-SeDriver`  New-SeDriverOptions [[-StartURL] <String>] [-AcceptInsecureCertificates] [-Arguments <String[]>] [-BinaryPath <Object>] [-Browser <Object>] [-DefaultDownloadPath <FileInfo>] [-ImplicitWait <Double>] [-LogLevel {All | Debug | Info | Warning | Severe | Off}] [-Position <Point>] [-PrivateBrowsing] [-ProfilePath <Object>] [-Size <Size>] [-State <Object>] [-Switches <String[]>] [-UserAgent <String>] [-WebDriverPath <Object>] [<CommonParameters>]
New-SeDriverService    New    SeDriverService    Create an instance of WebDriver service to be used with Start-SeDriver New-SeDriverService [-Browser <Object>] [-WebDriverPath <Object>] [<CommonParameters>]
Get-SeDriverTimeout    Get    SeDriverTimeout    Get the specified driver timeout value.                                Get-SeDriverTimeout [[-TimeoutType] {ImplicitWait | PageLoad | AsynchronousJavaScript}] [<CommonParameters>]
Set-SeDriverTimeout    Set    SeDriverTimeout    Set the various driver timeouts default.                               Set-SeDriverTimeout [[-TimeoutType] {ImplicitWait | PageLoad | AsynchronousJavaScript}] [[-Timeout] <Double>] [<CommonParameters>]
Get-SeElement          Get    SeElement          Finds all IWebElements within the current context using the given      Get-SeElement [-Value] <String[]> [-Element] <IWebElement> [-All] [-Attributes <String[]>] [-By {ClassName | CssSelector | Id | LinkText | PartialLinkText | Name | TagName | XPath}] [-Filter <ScriptBlock>] [-Single] [<CommonParameters>]
                                                     mechanism                                                          Get-SeElement [-Value] <String[]> [[-Timeout] <Double>] [-All] [-Attributes <String[]>] [-By {ClassName | CssSelector | Id | LinkText | PartialLinkText | Name | TagName | XPath}] [-Filter <ScriptBlock>] [-Single] [<CommonParameters>]
Wait-SeElement         Wait   SeElement          Wait for an element condition to be met.                               Wait-SeElement [[-By] {ClassName | CssSelector | Id | LinkText | PartialLinkText | Name | TagName | XPath}] [-Value] <String> [-Condition <Object>] [-ConditionValue <Object>] [-Timeout <Double>] [<CommonParameters>]
                                                                                                                        Wait-SeElement [-Condition <Object>] [-ConditionValue <Object>] -Element <IWebElement> [-Timeout <Double>] [<CommonParameters>]
Get-SeElementAttribute Get    SeElementAttribute Get the specified attribute from the specified element.                Get-SeElementAttribute [-Element] <IWebElement> [-Name] <String[]> [<CommonParameters>]
Get-SeElementCssValue  Get    SeElementCssValue  Get CSS value for the specified name of targeted element.              Get-SeElementCssValue [-Element] <IWebElement> [-Name] <String[]> [<CommonParameters>]
Get-SeFrame            Get    SeFrame                                                                                   Get-SeFrame [<CommonParameters>]
Switch-SeFrame         Switch SeFrame            Instructs the driver to send future commands to a different frame      Switch-SeFrame [-Frame] <Object> [<CommonParameters>]
                                                                                                                        Switch-SeFrame -Parent [<CommonParameters>]
                                                                                                                        Switch-SeFrame -Root [<CommonParameters>]
Get-SeHtml             Get    SeHtml             Get outer html of the specified element or driver.                     Get-SeHtml [[-Element] <IWebElement>] [-Inner] [<CommonParameters>]
Get-SeInput            Get    SeInput            Get element with an input tagname matching the specified conditions.   Get-SeInput [[-Type] <String>] [[-Text] <String>] [[-Timeout] <Double>] [[-Attributes] <String[]>] [[-Value] <String>] [-All] [-Single] [<CommonParameters>]
Invoke-SeJavascript    Invoke SeJavascript       Invoke Javascript in the specified Driver.                             Invoke-SeJavascript [[-Script] <String>] [[-ArgumentList] <Object[]>] [<CommonParameters>]
Get-SeKeys             Get    SeKeys             Return a list of the available special keys                            Get-SeKeys [<CommonParameters>]
Invoke-SeKeys          Invoke SeKeys             Send the keys to the browser or specified element.                     Invoke-SeKeys [[-Element] <IWebElement>] [-Keys] <String> [-ClearFirst] [-PassThru] [-Sleep <Double>] [-Submit] [<CommonParameters>]
Invoke-SeMouseAction   Invoke SeMouseAction      Perform mouse move & drag actions.                                     Invoke-SeMouseAction [[-Action] <Object>] [[-Value] <Object>] [[-Element] <IWebElement>] [<CommonParameters>]
Start-SeRemote         Start  SeRemote           Start a remote driver session.                                         Start-SeRemote [[-StartURL] <String>] [-DesiredCapabilities <Hashtable>] [-ImplicitWait <Double>] [-Position <Point>] [-RemoteAddress <String>] [-Size <Size>] [<CommonParameters>]
New-SeScreenshot       New    SeScreenshot       Take a screenshot of the current page                                  New-SeScreenshot [-AsBase64EncodedString] [-Element <IWebElement>] [<CommonParameters>]
                                                                                                                        New-SeScreenshot [-AsBase64EncodedString] [-InputObject <Object>] [<CommonParameters>]
Save-SeScreenshot      Save   SeScreenshot       Save a screenshot on the disk.                                         Save-SeScreenshot -Element <IWebElement> [-ImageFormat {Png | Jpeg | Gif | Tiff | Bmp}] -Path <String> [<CommonParameters>]
                                                                                                                        Save-SeScreenshot [-ImageFormat {Png | Jpeg | Gif | Tiff | Bmp}] [-InputObject <Object>] -Path <String> [<CommonParameters>]
                                                                                                                        Save-SeScreenshot [-ImageFormat {Png | Jpeg | Gif | Tiff | Bmp}] -Path <String> -Screenshot <Screenshot> [<CommonParameters>]
Clear-SeSelectValue    Clear  SeSelectValue      Clear all selected entries of a SELECT element.                        Clear-SeSelectValue [-Element] <IWebElement> [<CommonParameters>]
Get-SeSelectValue      Get    SeSelectValue      Get Select element selected value.                                     Get-SeSelectValue [-Element] <IWebElement> [-All] [<CommonParameters>]
Set-SeSelectValue      Set    SeSelectValue      Set Select element selected value.                                     Set-SeSelectValue [-Element] <IWebElement> [-By {Index | Text | Value}] [-value <Object>] [<CommonParameters>]
Get-SeUrl              Get    SeUrl              Retrieves the current URL of a target webdriver instance.              Get-SeUrl [-Stack] [<CommonParameters>]
Pop-SeUrl              Pop    SeUrl              Navigate back to the most recently pushed URL in the location stack.   Pop-SeUrl [<CommonParameters>]
Push-SeUrl             Push   SeUrl              Stores the current URL in the driver's location stack and optionally   Push-SeUrl [[-Url] <String>] [<CommonParameters>]
                                                     navigate to a new URL.
Set-SeUrl              Set    SeUrl              Navigates to the targeted URL with the selected or default driver.     Set-SeUrl [<CommonParameters>]
                                                                                                                        Set-SeUrl [-Url] <String> [<CommonParameters>]
                                                                                                                        Set-SeUrl -Back [-Depth <Int32>] [<CommonParameters>]
                                                                                                                        Set-SeUrl -Forward [[-Depth] <Int32>] [<CommonParameters>]
                                                                                                                        Set-SeUrl -Refresh [<CommonParameters>]
Get-SeWindow           Get    SeWindow           Gets the window handles of open browser windows                        Get-SeWindow [<CommonParameters>]
New-SeWindow           New    SeWindow                                                                                  New-SeWindow [[-Url] <Object>] [<CommonParameters>]
Remove-SeWindow        Remove SeWindow                                                                                  Remove-SeWindow [[-SwitchToWindow] <String>] [<CommonParameters>]
Switch-SeWindow        Switch SeWindow           Instructs the driver to send future commands to a different window     Switch-SeWindow [-Window] <Object> [<CommonParameters>]
#>


#Region TestMonocle

# Get the latest Selenium WebDriver version for updating
$GetDriver = 'Selenium.WebDriver.GeckoDriver'
$GetDriver = 'Selenium.WebDriver.MSEdgeDriver'
$GetDriver = 'Selenium.WebDriver.ChromeDriver'

$GetDriverVersion = nuget search $GetDriver -Take 1
$GetDriverVersion = $GetDriverVersion -Match $GetDriver -split ' | ' | Select-Object -First 1 -Skip 1

# Update/install driver
Install-MonocleDriver -Type Chrome -Version $GetDriverVersion -Verbose

Push-Location /Users/nathanrandall/.local/share/powershell/Modules/Monocle/1.3.4/lib/Browsers/mac
Rename-Item -Path 'chromedriver' -NewName 'chromedriver.85' #Update to correct version
Copy-Item -Path ../../../custom_drivers/mac/chromedriver -Destination .
Pop-Location


# create a browser
$browser = New-MonocleBrowser -Type Chrome
$browser = New-MonocleBrowser -Type Chrome -Path /Users/nathanrandall/.local/share/powershell/Modules/Monocle/1.3.4/custom_drivers/mac/chromedriver

# Monocle runs commands in web flows, for easy disposal and test tracking
Start-MonocleFlow -Name 'Load YouTube' -Browser $browser -ScriptBlock {

    # tell the browser which URL to navigate to, will wait for the page to load
    Set-MonocleUrl -Url 'https://www.youtube.com'

    # sets the element's value, selecting the element by ID/Name
    Get-MonocleElement -Id 'search_query' | Set-MonocleElementValue -Value 'Beerus Madness (Extended)'

    # click the search button
    Get-MonocleElement -Id 'search-icon-legacy' | Invoke-MonocleElementClick

    # wait for the URL to change to start with the following value
    Wait-MonocleUrl -Url 'https://www.youtube.com/results?search_query=' -StartsWith

    # downloads an image from the page, selcted by using an XPath to an element
    Get-MonocleElement -XPath "//div[@data-context-item-id='SI6Yyr-iI6M']/img[1]" | Save-MonocleImage -FilePath '.\beerus.jpg'

    # tells the browser to click the video in the results
    Get-MonocleElement -XPath "//a[@title='Dragon Ball Super Soundtrack - Beerus Madness (Extended)']" | Invoke-MonocleElementClick

    # wait for the URL to be loaded
    Wait-MonocleUrl -Url 'https://www.youtube.com/watch?v=SI6Yyr-iI6M'

}

# dispose the browser
Close-MonocleBrowser -Browser $browser


Set-MonocleUrl -Url 'https://emojipedia.org/smileys'
Get-MonocleElement -Selector '.scroll-mt-[140px]'
Get-MonocleElement -Id 'tongues-hands-accessories'

Get-MonocleElement -Selector 'Emoji_emoji__vbZHi __variable_e5a5aa' | Get-MonocleElementValue


#EndRegion TestMonocle


#Region TestSelenium

Update-SeDriver -Browser Chrome -OS Mac -Verbose

$Url = 'https://emojipedia.org'
Start-SeDriver -Browser Chrome -Options $Options

$Options = [OpenQA.Selenium.Chrome.ChromeOptions]::new(
)
$Options.AddExtensions(
    '/Users/nathanrandall/GitHub/PowerShellFunctions/Extensions/Privacy_Badger.crx',
    '/Users/nathanrandall/GitHub/PowerShellFunctions/Extensions/uBlock_Origin_Lite.crx'
)

Set-SeUrl $Url

# Hover over the first emoji to show category names
$UseMe = Get-SeElement -By ClassName 'List_navbar-list-item__0o_cL' | Select-Object -First 1
Invoke-SeMouseAction MoveToElement -Element $UseMe

# Get categories
$Categories = Get-SeElement -By ClassName 'List_navbar-list-item__0o_cL' | Get-SeElement -By TagName a | ForEach-Object {
    [PSCustomObject]@{
        Category      = ($PSItem | Get-SeElement -By TagName span).Text
        Icon          = $PSItem.text -replace '\n.*'
        Url           = $_.GetAttribute('href')
        Subcategories = @()
    }
}
$Categories

# Parse subcategories
$ErrorActionPreference = 'Stop'
$TheEmoji = foreach ($Category in $Categories) {
    Write-Host "`nProcessing category: $($Category.Category)" -ForegroundColor Cyan -NoNewline
    Set-SeUrl -Url $Category.Url
    Start-Sleep 1

    # Get subcategories
    try {
        $Subgroups = Get-SeElement -By ClassName 'scroll-mt-[140px]'
    }
    catch {
        Start-Sleep -Seconds 3
        $Subgroups = Get-SeElement -By ClassName 'scroll-mt-[140px]'
    }

    foreach ($Subgroup in $Subgroups) {
        $SubCategory = $Subgroup | Get-SeElement -By TagName h2 | Select-Object -ExpandProperty Text
        Write-Host "`nProcessing subcategory: $SubCategory" -ForegroundColor Green

        # Get the emoji
        $Subgroup | Get-SeElement -By TagName a | ForEach-Object {
            $Values = $PSItem | Get-SeElementAttribute -Name href,aria-label,aria-describedBy
            [PSCustomObject]@{
                Icon        = $PSItem.Text
                Name        = $Values.'aria-label'
                AlsoKnownAs = $null
                Category   = $Category.Category
                SubCategory = $SubCategory
                Meaning     = $null
                SeeAlso     = $null
                Url         = $Values.href
                VaryColor   = $false
                VaryGender  = $false
            }
            Write-Host -NoNewline $PSItem.Text
        }
        ''
    }

}
$TheEmoji = $TheEmoji | Where-Object Name
"Count is " + $TheEmoji.Count


# Get emoji details
for ($i = 0; $i -lt $TheEmoji.Count; $i++) {
    $Emoji = $TheEmoji[$i]
    Write-Host -ForegroundColor Green "`t$($Emoji.Icon)" -NoNewline
    try {
        Set-SeUrl -Url $Emoji.Url -ErrorAction Stop
        Start-Sleep -Milliseconds 500

        # Get emoji details
        $MeaningDiv     = Get-SeElement -By TagName section | Get-SeElement -By ClassName 'HtmlContent_html-content-container__a8A4K'
        $MeaningPs      = $MeaningDiv | Get-SeElement -By TagName p | Where-Object Text -NotMatch '^See also:'
        $Meaning        = $MeaningPs.Text -join "`n`n"
        if ($Meaning) {
            $Emoji.Meaning = $Meaning
        }
        $SeeAlso        = $MeaningDiv | Get-SeElement -By TagName p | Where-Object Text -Match '^See also:'
        $SeeAlsoText    = $SeeAlso.Text -replace '^See also:\s*'
        $SeeAlsoEmoji   = ($SeeAlso | Get-SeElement -By TagName a).Text -replace '\s.*'
        if ($SeeAlsoText) {
            $Emoji.SeeAlso = [PSCustomObject]@{
                Emoji = $SeeAlsoEmoji
                Text  = $SeeAlsoText
            }
        }

        Get-SeElement -By LinkText 'Technical Information' | Invoke-SeClick
        $AKA = Get-SeElement -By ClassName 'Table_table-tr__QVFqS' | Where-Object Text -Match '^Also Known As' | Get-SeElement -By TagName div -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Text
        if ($AKA) {
            $Emoji.AlsoKnownAs = $AKA -split ',\s*'
        }

        # Get variants
        $Variants = Get-SeElement -By TagName div | Where-Object Text -Like 'Related Emoji' | Get-SeElement -By TagName a | Get-SeElementAttribute -Name class
        if ($Variants -match 'ColorSkin') {
            Write-Host -NoNewline (" 🎨 {0}{1}{2}" -f $PSStyle.Foreground.FromRgb(210,180,140), ($Variants -match 'ColorSkin').Count, $PSStyle.Reset)
            $Emoji.VaryColor = $true
        }
        if ($Variants -match 'Gender') {
            Write-Host -NoNewLine (" ⚧️  {0}{1}{2}" -f $PSStyle.Foreground.FromRgb(221,160,221), ($Variants -match 'Gender').Count, $PSStyle.Reset)
            $Emoji.VaryGender = $true
        }
        Start-Sleep -Milliseconds 50
    }
    catch {
        $PSItem
        Write-Host -ForegroundColor Magenta $i $Emoji.Icon $Emoji.Name
    }
}

$ErrorActionPreference = $Continue





for ($i = 1126; $i -lt $TheEmoji.Count; $i++) {
    Set-SeUrl -Url $TheEmoji[$i].Url
    Write-Host -ForegroundColor Green "`n$i`t" $TheEmoji[$i].Icon -NoNewline
    try {
        $Variants = Get-SeElement -By TagName div | Where-Object Text -Like 'Related Emoji' | Get-SeElement -By TagName a | Get-SeElementAttribute -Name class
        if ($Variants -match 'ColorSkin') {
            Write-Host -NoNewline ("`t🎨 {0}{1}{2}" -f $PSStyle.Foreground.FromRgb(210,180,140), ($Variants -match 'ColorSkin').Count, $PSStyle.Reset)
        }
        if ($Variants -match 'Gender') {
            Write-Host -NoNewLine ("`t⚧️  {0}{1}{2}" -f $PSStyle.Foreground.FromRgb(221,160,221), ($Variants -match 'Gender').Count, $PSStyle.Reset)
        }
        if ($Variants -notmatch 'ColorSkin|Gender') {
            $Variants -notmatch 'ColorSkin|Gender'
            Write-Host -ForegroundColor Yellow $i
            $i = 2000
        }
        Start-Sleep 1

    }
    catch {
        $i = 2000
        $PSItem
    }
}


#EndRegion TestSelenium




#Region GetBrands
$RootURL = 'https://brands.evolutionconceptshow.com/'


$Options = [OpenQA.Selenium.Chrome.ChromeOptions]::new()
$Options.AddExtensions(
    '/Users/nathanrandall/GitHub/PowerShellFunctions/Extensions/Privacy_Badger.crx',
    '/Users/nathanrandall/GitHub/PowerShellFunctions/Extensions/uBlock_Origin_Lite.crx'
)
Start-SeDriver -Browser Chrome -Options $Options -Verbose

Set-SeUrl $RootURL

$Brands = Get-SeElement -By ClassName brand_list_flex | Get-SeElement -By TagName a | ForEach-Object {
    [PSCustomObject]@{
        Name = $PSItem.Text
        ThisUrl  = $PSItem.GetAttribute('href')
        Url  = ''
    }
}

$Brand = $Brands[0]
foreach ($Brand in $Brands) {
    Set-SeUrl $Brand.ThisUrl
    $Link = Get-SeElement -By ClassName visit-website-link
    $Brand.Url = $Link.GetAttribute('href')
}


$Brands | Select-Object Name, Url | ConvertTo-Csv -Delimiter "`t" | Set-Clipboard


Set-SeUrl 'https://www.evolutionconceptshow.com/augustnewyork'
Set-SeUrl 'https://www.evolutionconceptshow.com/augustsf'
$Brands = Get-SeElement -By ClassName margin-wrapper | Where-Object Text | ForEach-Object {
    [PSCustomObject]@{
        Name = $PSItem | Get-SeElement -By ClassName image-slide-title | Select-Object -ExpandProperty Text
        Url  = ($PSItem | Get-SeElement -By TagName a).GetAttribute('href')
    }
} | Sort-Object Name

$Brands | ConvertTo-Csv -Delimiter "`t" -NoHeader | Set-Clipboard

#EndRegion GetBrands


Stop-SeDriver
Start-SeDriver -Browser Chrome -StartURL 'https://www.addictionnouvellelingerie.com/collections/shop-underwire'

$Collection = [System.Collections.Generic.List[Object]]::new()

do {
    Get-SeElement -By ClassName grid-product__content | Get-SeElement -By TagName a | ForEach-Object {
        $Collection.Add(( [PSCustomObject]@{
            Name = $PSItem | Get-SeElement -By ClassName grid-product__title | Select-Object -ExpandProperty Text
            URL = $PSItem.GetAttribute('href')
        } ))
    }
    $Next = Get-SeElement -By ClassName next -ErrorAction SilentlyContinue
    if ($Next) {
        $Next.Click()
    }

} while (
    $Next
)

$Collection | Group-Object {$PSItem.Name.Split(' ')[0]} | Format-Table -AutoSize
