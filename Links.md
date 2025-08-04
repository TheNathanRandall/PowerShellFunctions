# Useful Links

Reference links that I started to collect, as I got tired of re-googling the same ones again and again.

## PowerShell Console

* Colors
    * [Using `$PSStyle` and ANSI sequences](https://4sysops.com/archives/using-powershell-with-psstyle/)
    * [In-depth on ANSI sequences](https://stackoverflow.com/questions/4842424/list-of-ansi-color-escape-sequences)
        * ```
          "`e[1mBold Text`e[0m"
          "`e[1;3;4mBold Italic Underline Text`e[0m"
          "`e[38;2;255;165;0mOrange via RGB Text`e[0m"
          "`e[38;5;208mOrange via 256 color number Text`e[0m"
          "`e[37;48;5;57mWhite Text on Purple Background`e[0m"
          ```
          will display:
        * ![image](https://github.com/user-attachments/assets/f2d27922-18ac-44e4-9954-884773aeecc9)
* [Rosetta Code](https://rosettacode.org/wiki/Category:PowerShell)
* [About...](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about)
* Best simplified explanation of [the -f format operator](https://ss64.com/ps/syntax-f-operator.html)
* Full [.NET API Browser](https://learn.microsoft.com/en-us/dotnet/api/)
* [Proxy Commands](https://devblogs.microsoft.com/powershell/extending-andor-modifing-commands-with-proxies/)
    * Simplified to two lines:
      `$metadata = New-Object system.management.automation.commandmetadata (Get-Command Get-Process)`
      `[System.management.automation.proxycommand]::Create($MetaData)`
* Go deeeep [PowerShell-Docs/reference/docs-conceptual/developer/cmdlet](https://github.com/MicrosoftDocs/PowerShell-Docs/tree/main/reference/docs-conceptual/developer/cmdlet)
* Get [MIME Types](https://github.com/t3hn3rd/PSMimeTypes)
* [PoshFunctions](https://github.com/riedyw/PoshFunctions)
* [Encrypt passwords](https://thesysadminchannel.com/passwords-in-scripts-the-ultimate-best-practice-guide/) (old)

# Graph

* [Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer)
* [Query parameters](https://learn.microsoft.com/en-us/graph/query-parameters)
* [Filter parameter](https://learn.microsoft.com/en-us/graph/filter-query-parameter)
* [Advanced query by object](https://learn.microsoft.com/en-us/graph/aad-advanced-queries)

## Workday

* [Get custom data / custom fields](https://sglmr.com/blog/post/how-to-include-custom-data-with-workday-get-workers-requests/)
* [PowerShell module](https://github.com/GaryOlivieri/PS_WorkdayAPI)
* [SOAP API](https://community.workday.com/sites/default/files/file-hosting/productionapi/)
    * [Human Resources](https://community.workday.com/sites/default/files/file-hosting/productionapi/Human_Resources/v44.0/Human_Resources.html) - Verify version
    * [Get_Workers](https://community.workday.com/sites/default/files/file-hosting/productionapi/Human_Resources/v44.0/Get_Workers.html) - Verify version
* [REST API](https://community.workday.com/sites/default/files/file-hosting/restapi/index.html)
    * [How to use](https://www.getknit.dev/blog/workday-api-integration-in-depth)
* Useful references
    * XPaths for many [User Attributes](https://www.netiq.com/documentation/identity-manager-48-drivers/workday/data/t4avmq7bukne.html)
    * Microsoft Entra ID [Workday attribute reference](https://learn.microsoft.com/en-us/entra/identity/app-provisioning/workday-attribute-reference)
* XPath
    * Online testers [Xpather](https://xpather.com/) and [FreeFormatter](https://www.freeformatter.com/xpath-tester.html)
    * [CheatSheet](https://devhints.io/xpath) and [speedrun howto](https://www.stationx.net/xpath-cheat-sheet/)
    * [Very basic howto](https://www.w3schools.com/xml/xpath_intro.asp)

## Other stuff

* VSCode extensions
   * [Code Spell Checker](https://marketplace.visualstudio.com/items/?itemName=streetsidesoftware.code-spell-checker)
   * [Quote Flipper](https://marketplace.visualstudio.com/items/?itemName=allenshuber.quote-flipper)
   * [Edit CSV](https://marketplace.visualstudio.com/items/?itemName=janisdd.vscode-edit-csv) and [Rainbow CSV](https://marketplace.visualstudio.com/items/?itemName=mechatroner.rainbow-csv)
   * [XML Tools](https://marketplace.visualstudio.com/items/?itemName=DotJoshJohnson.xml) for XPath testing
   * [HTML CSS Support](https://marketplace.visualstudio.com/items/?itemName=ecmel.vscode-html-css) and [HTML Preview](https://marketplace.visualstudio.com/items/?itemName=george-alisson.html-preview-vscode)
* MIME types
    * [Mozilla](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/MIME_types/Common_types)
    * [FreeFormatter](https://www.freeformatter.com/mime-types-list.html)
