Import-Module PsEnterprise -Force

# $here = Split-Path -Parent $MyInvocation.MyCommand.Path
# $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
# . "$here\$sut"

Describe "Open-ReportDocument" {

    $ID=301658

    It "Opens a report" {
        $actual = Open-ReportDocument $ID -Verbose
        $actual | Should Be ReportDocument
    }

}
