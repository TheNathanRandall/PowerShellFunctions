<#PSScriptInfo

.VERSION 1.0

.GUID 0d82a368-b1a6-42d1-bddd-613c5e3f2047

.AUTHOR Nathan Randall

.COMPANYNAME 

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

#Requires -Module ExchangeOnlineManagement
#Requires -Module Microsoft.Graph

<# 

.SYNOPSIS
    Processes worker updates and terminations from Workday into AD, Entra, and Exchange

.DESCRIPTION 
    Gets updated workers from Workday
    Updates properties on updated worker accounts
    For terminated workers:
        Disables AD account
        Updates AD properties
        Removes group memberships, MFA, and more

.PARAMETER DoNotUseWorkdayAPI
    Use SFTP with WinSCP instead of Workday API to get workers

.PARAMETER WorkdayURI
    Workday HumanResources URI for WorkdayAPI

.PARAMETER WorkdayUser
    User ID for WorkdayAPI

.PARAMETER WorkdayPass
    User password for WorkdayAPI

.PARAMETER TranscriptPath
    Path to transcript files

.PARAMETER ReportPath
    Path ro report files

.PARAMETER CSVPath
    Path to save and import CSV files when using SFTP

.PARAMETER ClearReportsAfterDays
    Delete reports older than this many days

.PARAMETER ClearTranscriptsAfterDays
    Delete transcripts older than this many days

.PARAMETER ClearCSVsAfterDays
    Delete CSVs older than this many days

.PARAMETER SFTPPass
    Password for SFTP connection

#> 

[CmdletBinding()]
param (
    [Parameter()]
    [Alias('NoWorkday')]
    [switch]
    $DoNotUseWorkdayAPI,
    [Parameter()]
    [string]
    $WorkdayURI = 'https://impl-services1.wd103.myworkday.com/ccx/service/COMPANY3/Human_Resources/v44.1',
    [Parameter()]
    [string]
    $WorkdayUser,
    [Parameter()]
    [System.Security.SecureString]
    $WorkdayPass,

    [Parameter()]
    [string]
    $TranscriptPath = "$PSScriptRoot\TransLogsProvisioning" <# 'C:\TransLogs\Provisioning' #>,
    [Parameter()]
    [string]
    $ReportPath = "$PSScriptRoot\Reports" <# 'C:\Reports' #>,
    [Parameter()]
    [string]
    $CSVPath = "$PSScriptRoot\WD_CSVs" <# 'C:\WD\FromWD\' #>,
    
    [Parameter()]
    [Int]
    $ClearReportsAfterDays = 61, # About 2 months
    [Parameter()]
    [Int]
    $ClearTranscriptsAfterDays = 182, # About 6 months
    [Parameter()]
    [Int]
    $ClearCSVsAfterDays = 182, # About 6 months
    
    [Parameter()]
    [string]
    $SFTPPass
)

#Region Setup




#Region Functions
# Build a couple of functions to use
function New-Password {
    [CmdletBinding()]
    param (
        # Length of password in characters
        [Parameter()]
        [Alias('Length')]
        [ValidateRange(8, 64)]
        [int]
        $PasswordLength = 20,
        # Characters to use: default is all valid ASCII characters
        [Parameter()]
        [Alias('Characters', 'Chars')]
        [char[]]
        $PasswordCharacters = [char[]](32..126),
        # Return the password as plain text instead of (default) secure string
        [Parameter()]
        [switch]
        $AsPlainText,
        # Will write the password to the host as well as return it
        [Parameter()]
        [switch]
        $WriteToConsole
    )
    
    begin {
        # Make sure the characters are ones allowed in passwords
        $IllegalChars = $PasswordCharacters | Where-Object { $PSItem -notin [char[]](32..126) }
        if ($IllegalChars) {
            throw "Character(s) $($IllegalChars -join ' ') [ASCII decimal(s) $([int[]]$IllegalChars -join ' ')] in -PasswordCharacters`nOnly characters $(-join [char[]](32..126)) and space are allowed."
            exit
        }
    }
    
    process {
        Write-Verbose 'Generating random password'
        do {
            # Get two each of all characters, then pick at random
            $NewPass = $PasswordCharacters + $PasswordCharacters | Get-Random -Count $PasswordLength
            # Join them together in a string
            $NewPass = -join $NewPass
        } until (
            # If it starts with a non-letter or it ends with a space, try again till it does not
            $NewPass -match '^[a-z].+[^\s]'
        )
    
        if ($WriteToConsole) {
            Write-Host 'new password is' $NewPass
        }
    
        # Convert to a secure string unless specified otherwise
        if (-not $AsPlainText) {
            $NewPass = ConvertTo-SecureString -AsPlainText -Force -String $NewPass
        }
    }
    
    end {
        $NewPass
    }
}
function Save-Results {
    param ()
    $ResultObject | ConvertTo-Json -Depth 4 | Out-File -FilePath $ResultFile
}

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
        $A = New-Object psobject -Prop ([ordered] @{ One = 1; Two = 2})
        $B = New-Object psobject -Prop ([ordered] @{ One = 1; Two = 2; Three = 3})
    
        Compare-Object $A $B
    
        # would return $null because it only compares the properties that have common names but
    
        Compare-ObjectProperty $A $B
    
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
        $ObjProps = New-Object -TypeName System.Collections.ArrayList
    }
    
    process {
        $null = $ObjProps.AddRange(($ReferenceObject | Get-Member -MemberType Property, NoteProperty).Name)
        $null = $ObjProps.AddRange(($DifferenceObject | Get-Member -MemberType Property, NoteProperty).Name)
        # Old way would consider property name uniqueness including capitalization
        # $ObjProps = $ObjProps | Sort-Object | Select-Object -Unique 
        # New way is case-insensitive
        $ObjProps = $ObjProps | Sort-Object -Unique
        $Diffs = New-Object -TypeName System.Collections.ArrayList
        foreach ($ObjProp in $ObjProps) {
            $Diff = Compare-Object -ReferenceObject $ReferenceObject -DifferenceObject $DifferenceObject -Property $ObjProp
            if ($Diff) {
                $DiffProps = @{
                    PropertyName = $ObjProp
                    StartValue   = ($Diff | Where-Object { $_.SideIndicator -eq '<=' } | ForEach-Object $($ObjProp))
                    EndValue     = ($Diff | Where-Object { $_.SideIndicator -eq '=>' } | ForEach-Object $($ObjProp))
                }
                $null = $Diffs.Add((New-Object -TypeName PSObject -Property $DiffProps))
            }
        }
        if ($Diffs) {
            $Diffs | Select-Object -Property PropertyName, StartValue, EndValue
        }
    }
    
    end {
        Write-Verbose -Message "Ending [$($MyInvocation.MyCommand)]"
    }
    
}

