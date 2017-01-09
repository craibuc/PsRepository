<#
.SYNOPSIS
    Query the BusinessObjects Enterprise repository using its SQL-like syntax.

.DESCRIPTION
    Query the BusinessObjects Enterprise repository using its SQL-like syntax.

.PARAMETER Query
    The 'SQL' query to be processed.

.EXAMPLE

    # return the InfoObject with SI_ID of 123456
    PS> Get-InfoObject "SELECT * FROM ci_infoobjects WHERE si_id=123456"

    COM_CLASS                : System.__ComObject
    COM_INTERFACE            : System.__ComObject
    Title                    : Lorem Ipsum
    Description              :
    ParentID                 : 12345
    Keyword                  :
    MarkedAsRead             : False
    Properties               : {...}
    ID                       : 12346
    ...

.EXAMPLE

    # return the InfoObject with SI_ID of 123456
    PS> $infoObject = Get-InfoObject "SELECT * FROM ci_infoobjects WHERE si_id=123456"

    # examine its collection of properties (AKA 'property bag')
    PS> $infoObject.Properties

    COM_CLASS     : System.__ComObject
    COM_INTERFACE : System.__ComObject
    Value         : 123456
    Name          : SI_ID
    Flags         : cePropFlagNone
    Container     : False
    Properties    : {}

    COM_CLASS     : System.__ComObject
    COM_INTERFACE : System.__ComObject
    Value         : Lorem Ipsm
    Name          : SI_NAME
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

function Get-InfoObject {

    [CmdletBinding()]
    param(
        [string]$Query
    )

    Write-Debug "$($MyInvocation.MyCommand.Name)::BEGIN"

    # PS> $DebugPreference = $Continue
    Write-Debug $Query

    if ( !$global:token )
    {
        Get-LogonToken | Out-Null # don't add the token to the pipeline, as this will confuse 'down stream' processing
    }

    $sessionMgr = New-Object CrystalDecisions.Enterprise.SessionMgr
    $session = $sessionMgr.LogonWithToken($global:token)

    $infoStore = [CrystalDecisions.Enterprise.InfoStore]$session.GetService("InfoStore")
    $infoStore.Query($query)

    Write-Debug "$($MyInvocation.MyCommand.Name)::END"

}
