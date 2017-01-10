<#
.SYNOPSIS
    Converts a URI-formatted query (e.g. path://InfoObjects/Root Folder) to one (or more) SQL-like queries (SELECT * FROM ci_infoobjects WHERE ...).

.DESCRIPTION
    Converts a URI-formatted query (e.g. path://InfoObjects/Root Folder) to one (or more) SQL-like queries (SELECT * FROM ci_infoobjects WHERE ...).

.PARAMETER Uri
    The Uri to be processed.

.PARAMETER PageSize
    Number of InfoObjects to be returned by any given SQL query (effects the number of queries that are generated).  Default = 200

.PARAMETER Incremental
    Not sure what this really does.

.EXAMPLE

    # convert Uri to SQL
    PS> Resolve-UriQuery -Uri 'path://InfoObjects/Root Folder'
    SELECT TOP 200 static,SI_CUID,SI_PARENT_CUID FROM CI_INFOOBJECTS WHERE (SI_PARENTID IN (4) AND SI_NAME='Root Folder') AND ((SI_ID>='23')) ORDER BY SI_ID

.EXAMPLE

    # convert the Uri to SQL, then query the repository to get the InfoObjects
    PS> Resolve-UriQuery -Uri 'path://InfoObjects/Root Folder' | Get-InfoObject

    COM_CLASS     : System.__ComObject
    COM_INTERFACE : System.__ComObject
    Value         : 123456
    Name          : SI_ID
    Flags         : cePropFlagNone
    Container     : False
    Properties    : {}
    ...    

.NOTES
    N/A

.LINK
    http://help.sap.com/businessobject/product_guides/EvIn4/en/EvIn_4_help_querybuilder_en.pdf

.FUNCTIONALITY
    PowerShell Language
#>

function Resolve-UriQuery {

    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]$Uri,
        [int]$PageSize = 200,
        [switch]$Incremental
    )

    Begin { 
        Write-Debug "$($MyInvocation.MyCommand.Name)::BEGIN"

        if ( !$global:session )
        {
            Get-LogonToken | Out-Null # don't add the token to the pipeline, as this will confuse 'down stream' processing
        }

        $infoStore = [CrystalDecisions.Enterprise.InfoStore]$global:session.GetService("InfoStore")

        $options = New-Object CrystalDecisions.Sdk.Uri.PagingQueryOptions
        $options.IsIncremental = $Incremental
        $options.pageSize = $PageSize

    } # /Begin
    Process {
        try {

            foreach ($U In $Uri) {

                Write-Verbose "Uri: $U"

                [CrystalDecisions.Sdk.Uri.IPageResult]$pageResult = [CrystalDecisions.Enterprise.PageFactoryFacade]::PageResult($infoStore, $U, $options)
                [System.Collections.IEnumerator]$enumerator = $pageResult.Enumerator

                while ( $enumerator.MoveNext() ) 
                {
                    $pagedUri = [string]$enumerator.Current
                    Write-Debug "PagedUri: $pagedUri"

                    [CrystalDecisions.Sdk.Uri.IStatelessPageInfo]$pageInfo = [CrystalDecisions.Enterprise.PageFactoryFacade]::FetchPage($infoStore, $pagedUri, $options)

                    $pageInfo.PageSQL
                    Write-Debug ("PageSQL: {0}" -F $pageInfo.PageSQL )

                } # /while

            } # /foreach

        } # /try
        catch { Write-Error $_.Exception.Message }
        
    } # /Process
    End { Write-Debug "$($MyInvocation.MyCommand.Name)::END" }
}