function Send-GraphMailMessage {
    [CmdletBinding()]
    param (
        # Plain text body. String arrays will be joined with NewLine.
        [Parameter(ParameterSetName = 'TextBody', Mandatory = $true)]
        [Alias('Text', 'Body')]
        [string[]]
        # HTML body. String arrays will be joined with NewLine.
        $TextBody,
        [Parameter(ParameterSetName = 'HtmlBody', Mandatory = $true)]
        [Alias('HTML')]
        [string[]]
        $HtmlBody,
        # Message subject
        [Parameter(Mandatory = $true)]
        [validateLength(1, 255)]
        [string]
        $Subject,
        # One or more email addresses
        [Parameter()]
        [string[]]
        $To,
        # One or more email addresses
        [Parameter()]
        [string[]]
        $Cc,
        # One or more email addresses
        [Parameter()]
        [string[]]
        $Bcc,
        # Email addresses OR Entra/Exchange GUID of sender
        [Parameter()]
        [validatePattern(
            # This Regex validates that it matches a GUID or company.com email address
            "[\da-z]{8}-([\da-z]{4}-){3}[\da-z]{12}|[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@company\.com"
        )]
        [string]
        $From,
        # Paths to attachment file(s) OR [System.IO.FileInfo] from Get-ChildItem or similar
        [Parameter(ValueFromPipeline = $true)]
        [object[]]
        $Attachments
    )

    begin {
        # Make sure there is a recipient
        if (-not $To -and -not $Cc -and -not $Bcc) {
            throw 'Must have at least one of: $To $Cc $Bcc'
        }
        # Make sure attachments are valid
        if ($Attachments -and (Test-Path $Attachments) -contains $false) {
            throw 'At least one attachment is invalid'
        }
        # Make sure attachments are under 4MB total
        if ((Get-ChildItem $Attachments | Measure-Object -Property Length -Sum).Sum -ge 4mb) {
            throw 'Total of attachment size is over 4MB'
        }

        # Build a class to use to resolve MIME types
        class MimeTypeResolver {
            # Stolen from https://github.com/jshttp/mime-db
            hidden static [PSObject] $MimeTypes
            static [string] resolveMimeType([string]$Extension) {
                if (-not([MimeTypeResolver]::MimeTypes)) {
                    [MimeTypeResolver]::MimeTypes = Invoke-RestMethod -Uri 'https://cdn.jsdelivr.net/gh/jshttp/mime-db@master/db.json'
                }
                $Extension = $Extension.TrimStart('.')
                $AllProperties = [MimeTypeResolver]::MimeTypes.PSObject.Properties
                $MimeType = $AllProperties | Where-Object { $_.Value.extensions -contains $Extension }
                if ($MimeType.name) {
                    return $MimeType.name
                }
                return 'application/octet-stream'
            }
            static [bool] ImportMimeDBFromFile([string]$Path) {
                try {
                    $Import = $(Get-Content -Path $Path | ConvertFrom-Json)
                    [MimeTypeResolver]::MimeTypes = $Import
                    return $true
                } catch {
                    return $false
                }
            }
        }
        # Start an empty array of MIME types
        $ResolvedMimeTypes = @{}

        # Build an empty message
        $MessageParams = @{
            Message = @{
                Attachments   = @()
                Subject       = ''
                Body          = @{}
                BccRecipients = @()
                CcRecipients  = @()
                ToRecipients  = @()
            }
        }
    }
    
    process {
        # Add attachments
        if ($Attachments) {
            foreach ($Attachment in $Attachments) {
                # Make sure we have the Mime type for this extension already
                $Extension = [System.IO.Path]::GetExtension($Attachment)
                if (-not $ResolvedMimeTypes.$Extension) {
                    $ResolvedMimeTypes.$Extension = [MimeTypeResolver]::resolveMimeType( $Extension )
                }
    
                # Build a hash table for this attachment
                $AttachmentHash = @{
                    '@odata.type' = '#microsoft.graph.fileAttachment'
                    # Just the file name
                    Name          = Split-Path $Attachment -Leaf
                    # This is the MIME type for the file extension
                    ContentType   = $ResolvedMimeTypes.$Extension
                    # Get the content of the file as a Base64 string
                    ContentBytes  = [convert]::ToBase64String((
                            Get-Content -Path $Attachment -Encoding byte
                        ))
                }
    
                # Add this attachment to the message
                $MessageParams.Message.Attachments += $AttachmentHash
            }
        } else {
            $MessageParams.Message.Remove('Attachments')
        }
        
        # Set the subject
        $MessageParams.Message.Subject = $Subject

        # Set the body
        if ($TextBody) {
            $MessageParams.Message.Body.ContentType = 'Text'
            $MessageParams.Message.Body.Content = $TextBody -join "`n"
        } else {
            $MessageParams.Message.Body.ContentType = 'HTML'
            $MessageParams.Message.Body.Content = $HtmlBody -join "`n"
        }
        
        # Add recipients
        if ($To) {
            # Add each To recipient
            $To | ForEach-Object {
                $MessageParams.Message.ToRecipients += @{
                    EmailAddress = @{
                        Address = "$PSItem"
                    }
                }
            }
        } else {
            # Remove this field if there are none
            $MessageParams.Message.Remove('ToRecipients')
        }
        if ($Cc) {
            # Add each Cc recipient
            $Cc | ForEach-Object {
                $MessageParams.Message.CcRecipients += @{
                    EmailAddress = @{
                        Address = "$PSItem"
                    }
                }
            }
        } else {
            # Remove this field if there are none
            $MessageParams.Message.Remove('CcRecipients')
        }
        if ($Bcc) {
            # Add each Bcc recipient
            $Bcc | ForEach-Object {
                $MessageParams.Message.BccRecipients += @{
                    EmailAddress = @{
                        Address = "$PSItem"
                    }
                }
            }
        } else {
            # Remove this field if there are none
            $MessageParams.Message.Remove('BccRecipients')
        }
    }
    
    end {
        Write-Verbose ($MessageParams | ConvertTo-Json -Depth 5)
        Send-MgUserMail -UserId $From -BodyParameter $MessageParams
    }
}
#EndRegion Functions


