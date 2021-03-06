@{
    RootModule = 'PathFinder.psm1'
    ModuleVersion = '0.0.0.3'
    GUID = '9c013e8e-0be5-4669-9106-b61382890a1a'
    Author = 'drLSDee'
    CompanyName = 'Unknown'
    Copyright = '(c) 2020 drLSDee <tracert0@gmail.com>. All rights reserved.'
    Description = 'Simple and silly PowerShell module for some things with environment variables that store paths like $ env: PATH, $ env: PSModulePath etc. This module does not write any values to the registry or PowerShell profile - it just returns strings or string arrays.'
    PowerShellVersion = '5.1'
    RequiredAssemblies = 'System.Core, Version=4.0.0.0'
    FunctionsToExport = 'Add-Path', 'Find-Path', 'Get-Path', 'Remove-Path'
    CmdletsToExport = '*'
    VariablesToExport = '*'
    AliasesToExport = '*'
    PrivateData = @{
        PSData = @{
            Tags = 'Get-Path', 'Find-Path', 'Add-Path', 'Remove-Path'
            ProjectUri = 'https://github.com/drlsdee/pathfinder'
            ReleaseNotes = 'The module is divided into separate scripts. Added some basic tests. The minimum PowerShell version is set to "5.1". Needs assembly "System.Linq.Enumerable".'
        }
    }
}

