#   Declare paths and patterns
[string]$psSearchPattern        =   '*.ps1'
[string]$psSearchOptions        =   [System.IO.SearchOption]::TopDirectoryOnly
[string]$functionPathPrivate    =   [System.IO.Path]::Combine($PSScriptRoot,'Functions','Private')
[string]$functionPathPublic     =   [System.IO.Path]::Combine($PSScriptRoot,'Functions','Public')
#   Get and import all functions
##  Enumerate private functions
try	{
    [System.IO.FileInfo[]]$functionFilesPrivate =   [System.IO.Directory]::EnumerateFiles($functionPathPrivate,$psSearchPattern,$psSearchOptions)
}
catch	{
    [System.IO.FileInfo[]]$functionFilesPrivate =   @()
}
##  Enumerate public functions
try	{
    [System.IO.FileInfo[]]$functionFilesPublic =   [System.IO.Directory]::EnumerateFiles($functionPathPublic,$psSearchPattern,$psSearchOptions)
}
catch	{
    [System.IO.FileInfo[]]$functionFilesPublic =   @()
}
##  Import private and public functions
foreach ($functionFile in @($functionFilesPrivate + $functionFilesPublic)) {
    [System.IO.FileInfo]$functionFile   =   $functionFile
    [string]$scriptName =   $functionFile.BaseName
    #   Skip files with double extensions
    if	($scriptName.Contains('.'))	{
        continue
    }
    #   Import the script
    [string]$scriptPath =   $functionFile.FullName
    .   $scriptPath
    #   If the function is public
    if	($functionFile.Directory.FullName   -ieq    $functionPathPublic)	{
        #   export the function
        Export-ModuleMember -Function $scriptName
        #   try to get alias(es)
        try	{
            [string[]]$functionAliases  =   Get-Alias -ErrorAction Stop -Definition $scriptName
        }
        catch	{
            [string[]]$functionAliases  =   @()
        }
        #   if alias found
        if	($functionAliases.Count	-gt	0)	{
            Export-ModuleMember -Alias $functionAliases
        }
    }
}