# Set some details to use for AD
$ADSplat = @{
    Server = 'server.company.com'
}
$OtherADSplat = @{
    Server = 'server.othercompany.local'
}


# Get present time
$Now = Get-Date
# Set output file paths
$ResultFile = Join-Path -Path $ReportPath -ChildPath ( 'Provisioning' + (Get-Date -Format s).Replace(':', '-') + '.json' )
$TranscriptName = Join-Path -Path $TranscriptPath -ChildPath ( 'Provisioning' + (Get-Date -Format s).Replace(':', '-') + '.txt' )

# Start transcript
Start-Transcript $TranscriptName

# Get previous result files
$LastResultFile = Get-Item $ReportPath\Provisioning* | Sort-Object Name -Descending

# Sometimes the exported JSON has entries that are valid but don't import, like having keys 'value' and 'Value'
# This method of importing allows for all valid entries, but we have to load the .NET namespace
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Web.Extensions')

# Set the first index number to try
$Int = 0
# Keep importing until we get a valid date or run out of files to try
do {
    # Import the file using the .NET namespace
    $LastResults = (New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{MaxJsonLength = 67108864 }).DeserializeObject( ($LastResultFile[$Int] | Get-Content) )
    # The json will only say "success" if it completed correctly
    if ($LastResults.Success) {
        $TransactionsSince = $LastResults.Date
    }
    # dump this variable to save on memory
    Remove-Variable $LastResults
    # increment this variable
    $Int++
} until (
    # If we have a valid entry or no more files, stop
    $TransactionsSince -or -not $LastResultFile[$Int]
)

# If we can't find one, use "two weeks ago"
if (-not $TransactionsSince) {
    $TransactionsSince = $Now.AddDays(-14)
}

# Build a starting result object, with some null values to fill later
$ResultObject = [PSCustomObject]@{
    Date            = $Now
    Since           = $TransactionsSince
    TranscriptFile  = $TranscriptName
    CSVFiles        = $null
    UpdatedUsers    = $null
    TerminatedUsers = $null
    Success         = $false
}


# Write the starting values of $ResultObject
Write-Host 'Initial $ResultObject content'
$ResultObject | Out-String | Write-Host

# Connect to services
Connect-ExchangeOnline -ShowBanner:$false -CommandName 'Get-Mailbox', 'Get-Recipient', 'Set-Mailbox' -UserPrincipalName 'nathan.randall@company.com' -LoadCmdletHelp
Connect-MgGraph -NoWelcome #-Scopes Mail.Send, Sites.ReadWrite.All, Files.ReadWrite.All UserAuthenticationMethod.Read.All

Write-Host 'ExchangeOnline connection information:'
Get-ConnectionInformation | Out-String | Write-Host
Write-Host 'Graph connection information:'
Get-MgContext | Out-String | Write-Host
Write-Host "Graph connection scopes:`n`t" ((Get-MgContext).Scopes -join ', ')

#EndRegion Setup





#Region GetUpdatesFromWorkday

