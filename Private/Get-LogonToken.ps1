<#
.SYNOPSIS
    Generate a token for 

.DESCRIPTION
    Join data from two sets of objects based on a common value

.PARAMETER Server
    The IP address of name of CMS

.PARAMETER Authentication
    secEnterprise, secWinAD

.PARAMETER Account

.PARAMETER Password

.EXAMPLE

    PS> Get-LogonToken

    cmdlet Get-LogonToken at command pipeline position 1
    Supply values for the following parameters:
    server: SERVER_NAME_OR_IP
    authentication: secwinad
    account: MY_BOE_ACCOUNT
    password: ******
    server_name_or_ip:6400@20811775JvsxS...

.NOTES
    This function is used internally to capture authentication credentials; it's not necessary to use it directly.

.LINK
    N/A

.FUNCTIONALITY
    PowerShell Language

#>
function Get-LogonToken {

    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$server,

        [Parameter(Position=1,Mandatory=$true)]
        [ValidateSet('secWinAD','secEnterprise')]
        [string]$authentication,

        [Parameter(Position=2,Mandatory=$true)]
        [string]$account,

        [Parameter(Position=3,Mandatory=$true)]
        [SecureString]$password
    )

    Write-Debug "$($MyInvocation.MyCommand.Name)::BEGIN"

    # PS> $DebugPreference = $Continue
    Write-Debug $server
    Write-Debug $authentication
    Write-Debug $account

    # authenticate
    $sessionMgr = New-Object CrystalDecisions.Enterprise.SessionMgr
    $session = $sessionMgr.Logon($account, (ConvertTo-PlainText $password) ,$server, $authentication)

    # create token
    $logonTokenMgr = $session.LogonTokenMgr
    $token = $logonTokenMgr.CreateLogonTokenEx('',1440,-1)
    Write-Debug $token

    # persist in session variable
    $global:token = $token
    
    # return token
    $token
    
    Write-Debug "$($MyInvocation.MyCommand.Name)::END"

}
