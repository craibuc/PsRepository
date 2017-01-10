# Import-Module PsRepository -Force

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-LogonToken" {

    $server = Read-Host 'Server'
    $authentication = Read-Host 'Authentication [secEnterprise|secWinAD]'
    $account = Read-Host 'Account'
    $securePassword = Read-Host 'Password' -AsSecureString

    It "generates a logon token and saves it in a session variable" {
        $actual = Get-LogonToken -Server $server -Authentication $authentication -Account $account -Password $securePassword -Verbose

        $actual | Should Not Be $Null
    }

}
