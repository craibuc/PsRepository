# Import-Module PsRepository -Force

Describe "Get-InfoObject" {

    Context "Query parameter" {

        # arrange
        $query = "SELECT * FROM ci_INFOobjects WHERE si_id=23"

        It "should return an InfoObject" {            
            # act
            $actual = Get-InfoObject -Query $query -Verbose

            # assert
            $actual.Count | Should Be 1
            $actual[0].GetType() | Should Be CrystalDecisions.Enterprise.Desktop.Folder
        }
    }

    Context "Pipeline" {

        # arrange
        $query = "SELECT * FROM ci_INFOobjects WHERE si_id=23","SELECT * FROM ci_SYSTEMobjects WHERE si_id=4"

        It "should return an InfoObject" {
            # act
            $actual = $query | Get-InfoObject -Verbose

            # assert
            $actual.Count | Should Be 2
            $actual.GetType() | Should Be System.Object[]
        }
    }

}