if (-not $DoNotUseWorkdayAPI) {
    Write-Host 'Importing the Workday module'
    # On import, variable $WorkdayConfiguration is created to hold details that commands will use
    Import-Module -Name "$PSScriptRoot\WorkdayAPI\WorkdayApi.psm1"
    
    Write-Host 'Setting Workday parameters'
    # Set workday credential
    $WDCredential = New-Object System.Management.Automation.PSCredential ($WorkdayUser, $WorkdayPass)

    # Put the credentials and the URI in the $WorkdayConfiguration variable
    Set-WorkdayCredential $WDCredential
    Set-WorkdayEndpoint -Endpoint Human_Resources -Uri $WorkdayURI

    Write-Host 'Getting Workday users changed since' $ResultObject.Since.ToString('u')
    # Get all Workers from Workday that have had transactions (changes) since the last time this ran
    $RecentChanges = Get-WorkdayWorker2 -TransactionsSince $TransactionsSince -TransactionsUntil $Now -IncludePersonal -IncludeWork -IncludeInactive -IncludeManagerName

    Write-Host 'Found' $RecentChanges.Count 'users. Processing data into $Entries.'

    $Entries = $RecentChanges | ForEach-Object {
        [PSCustomObject]@{
            PERNR                 = $PSItem.WorkerId
            Name                  = $PSItem.PreferredName
            Title                 = $PSItem.BusinessTitle
            ManagerName           = $PSItem.Manager.Name
            SamAccountName        = $PSItem.UserId
            ManagerPERNR          = $PSItem.Manager.Id
            Email                 = $PSItem.Email.Email
            Status                = $PSItem.Active
            WorkerType            = $PSItem.WorkerType
            RecordType            = $PSItem.RecordReason
            ManagerSamAccountName = $PSItem.Manager.SamAccountName
            RecentTermDate        = $PSItem.TerminationDate
            givenName             = $PSItem.FirstName
            sn                    = $PSItem.LastName
            middleName            = $null # $PSItem.????
            Territory             = $null # $PSItem.?????
            ISManager             = $PSItem.ISManager
        }
    }

} else {
    # SCP with .NET assembly replaces commandline WinSCP
    # Use https://winscp.net/eng/docs/library_powershell as reference

    # Get CSVs
    try {
        Write-Host 'Loading WinSCP .NET assembly'
        # Load WinSCP .NET assembly into memory
        Add-Type -Path 'C:\Program Files (x86)\WinSCP\WinSCPnet.dll'
    
        Write-Host 'Building session and connection options for SFTP'
        # Setup session options to use to open the connection. See https://winscp.net/eng/docs/library_sessionoptions
        $SessionOptions = New-Object WinSCP.SessionOptions -Property @{
            Protocol              = [WinSCP.Protocol]::Sftp
            HostName              = 'sftp.company.com'
            UserName              = 'secretusername'
            Password              = $SFTPPass
            SshHostKeyFingerprint = 'ssh-rsa 1024 supersecretrandomkey'
        }
        # Sets transfer options to use later when getting files. See https://winscp.net/eng/docs/library_transferoptions
        $TransferOptions = New-Object WinSCP.TransferOptions -Property @{
            TransferMode = [WinSCP.TransferMode]::Binary
        }
        # Create session to use
        $Session = New-Object WinSCP.Session
    
        # If anything fails in this, quit the whole script
        try {
            Write-Host 'Connecting to' $SessionOptions.HostName
            # Connect to the SFTP server
            $Session.Open($SessionOptions)

            Write-Host 'Attempting to download files'
            # Download files
            # The GetFiles() method requires four parameters, (string remotePath, string localPath, bool remove, WinSCP.TransferOptions options)
            # See https://winscp.net/eng/docs/library_session_getfiles
            $TransferResult = $Session.GetFiles(
                '/EFT/FromWorkdaytoAD/*.csv', # Server path
                $CSVPath, # Local path
                $true, # Remove after copy?
                $TransferOptions                # Options created above
            )

            # Throw on any error
            $TransferResult.Check()
    
            # Keep results
            if ($TransferResult) {
                # Get list of downloaded CSV file paths into an array
                $CSVs = $TransferResult.Transfers.Destination -as [array]
                # Copy the list into the ResultObject and save it
                $ResultObject.CSVFiles = $CSVs
                Save-Results

                # Delete the files from the server
                Write-Host 'Downloaded' $CSVs.Count 'files to process, now removing CSVs from server'
                $TransferResult.Transfers | ForEach-Object {
                    $RemoveResult = $Session.RemoveFile($PSItem.FileName)
                    if ($RemoveResult.Error) {
                        Write-Warning "Failed to remove $($PSItem.FileName) from server"
                    }
                }
            } else {
                Write-Host "No files found on SFTP.`nExiting"
                exit
            }
        } finally {
            Write-Host 'Disconnecting from' $SessionOptions.HostName
            # Disconnect, clean up
            $Session.Dispose()
        }
    
    } catch {
        Write-Host "Quitting with error: $($_.Exception.Message)"
        exit 1
    }
    
    # Create array to add entries to
    $Entries = @()
    Write-Host 'Getting all entries from CSV(s) to array'
    # Get ALL CSVs entries
    foreach ($File in $CSVs) {
        Write-Host 'Importing from' $File.FullName
        # Converts filename data to DateTime object, including changing MMddyyyyHHmmss to yyyy-MM-dd HH:mm:ss
        $FileTime = $File -replace '.*_|\..*' -replace '(\d{2})(\d{2})(\d{4})(\d{2})(\d{2})(\d{2})', '$3-$1-$2 $4:$5:$6' -as [datetime]
        # Imports the CSV and adds a FileTime property, and forces it to be an array
        [Array]$ThisFileEntries = Import-Csv $File | Select-Object *, @{ Name = 'FileTime' ; Expression = { $FileTime } }
        # Adds each entry to the array
        Write-Host 'Adding' $ThisFileEntries.Count 'to array'
        $ThisFileEntries | ForEach-Object {
            $Entries += $PSItem
        }
        # $File | Move-Item -Destination .\Archive
    }

    Write-Host 'Found' $Entries.Count 'total entries. Filtering out duplicate users, keeping only newest entries.'
    # Gets the LATEST entry only for each PERNR
    $Entries = $Entries | Sort-Object FileTime | Group-Object PERNR | ForEach-Object {
        # Since these are sorted by FileTime, the last one in each group will be the most recent
        $PSItem.Group[-1]
    } | ForEach-Object {
        # Make these into more usable property names
        [PSCustomObject]@{
            PERNR                 = $PSItem.PERNR
            Name                  = $PSItem.Emp_Name
            Title                 = $PSItem.'Position Title'
            ManagerName           = $PSItem.Manager_Name
            SamAccountName        = $PSItem.'SAM Account'
            ManagerPERNR          = $PSItem.'Mgr PERNR'
            Email                 = $PSItem.'E-mail'
            Status                = $PSItem.Status
            WorkerType            = $PSItem.'Worker Type'
            RecordType            = $PSItem.'Record Type'
            ManagerSamAccountName = $PSItem.'Mgr SAM Account'
            RecentTermDate        = $PSItem.'Recent Term Date'
            givenName             = $PSItem.givenName
            sn                    = $PSItem.sn
            middleName            = $PSItem.middleName
            Territory             = $PSItem.Territory
            ISManager             = $PSItem.ISManager
        }
    }
}

# Split into Terminations and Updates
Write-Host 'Sorting entries into Updates and Terminations'
[array]$UpdateEntries = $Entries | Where-Object RecordType -Like 'U' #| Where-Object SamAccountName
[array]$TerminationEntries = $Entries | Where-Object RecordType -Like 'T' #| Where-Object SamAccountName
Write-Host 'Found' $UpdateEntries.Count 'update entries and' $TerminationEntries.Count 'termination entries'

#EndRegion GetUpdatesFromWorkday





#Region ProcessUpdates
# Properties to use in a bit; simplifies later lines (and making changes) to do it as an array here
$UserUpdateProps = @(
    'Name'
    'SamAccountName'
    'Enabled'
    'EmployeeID'
    'EmployeeNumber'
    'mail'
    'givenName'
    'SurName'
    'Title'
    'Manager'
    'msExchExtensionAttribute33'
    'msExchExtensionAttribute34'
    'extensionAttribute3'
    'extensionAttribute6'
    'extensionAttribute14'
)

# build an empty array to load them into later
$UpdatedUsers = @()

