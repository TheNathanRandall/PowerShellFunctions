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
