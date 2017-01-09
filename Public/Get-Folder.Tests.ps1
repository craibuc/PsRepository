# Import-Module PsRepository -Force

Describe "Get-Folder" {

    It "should return a Folder" {
        
        # arrange
        $folders = @(23)

        # act
        $actual = $folders | Get-Folder -Verbose

        # assert
        $actual[0].GetType() | Should Be System.Management.Automation.PSCustomObject

    }

}