Write-Host 'Processing update entries'
foreach ($Entry in $UpdateEntries) {
    Write-Host 'Getting existing user for employeeID' $Entry.PERNR 
    $PreUser = Get-ADUser @ADSplat -Filter "EmployeeID -eq '$($Entry.PERNR)'" -Properties $UserUpdateProps

    if (-not $PreUser) {
        Write-Host 'Could not find user in AD'
        $ThisObject = [PSCustomObject]@{
            PERNR        = $Entry.PERNR
            CSVEntry     = $Entry
            ADPreUpdate  = $null
            ADPostUpdate = $null
        }
        $UpdatedUsers += $ThisObject
        # Quit processing this user
        continue
    }
    # In cases where SamAccountName was not yet in Workday
    if (-not $Entry.SamAccountName) {
        $Entry.SamAccountName = $PreUser.SamAccountName
    }
    Write-Host -ForegroundColor green 'Processing user' $PreUser.DistinguishedName
    Write-Host 'Clearing extensionAttributes 3 and 6'
    # Clear so they update later
    Set-ADUser @ADSplat -Identity $PreUser -Clear 'extensionAttribute3'
    Set-ADUser @ADSplat -Identity $PreUser -Clear 'extensionAttribute6'
    
    Write-Host 'Updating Manager, Title, and extensionAttributes'
    # Update the properties
    Set-ADUser @ADSplat -Identity $PreUser -Manager $Entry.ManagerSamAccountName
    Set-ADUser @ADSplat -Identity $PreUser -Title $Entry.Title
    Set-ADUser @ADSplat -Identity $PreUser -Add @{'extensionAttribute6' = $Entry.Territory }
    If ($Entry.ISManager -eq 'Y') {
        Set-ADUser @ADSplat -Identity $PreUser -Add @{'extensionAttribute3' = 'Manager' }
    }

    # Get the user after changes
    $PostUser = Get-ADUser @ADSplat -Identity $PreUser -Properties $UserUpdateProps
    
    # Check for OtherCompany account
    if ($PreUser.extensionAttribute14 -match 'OtherCompany') {
        Write-Host "Getting OtherCompany account and manager account"
        $OtherPre = Get-ADUser @OtherADSplat -Filter "EmployeeID -eq '$($Entry.PERNR)'" -Properties @UserUpdateProps
        $OtherManager = Get-ADUser @OtherADSplat -Filter "EmployeeID -eq '$($Entry.ManagerPERNR)'"

        Write-Host 'Clearing extensionAttributes 3 and 6'
        # Clear so they update later
        Set-ADUser @OtherADSplat -Identity $OtherPre -Clear 'extensionAttribute3'
        Set-ADUser @OtherADSplat -Identity $OtherPre -Clear 'extensionAttribute6'
        
        Write-Host 'Updating Manager, Title, and extensionAttributes'
        # Update the properties
        if ($OtherManager) {
            Set-ADUser @OtherADSplat -Identity $OtherPre -Manager $Entry.ManagerSamAccountName
        }
        Set-ADUser @OtherADSplat -Identity $OtherPre -Title $Entry.Title
        Set-ADUser @OtherADSplat -Identity $OtherPre -Add @{'extensionAttribute6' = $Entry.Territory }
        If ($Entry.ISManager -eq 'Y') {
            Set-ADUser @OtherADSplat -Identity $OtherPre -Add @{'extensionAttribute3' = 'Manager' }
        }
    

        $OtherPost = Get-ADUser @OtherADSplat -Filter "EmployeeID -eq '$($Entry.PERNR)'" -Properties @UserUpdateProps
    }


    $ThisObject = [PSCustomObject]@{
        PERNR        = $Entry.PERNR
        Entry        = $Entry
        Changes      = Compare-ObjectProperty $PreUser $PostUser
        ADPreUpdate  = $PreUser
        ADPostUpdate = $PostUser
        OtherCompany = if ($PreUser.extensionAttribute14 -match 'OtherCompany') {
                [PSCustomObject]@{
                    PreUpdate  = $OtherPre
                    PostUpdate = $OtherPost
                }
            }
    }
    $UpdatedUsers += $ThisObject
    $ResultObject.UpdatedUsers = $UpdatedUsers
    Save-Results
}
Write-Host 'Processed' $UpdatedUsers 'of' $UpdateEntries 'updates'

#EndRegion ProcessUpdates





#Region ProcessTerminations

# Use these later
$UserTermProps = @(
    'Name'
    'SamAccountName'
    'Enabled'
    'EmployeeID'
    'EmployeeNumber'
    'mail'
    'givenName'
    'SurName'
    'Title'
    'Manager'
    'msExchExtensionAttribute33'
    'msExchExtensionAttribute34'
    'extensionAttribute3'
    'extensionAttribute6'
    'extensionAttribute14'
    'AccountExpirationDate'
    'CanonicalName'
    'PasswordLastSet'
    'MemberOf'
    'msExchExtensionCustomAttribute1' # Or whichever is picked for alt domain + elevated users
)
$MGUserProps = @(
    'DisplayName'
    'Id'
    'Mail'
    'UserPrincipalName'
    'AccountEnabled'
    'OnPremisesSyncEnabled'
    'GivenName'
    'OnPremisesLastSyncDateTime'
    'SignInSessionsValidFromDateTime'
    'Surname | Select-Object DisplayName'
    'Id'
    'Mail'
    'UserPrincipalName'
    'AccountEnabled'
    'OnPremisesSyncEnabled'
    'GivenName'
    'OnPremisesLastSyncDateTime'
    'SignInSessionsValidFromDateTime'
    'Surname'
)

Write-Host 'Beginning termination process for' $TerminationEntries.Count 'users'

