function Get-Path {
    <#
    .SYNOPSIS
        The function converts string with delimiter (e.g. environment variable $env:Path) to array of strings.
    .DESCRIPTION
        The function converts string with delimiter (e.g. environment variable $env:Path) to array of strings.
    .EXAMPLE
        PS C:\> Get-Path -Path $env:Path
        Converts environment variable $env:Path to array of strings. Flag "OnlyAvailable" is set by default, so the function will return only existing paths.
    .EXAMPLE
        PS C:\> Get-Path -Path $env:Path -OnlyAvailable:$false
        Converts environment variable $env:Path to array of strings. Flag "OnlyAvailable" is unset, so the function will return all paths.
    .INPUTS
        [System.String]
    .OUTPUTS
        [System.Array]
    .NOTES
        ...
    #>
    [CmdletBinding()]
    param (
        # Source path from $env:Path, $env:PSModulePath or from elsewhere like $env:SMS_ADMIN_UI_PATH. Default is $env:Path.
        [Parameter(HelpMessage="Source path from env:Path, env:PSModulePath or from elsewhere like env:SMS_ADMIN_UI_PATH. Default is env:Path.")]
        [string]
        $Path = $env:Path,

        # Returns only available paths if checked. Default value is "True".
        [Parameter(HelpMessage="Returns only available paths if checked. Default value is True.")]
        [bool]
        $OnlyAvailable = $true
    )

    begin {
        [array]$pathToArray = $Path.Split(";").Where({$_.Length -ne 0})
        [array]$outArray = @()
    }

    process {
        if ($OnlyAvailable) {
            [array]$tempArray = @()
            foreach ($pathStr in $pathToArray) {
                if (Test-Path -Path $pathStr) {
                    $tempArray += $pathStr
                }
            }
            $outArray = $tempArray
        } else {
            $outArray = $pathToArray
        }
    }

    end {
        return $outArray
    }
}

function Find-Path {
    <#
    .SYNOPSIS
        The function finds path by keyword.
    .DESCRIPTION
        The function finds path by keyword.
    .EXAMPLE
        PS C:\> Find-Path -Keyword putty -Path $env:Path
        Returns from environment variable $env:Path path with keyword "putty":
        PS C:\> C:\Program Files\PuTTY\
    .EXAMPLE
        PS C:\> Find-Path -Keyword pageant -Path $env:Path -InContent
        Function will get paths from $env:Path and will search for files with keyword "pageant", then will return paths to folders where the files are present:
        PS C:\> C:\Program Files\PuTTY\
        PS C:\> C:\Program Files\Git\cmd
    .INPUTS
        [System.String]
    .OUTPUTS
        [System.Array]
    .NOTES
        ...
    #>
    [CmdletBinding()]
    param (
        # Search string
        [Parameter(Mandatory=$true,HelpMessage="Keyword for search, mandatory parameter")]
        [string]
        $Keyword,

        # Path to search, default is $env:Path
        [Parameter(HelpMessage="Path to search, default is env:Path")]
        [string]
        $Path = $env:Path,

        # If true, will search for matches in filenames in path folders. Default is "False".
        [Parameter(HelpMessage="If true, will search for matches in filenames in path folders. Default is False.")]
        [switch]
        $InContent = $false
    )
    
    begin {
        [array]$tempArray = Get-Path -Path $Path
        [array]$outArray = @()
    }
    
    process {
        foreach ($pathStr in $tempArray) {
            if (!$InContent) {
                if ($pathStr -match $Keyword) {
                    $outArray += $pathStr
                }
            } else {
                if ((Get-ChildItem -Path $pathStr -File).Name -match $Keyword) {
                    $outArray += $pathStr
                }
            }
        }
    }
    
    end {
        return $outArray
    }
}

function Add-Path {
    <#
    .SYNOPSIS
        Adds path to environment. Returns string.
    .DESCRIPTION
        Adds path to environment. Returns string.
    .EXAMPLE
        PS C:\> Add-Path -Path "C:\Path\Does\Not\Exists" -Scope $env:Path
        Adds path "C:\Path\Does\Not\Exists" to environment variable $env:Path, if path "C:\Path\Does\Not\Exists" exists.
    .EXAMPLE
        PS C:\> Add-Path -Path "C:\Path\Does\Not\Exists" -Scope $env:Path -OnlyIfExists:$false
        Adds path "C:\Path\Does\Not\Exists" to environment variable $env:Path, even if path "C:\Path\Does\Not\Exists" does NOT exists.
    .INPUTS
        [System.String]
    .OUTPUTS
        [System.String]
    .NOTES
        ...
    #>
    [CmdletBinding()]
    param (
        # Path to add
        [Parameter(Mandatory=$true,HelpMessage="Path to add")]
        [string]
        $Path,

        # Scope. Default is $env:Path.
        [Parameter(HelpMessage="Scope. Default is env:Path.")]
        [string]
        $Scope = $env.Path,

        # Test path before addition. Default is $true.
        [Parameter(HelpMessage="Test path before addition. Default is True.")]
        [bool]
        $OnlyIfExists = $true
    )
    
    begin {
        [array]$tempArray = Get-Path -Path $Scope
        [string]$outString = $null
    }
    
    process {
        if (!$OnlyIfExists) {
            Write-Warning -Message "Adding path $Path without checking for existence!"
            $tempArray += $Path
        } else {
            if (Test-Path -Path $Path) {
                Write-Verbose -Message "Adding path $Path to selected scope $Scope"
                $tempArray += $Path
            } else {
                Write-Error -Message "Path $Path does not exists! Exiting."
                break
            }
        }
        Write-Verbose -Message $tempArray
        $outString = $tempArray -join ";"
    }
    
    end {
        return $outString
    }
}

function Remove-Path {
    <#
    .SYNOPSIS
        Removes path from environment variable.
    .DESCRIPTION
        Removes path from environment variable.
    .EXAMPLE
        PS C:\> Remove-Path -Path "C:\Path\Does\Not\Exists" -Scope $env:Path
        Removes path "C:\Path\Does\Not\Exists" from environment variable $env:Path and return string.
    .INPUTS
        [System.String]
    .OUTPUTS
        [System.String]
    .NOTES
        ...
    #>
    [CmdletBinding()]
    param (
        # Path to remove
        [Parameter(Mandatory=$true,HelpMessage="Path to remove")]
        [string]
        $Path,

        # Scope. Default is $env:Path
        [Parameter(HelpMessage="Scope. Default is env:Path")]
        [string]
        $Scope = $env:Path
    )
    
    begin {
        [array]$tempArray = Get-Path -Path $Scope
        [array]$outArray = @()
        [string]$outString = $null
    }
    
    process {
        foreach ($pathStr in $tempArray) {
            if (!($pathStr -ne $Path)) {
                $outArray += $pathStr
            }
        }
        $outString = $outArray -join ";"
    }
    
    end {
        return $outString
    }
}

Export-ModuleMember -Function @(
    "Get-Path",
    "Find-Path",
    "Add-Path",
    "Remove-Path"
    )