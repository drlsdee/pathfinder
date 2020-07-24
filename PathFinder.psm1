
function Get-PSScriptsInFolder {
    [CmdletBinding()]
    param (
        # Folder to search
        [Parameter()]
        [string]
        $Path,

        # Include files with double extensions, e.g. '*.tests.ps1', '*.build.ps1' etc.
        [Parameter()]
        [switch]
        $IncludeTests
    )
    [string]$myName                     =   "$($MyInvocation.InvocationName):"

    if (-not [System.IO.Directory]::Exists($Path)) {
        Write-Verbose -Message "$myName Directory `"$Path`" does not exist! Exiting."
        return
    }

    [System.IO.FileInfo[]]$psScriptsAll =   [System.IO.Directory]::EnumerateFiles($Path, '*.ps1')
    if ($psScriptsAll.Count -eq 0) {
        Write-Verbose -Message "$myName Directory `"$Path`" does not contain PowerShell scripts! Exiting."
        return
    }
    Write-Verbose -Message "$myName Directory `"$Path`" contains $($psScriptsAll.Count) PowerShell scripts total."

    if ($IncludeTests) {
        Write-Verbose -Message "$myName Returning all $($psScriptsAll.Count) PowerShell script paths found in folder `"$Path`" including tests, build scripts etc."
        [string[]]$psScriptsOut         =   $psScriptsAll.FullName
        return    $psScriptsOut
    }

    [string[]]$psScriptsOut             =   $psScriptsAll.Where({
        -not ([regex]::IsMatch($_.BaseName, '\.'))
    }).FullName

    if ($psScriptsOut.Count -eq 0) {
        Write-Verbose -Message "$myName Seems like the folder `"$Path`" contains only tests, build scripts or something like. Nothing to return!"
        return
    }
    Write-Verbose -Message "$myName Found $($psScriptsAll.Count) PowerShell scripts in folder `"$Path`"."
    return      $psScriptsOut
}

[string]$fldrNameClasses    =   [System.IO.Path]::Combine($PSScriptRoot, 'Classes')
[string]$fldrNameFuncPriv   =   [System.IO.Path]::Combine($PSScriptRoot, 'Functions', 'Private')
[string]$fldrNameFuncPubl   =   [System.IO.Path]::Combine($PSScriptRoot, 'Functions', 'Public')

[string[]]$importClasses    =   Get-PSScriptsInFolder -Path $fldrNameClasses
[string[]]$importFuncPriv   =   Get-PSScriptsInFolder -Path $fldrNameFuncPriv
[string[]]$importFuncPubl   =   Get-PSScriptsInFolder -Path $fldrNameFuncPubl
[string[]]$exportFunctions  =   $importFuncPubl.ForEach({
    [System.IO.Path]::GetFileNameWithoutExtension($_)
})

$importClasses.ForEach({
    [string]$scriptName =   $_
    try {
        Write-Verbose -Message "Importing class from the script: $scriptName"
        .   $scriptName
    }
    catch {
        Write-Warning -Message "Cannot import class from the script: $scriptName"
        throw   $_
    }
})

@($importFuncPriv + $importFuncPubl).ForEach({
    [string]$scriptName =   $_
    try {
        Write-Verbose -Message "Importing function from the script: $scriptName"
        .   $scriptName
    }
    catch {
        Write-Warning -Message "Cannot import function from the script: $scriptName"
        throw   $_
    }
})

[string[]]$aliasesList  =   @()
$exportFunctions.ForEach({
    [string]$functionName   =   $_
    Write-Verbose -Message "Exporting public function: $functionName"
    Export-ModuleMember -Function $functionName
    try {
        Write-Verbose   -Message "Getting alias for the function: $functionName"
        $aliasesList    +=  (Get-Alias -Definition $functionName -ErrorAction Stop).Name
    }
    catch {
        Write-Verbose   -Message "Unable to get aliases for the function: $functionName"
    }
})
$aliasesList.ForEach({
    Write-Verbose   -Message "Exporting alias: $_"
    Export-ModuleMember -Alias $_
})