$TerminatedUsers = @()
foreach ($Entry in $TerminationEntries) {
    # Clear the errors so we can record which ones occurred for this user
    $Error.Clear()

    #Region RecordBeforeState
    Write-Host 'Get AD User, AD Groups. Entra user, Entra groups, and Mailbox for' $Entry.PERNR $Entry.Name $Entry.Email
    $ADUser = Get-ADUser @ADSplat -Filter "EmployeeID -eq '$($Entry.PERNR)'" -properties $UserTermProps

    if (-not $ADUser) {
        Write-Host 'Could not find user in AD'
        $ThisObject = [PSCustomObject]@{
            PERNR  = $Entry.PERNR
            ADUser = $null
        }
        $UpdatedUsers += $ThisObject
        # Quit processing this user
        continue
    }

    # In cases where SamAccountName was not yet in Workday
    if (-not $Entry.SamAccountName) {
        $Entry.SamAccountName = $ADUser.SamAccountName
    }

    [array]$ADGroups = $ADUser.MemberOf | Get-ADGroup @ADSplat

    # Get EntraID/AzureAD user va Graph
    $MGUser = Get-MgUser -Filter "UserPrincipalName eq '$($ADUser.UserPrincipalName)'" -ExpandProperty MemberOf -Property $MGUserProps
    # Get group memberships
    $MGUser.MemberOf | Where-Object {$PSItem.AdditionalProperties.'@odata.type' -like '#microsoft.graph.group' }
    # Get user roles
    $MGRoles = Get-MgRoleManagementDirectoryRoleAssignment -Filter "PrincipalId eq '$($MGUser.Id)'" -ExpandProperty RoleDefinition | Select-Object @{Name = 'RoleName'; Expression = { $PSItem.RoleDefinition.DisplayName } }, *
    
    # Get the current authentication methods, which includes password and MFA types
    $CurrentAuthenticationMethods = Get-MgUserAuthenticationMethod -UserId $MGUser.Id

    
    # Get mailbox - may need to get inactives but the switch stopped working?
    $Mailbox = Get-Mailbox -Identity $ADUser.UserPrincipalName #-IncludeInactiveMailbox

    Write-Host 'Store start info in an object'
    $ThisObject = [PSCustomObject]@{
        PERNR                 = $Entry.PERNR
        ADUser                = $ADUser | Select-Object $UserTermProps
        ADGroups              = $ADGroups | Select-Object Name, ObjectGUID, DistinguishedName, GroupCategory, GroupScope
        MGUser                = $MGUser | Select-Object $MGUserProps
        MGGroups              = $MGUser.MemberOf | Where-Object {
                $PSItem.AdditionalProperties.'@odata.type' -like '#microsoft.graph.group'
            } | ForEach-Object {
                [PSCustomObject]@{
                    Id = $PSItem.Id
                    DisplayName = $PSItem.AdditionalProperties.displayName
                    OnPremSyncEnabled = $PSItem.AdditionalProperties.onPremisesSyncEnabled
                    onPremLastSync = $PSItem.AdditionalProperties.onPremisesLastSyncDateTime
                    Mail = $PSItem.AdditionalProperties.mail
                    MailEnabled = $PSItem.AdditionalProperties.mailEnabled
                    MailNickname = $PSItem.AdditionalProperties.mailNickname
                    SecurityEnabled = $PSItem.AdditionalProperties.securityEnabled
                    Description = $PSItem.AdditionalProperties.description
                }
            }
        MGRoles               = $MGRoles | Select-Object RoleName, DirectoryScopeId, Id, RoleDefinitionId
        AuthenticationMethods = $CurrentAuthenticationMethods | ForEach-Object {
            [PSCustomObject]@{
                Id                = $PSItem.Id
                Type              = switch ($PSItem.AdditionalProperties.'@odata.type') {
                    '#microsoft.graph.passwordAuthenticationMethod' { 'Password' }
                    '#microsoft.graph.EmailAuthenticationMethod' { 'Email' }
                    '#microsoft.graph.Fido2AuthenticationMethod' { 'FIDO2' }
                    '#microsoft.graph.MicrosoftAuthenticatorAuthenticationMethod' { 'Microsoft Authenticator' }
                    '#microsoft.graph.PhoneAuthenticationMethod' { 'Phone number' }
                    '#microsoft.graph.SoftwareOathAuthenticationMethod' { 'Software OATH' }
                    '#microsoft.graph.TemporaryAccessPassAuthenticationMethod' { 'Temporary Access Password' }
                    '#microsoft.graph.WindowsHelloForBusinessAuthenticationMethod' { 'Windows Hello' }
                    Default { $PSItem.AdditionalProperties.'@odata.type' -replace 'AuthenticationMethod' -csplit '(?<!^)(?=[A-Z])' -join ' ' }
                }
                CreatedDateTime   = $PSItem.AdditionalProperties.createdDateTime
                DisplayName       = $PSItem.AdditionalProperties.displayName
                EmailAddress      = $PSItem.AdditionalProperties.emailAddress
                PhoneAppVersion   = $PSItem.AdditionalProperties.phoneAppVersion
                PhoneNumber       = $PSItem.AdditionalProperties.phoneNumber
                StartDateTime     = $PSItem.AdditionalProperties.startDateTime
                LifetimeInMinutes = $PSItem.AdditionalProperties.lifetimeInMinutes
        
            }
        }
        Mailbox               = $Mailbox
        OtherAccounts         = [PSCustomObject]@{}
        Changes               = $null
        Errors                = $null
    }
    #EndRegion RecordBeforeState




    #Region SetADSettings
    
    # Generate new password, as a secure string
    $NewPass = New-Password

    # Get the term date from the user output, and use 12AM that day as expiration time
    $ExpirationDate = $Entry.RecentTermDate -as [datetime]
    # But if it isn't at least a day ago, use exactly a day ago
    if ($ExpirationDate -ge [DateTime]::Now.AddDays(-1)) {
        $ExpirationDate = [DateTime]::Now.AddDays(-1)
    }
    
    Write-Host 'Disabling AD user' $ADUser.UserPrincipalName
    Disable-ADAccount @ADSplat -Identity $ADUser
    Write-Host 'Resetting AD password'
    Set-ADAccountPassword @ADSplat -Identity $ADUser -Reset -NewPassword $NewPass
    Write-Host 'Setting AD account expiration to' $ExpirationDate
    Set-ADAccountExpiration @ADSplat -Identity $ADUser -DateTime $ExpirationDate
    Write-Host 'Removing AD account manager and setting extension attributes'
    # Build a hashtable of parameters to "splat" to Set-ADUser
    $SetADSplat = @{
        Identity       = $ADUser
        Clear          = 'Manager'
        EmployeeID     = 'DNU-' + $Entry.PERNR
        EmployeeNumber = 'DNU-' + $Entry.PERNR
        Replace        = @{
                msExchExtensionAttribute33 = $Now.ToString('yyyy-MM-dd_HHmm')
                msExchExtensionAttribute34 = $Now.ToString('yyyy-MM-dd')
                ExtensionAttribute15       = 'Term'
            }
    }
    # Verify SamAccountName doesn't already start with DNU- for some reason before adding it
    if ($ADuser.SamAccountName -notlike 'DNU-*') {
        $SetADSplat.SamAccountName = 'DNU-' + $ADuser.SamAccountName
    }
    Set-ADUser @ADSplat @SetADSplat

    Write-Host 'Removing from AD groups' $ADGroups.SamAccountName
    $ADGroups | ForEach-Object {
        # Removes this AD user from each group and writes the command to the console
        Remove-ADGroupMember @ADSplat -Identity $PSItem -Members $ADUser -Verbose
    }


    #EndRegion SetADSettings
    



    #Region SetMailboxSettings
    # Build a hashtable of the parameters to use
    $SetMailboxParams = @{
        Identity                      = $Mailbox
            # Retention hold on hold for now; enable this to enable it
        # RetentionHoldEnabled          = $true     # Set retention hold
        HiddenFromAddressListsEnabled = $true     # Hide from GAL
        ForwardingAddress             = $null     # Remove forwarding
        ForwardingSmtpAddress         = $null     # Remove forwarding
    }
    Write-Host 'Enabling retention hold, disabling forwarding, and hiding from address lists on mailbox'
    # This will apply the parameters and run the command
    Set-Mailbox @SetMailboxParams
    #EndRegion SetMailboxSettings




    #Region SetGraphSettings
    
    # Get users' groups with direct, not dynamic, membership
    $DirectGroups = $MGUser.MemberOf | Where-Object {
        $PSItem.AdditionalProperties.'@odata.type' -like '#microsoft.graph.group' -and
        -not $PSItem.AdditionalProperties.onPremisesSecurityIdentifier -and
        $PSItem.AdditionalProperties.groupTypes -notmatch 'DynamicMembership'
    }

    if ($DirectGroups) {
        Write-Host "Removing membership from cloud-only groups:`n" ( $DirectGroups.AdditionalProperties.displayName -join ', ' )
        $DirectGroups | ForEach-Object {
            Remove-MgGroupMemberByRef -GroupId $PSItem.Id -MemberId $MGUser.Id
        }
    }

    # Remove Assigned Roles
    if ($MGRoles) {
        Write-Host "Removing Roles:`n" ( $MGRoles.RoleName -join ', ' )
        $MGRoles | ForEach-Object {
            Remove-MgRoleManagementDirectoryRoleAssignment -UnifiedRoleAssignmentId $PSItem.Id
        }
    }

    # Reset and require MFA
    Write-Host 'Removing MFA and other authentication methods'

    $CurrentAuthenticationMethods | ForEach-Object {
        # Okay, so this is ugly. Basically, we are using _switch_ instead of a bunch of if/then statements, using the data type
        # For each data type, we write relevant info about that object (device, phone number etc.) then use the appropriate command to remove it
        switch ($PSItem.AdditionalProperties.'@odata.type') {
            '#microsoft.graph.passwordAuthenticationMethod' { 
                # Do nothing for this one. It isn't MFA, there's no command for it, it isn't even removable. It was already reset above.
            }
            '#microsoft.graph.EmailAuthenticationMethod' { 
                Write-Host 'Removing Email authentication method with email address:' $PSItem.AdditionalProperties.emailAddress
                Remove-MgUserAuthenticationEmailMethod -EmailAuthenticationMethodId $PSItem.Id -UserID $MGUser.Id
            }
            '#microsoft.graph.Fido2AuthenticationMethod' { 
                Write-Host 'Removing Fido2 authentication method with name' $PSItem.AdditionalProperties.displayName 'from device' $PSItem.AdditionalProperties..model 'created on' $PSItem.AdditionalProperties.createdDateTime
                Remove-MgUserAuthenticationFido2Method -Fido2AuthenticationMethodId $PSItem.Id -UserID $MGUser.Id
            }
            '#microsoft.graph.MicrosoftAuthenticatorAuthenticationMethod' { 
                Write-Host 'Removing Microsoft Authenticator app authentication method from device' $PSItem.AdditionalProperties.displayName 'with app version' $PSItem.AdditionalProperties.phoneAppVersion 'created on' $PSItem.AdditionalProperties.createdDateTime
                Remove-MgUserAuthenticationMicrosoftAuthenticatorMethod -MicrosoftAuthenticatorAuthenticationMethodId $PSItem.Id -UserID $MGUser.Id
            }
            '#microsoft.graph.PhoneAuthenticationMethod' { 
                Write-Host 'Removing Phone authentication method with phone number' $PSItem.AdditionalProperties.phoneNumber 
                Remove-MgUserAuthenticationPhoneMethod -PhoneAuthenticationMethodId $PSItem.Id -UserID $MGUser.Id
            }
            '#microsoft.graph.SoftwareOathAuthenticationMethod' { 
                Write-Host 'Removing Software OATH authentication method' 
                Remove-MgUserAuthenticationSoftwareOathMethod -SoftwareOathAuthenticationMethodId $PSItem.Id -UserID $MGUser.Id
            }
            '#microsoft.graph.TemporaryAccessPassAuthenticationMethod' { 
                Write-Host 'Removing Temporary Access Pass authentication method created' $PSItem.AdditionalProperties.createdDateTime 'available until' ([datetime]($PSItem.AdditionalProperties.startDateTime)).AddMinutes($PSItem.AdditionalProperties.lifetimeInMinutes)
                Remove-MgUserAuthenticationTemporaryAccessPassMethod -TemporaryAccessPassAuthenticationMethodId $PSItem.Id -UserID $MGUser.Id
            }
            '#microsoft.graph.WindowsHelloForBusinessAuthenticationMethod' { 
                Write-Host 'Removing Windows Hello for Business authentication method for device' $PSItem.AdditionalProperties.displayName 'created' $PSItem.AdditionalProperties.createdDateTime 
                Remove-MgUserAuthenticationWindowsHelloForBusinessMethod -WindowsHelloForBusinessAuthenticationMethodId $PSItem.Id -UserID $MGUser.Id
            }
            Default {
                # If it is a new/unknown Type, write a warning then write the values
                Write-Warning (
                    "Found unknown AuthenticationMethod type {0}`nAll AdditionalProperties are:" -f $PSItem.AdditionalProperties.'@odata.type'                  
                )
                $PSItem.AdditionalProperties.GetEnumerator() | ForEach-Object {
                    '{0,-21} : {1}' -f $PSItem.Key, $PSItem.Value
                }
            }
        }
    }


    # Revoke existing connections
    Write-Host 'Revoking sessions'
    Revoke-MgUserSignInSession -UserId $MGUser.Id


    #EndRegion SetGraphSettings
    



    #Region MoveToNonSyncOU
    Write-Host 'Moving' $ADUser.UserPrincipalName 'to DisabledUsers OU'
    Move-ADObject @ADSplat -Identity $ADUser -TargetPath 'OU=DisabledUsers,DC=company,DC=com'
    #EndRegion MoveToNonSyncOU




    #Region CheckOtherAccounts
        # Check for OtherCompany account
        if ($PreUser.extensionAttribute14 -match 'OtherCompany') {
            Write-Host "Getting OtherCompany account"
            $OtherPre = Get-ADUser @OtherADSplat -Filter "EmployeeID -eq '$($Entry.PERNR)'" -Properties @UserTermProps
            [array]$OtherGroups = $OtherPre.MemberOf | Get-ADGroup @OtherADSplat
    
            Write-Host 'Disabling AD user' $OtherPre.UserPrincipalName
            Disable-ADAccount @OtherADSplat -Identity $OtherPre
            Write-Host 'Resetting AD password'
            Set-ADAccountPassword @OtherADSplat -Identity $OtherPre -Reset -NewPassword $NewPass
            Write-Host 'Setting AD account expiration to' $ExpirationDate
            Set-ADAccountExpiration @OtherADSplat -Identity $OtherPre -DateTime $ExpirationDate
            Write-Host 'Removing AD account manager and setting extension attributes'
            Set-ADUser @OtherADSplat -Identity $OtherPre -Clear Manager -Replace @{
                msExchExtensionAttribute33 = $Now.ToString('yyyy-MM-dd_HHmm')
                msExchExtensionAttribute34 = $Now.ToString('yyyy-MM-dd')
                ExtensionAttribute15       = 'Term'
            }

            Write-Host 'Removing from AD groups' $ADGroups.SamAccountName
            $OtherGroups | ForEach-Object {
                # Removes this AD user from each group and writes the command to the console
                Remove-ADGroupMember @OtherADSplat -Identity $PSItem -Members $OtherPre -Verbose
            }
    
            $OtherPost = Get-ADUser @OtherADSplat -Filter "EmployeeID -eq '$($Entry.PERNR)'" -Properties @UserTermProps

            $ThisObject.OtherAccounts | Add-Member -NotePropertyMembers {
                OtherCompanyPre  = $OtherPre
                OtherCompanyPost = $OtherPost
            }
        }

        # Check for admin accounts
        if ($PreUser.extensionAttribute14 -match 'dadmin|ouadmin') {
            $AdminSAMs = $PreUser.extensionAttribute14.Split(',;:|').Trim() | Where-Object {$PSItem -match 'dadmin|ouadmin'}
            $AdminSAMs | ForEach-Object {
                Write-Host "Getting Admin account $PSItem"
                $AdminPre = Get-ADUser @ADSplat $PSItem -Properties @UserTermProps
                [array]$AdminGroups = $AdminPre.MemberOf | Get-ADGroup @ADSplat
        
                Write-Host 'Disabling AD user' $AdminPre.UserPrincipalName
                Disable-ADAccount @ADSplat -Identity $AdminPre
                Write-Host 'Resetting AD password'
                Set-ADAccountPassword @ADSplat -Identity $AdminPre -Reset -NewPassword $NewPass
                Write-Host 'Setting AD account expiration to' $ExpirationDate
                Set-ADAccountExpiration @ADSplat -Identity $AdminPre -DateTime $ExpirationDate
                Write-Host 'Removing AD account manager and setting extension attributes'
                Set-ADUser @ADSplat -Identity $AdminPre -Clear Manager -Replace @{
                    msExchExtensionAttribute33 = $Now.ToString('yyyy-MM-dd_HHmm')
                    msExchExtensionAttribute34 = $Now.ToString('yyyy-MM-dd')
                    ExtensionAttribute15       = 'Term'
                }
    
                Write-Host 'Removing from AD groups' $ADGroups.SamAccountName
                $AdminGroups | ForEach-Object {
                    # Removes this AD user from each group and writes the command to the console
                    Remove-ADGroupMember @ADSplat -Identity $PSItem -Members $AdminPre -Verbose
                }
        
                $AdminPost = Get-ADUser @ADSplat $PSItem -Properties @UserTermProps
    
                $ThisObject.OtherAccounts | Add-Member -NotePropertyMembers {
                    AdminPre  = $AdminPre
                    AdminPost = $AdminPost
                }
            }
            
            
        }

    #EndRegion CheckOtherAccounts




    #Region LogUser
    # Update the (AD) changes record for the user
    $ThisObject.Changes = Compare-ObjectProperty $ADUser (Get-ADUser @ADSplat -Filter "EmployeeID -eq '$($Entry.PERNR)'" -properties $UserTermProps)

    # Update the error record for the user
    $ThisObject.Errors = $Error | ForEach-Object {
        "{0}`n{1}" -f $PSItem.Exception.ToString(), $PSItem.InvocationInfo.PositionMessage
    }
    $ThisObject.Errors = $ThisObject.Errors -as [array]
    # Update the main object with this user
    $TerminatedUsers += $ThisObject
    #EndRegion LogUser


}

