#Requires -Assembly 'System.Linq.Enumerable, System.Core, Version=4.0.0.0'
function Split-PathVariable {
    [CmdletBinding()]
    [OutputType('System.String[]')]
    param (
        # Path string
        [Parameter(
            Mandatory   =   $true,
            ValueFromPipeline   =   $true
        )]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Path
    )

    begin   {
        #   Convert the char [System.IO.Path]::PathSeparator to a string
        [string]$pathSeparator  =   [System.IO.Path]::PathSeparator
        #   Otherwise, the [System.StringSplitOptions]::RemoveEmptyEntries may not work properly if the source string consists of only "path separator" characters
        [System.StringSplitOptions]$stringSplitOptions  =   [System.StringSplitOptions]::RemoveEmptyEntries
    }

    process {
        #   If the string is empty, do nothing
        if	(([string]::IsNullOrEmpty($Path)) -or [string]::IsNullOrWhiteSpace($Path))	{
            return
        }
        #   Split the path
        [string[]]$pathSplitted =   $Path.Split($pathSeparator,$stringSplitOptions)
        #   If the result is empty, do nothing
        if	($pathSplitted.Count	-eq	0)	{
            return
        }
        #   Return the single string
        if	($pathSplitted.Count	-eq	1)	{
            return  $pathSplitted[0]
        }
        #   Remove duplicates
        return  [string[]]([System.Linq.Enumerable]::Distinct($pathSplitted))
    }

    end     {}
}