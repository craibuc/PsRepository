# Import-Module PsRepository -Force

Describe "Get-InfoObject" {

    It "should return an InfoObject" {
        
        # arrange
        $query = "SELECT * FROM ci_INFOobjects WHERE si_id=23"

        # act
        $actual = Get-InfoObject -Query $query -Verbose

        # assert
        $actual[0].GetType() | Should Be CrystalDecisions.Enterprise.Desktop.Folder

    }

}