$ResultObject.TerminatedUsers = $TerminatedUsers
Save-Results



#EndRegion ProcessTerminations





#Region ReportAndCleanup

# Move CSVs to Archive if they exist
if ($CSVs) {
    $ArchivePath = Join-Path $CSVPath 'Archive'
    Write-Host "Archiving CSVs to $CSVPath"
    $CSVs | Move-Item -Destination $ArchivePath
}

# Delete archived CSVs
$ClearCSVsDate = $Now.AddDays(-$ClearCSVsAfterDays)
Get-ChildItem -Path $ArchivePath -Filter *.csv | Where-Object LastWriteTime -le $ClearCSVsDate | Remove-Item

# Delete archived Reports
$ClearReportsDate = $Now.AddDays(-$ClearReportsAfterDays)
Get-ChildItem -Path $ReportPath -Filter Provisioning*.json | Where-Object LastWriteTime -le $ClearReportsDate | Remove-Item

# Delete archived Transcripts
$ClearTranscriptsDate = $Now.AddDays(-$ClearTranscriptsAfterDays)
Get-ChildItem -Path $TranscriptPath -Filter Provisioning*.txt | Where-Object LastWriteTime -le $ClearTranscriptsDate | Remove-Item


$MailReportProps = @(
    'Name'
    'SamAccountName'
    'Enabled'
    'EmployeeID'
    'EmployeeNumber'
    'mail'
    'givenName'
    'sn'
    'title'
    'manager'
    'msExchExtensionAttribute33'
    'msExchExtensionAttribute34'
)
$MailReportPath = Join-Path -Path $CSVPath, 'Report' -ChildPath "WorkdayExport-report_$($Now.ToString('MM-dd-yyyy_HHmm')).csv"
$Entries.SamAccountName | Get-ADUser @ADSplat -Properties $MailReportProps | Select-Object $MailReportProps | Export-Csv -NoTypeInformation -Path $MailReportPath




Send-GraphMailMessage -HtmlBody ($ResultObject | ConvertTo-Html) -Subject 'Test of stuff' -To 'nathan.randall@company.com' -From 'nathan.randall@company.com' -Attachments (Get-ChildItem .\Reports).FullName

$ResultObject | ConvertTo-Html


# Email CSV and transcript

$ResultObject.Success = $true
Save-Results

Stop-Transcript
#EndRegion ReportAndCleanup

