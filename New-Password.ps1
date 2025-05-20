<#PSScriptInfo

.VERSION 1.0.0.0

.GUID 4fd835ab-f3b8-4229-81a5-29c26e72b726

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


.PRIVATEDATA


#>


function New-Password {
    <#
    .SYNOPSIS
    Generates a random password.
    .DESCRIPTION
    Generates a random password. The password is generated using the characters specified in the -PasswordCharacters parameter. The default is all valid ASCII characters.

    .PARAMETER PasswordLength
    The length of the password to generate. The default is 20 characters.
    .PARAMETER PasswordCharacters
    The characters to use to generate the password. The default is all valid ASCII characters.
    .PARAMETER AsPlainText
    Return the password as plain text instead of (default) secure string.
    .PARAMETER WriteToConsole
    Will write the password to the host as well as return it.

    .EXAMPLE
    New-Password -PasswordLength 16 -PasswordCharacters ("a".."z" + "A".."Z" + "0".."9" + "!@#$%^&*()".ToCharArray()) -AsPlainText
    Generates a random password of length 16 using letters, numbers, and special characters and returns it as plain text.
    .EXAMPLE
    New-Password -PasswordLength 48 -WriteToConsole
    Generates a random password of length 48 using all valid ASCII characters and writes it to the console.

    #>
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
