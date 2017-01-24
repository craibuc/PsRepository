Import-Module PsRepository -Force
# $here = Split-Path -Parent $MyInvocation.MyCommand.Path
# $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
# . "$here\$sut"

Describe "Get-Document" {

    $uri = ""

    Context "A document's CUID is provide" {

        # arrange
        $cuid="ARq1jE3YL99Nm9EfzoO_jRA"

        It "gets the document's content" {
            # act
            $actual = Get-Document -Cuid $cuid -Verbose

            # assert
            $actual | Should Be $true
        }

    }

}
