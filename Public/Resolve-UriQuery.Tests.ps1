Import-Module PsRepository -Force

# $here = Split-Path -Parent $MyInvocation.MyCommand.Path
# $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
# . "$here\$sut"

Describe "Resolve-UriQuery" {

    Context "Container" {
        # arrange
        $url = "path://InfoObjects/Root Folder"
        $expected = "SELECT TOP 200 static,SI_CUID,SI_PARENT_CUID FROM CI_INFOOBJECTS WHERE (SI_PARENTID IN (4) AND SI_NAME='Root Folder') AND ((SI_ID>='23')) ORDER BY SI_ID"
        It "converts a path to a container to a single query" {
            # act
            $actual = Resolve-UriQuery -Uri $url -Verbose

            # assert
            $actual | Should Be $expected
        }
    }

    Context "Objects in container" {
        # arrange
        $url = "path://InfoObjects/Root Folder/"
        $expected = "SELECT TOP 200 static,SI_CUID,SI_PARENT_CUID FROM CI_INFOOBJECTS WHERE (SI_PARENTID IN (23)) AND ((SI_ID>='9607')) ORDER BY SI_ID"

        It "converts a path to a container's objects to a single query" {
            # act
            $actual = Resolve-UriQuery -Uri $url -Verbose

            # assert
            $actual | Should Be $expected
        }
    }

    Context "Objects + Container" {
        # arrange
        $url = "path://InfoObjects/Root Folder+/"
        $expected = "SELECT TOP 200 static,SI_CUID,SI_PARENT_CUID FROM CI_INFOOBJECTS WHERE ((SI_PARENTID IN (23) OR SI_ID IN (23))) AND ((SI_ID>='23')) ORDER BY SI_ID"

        It "converts a path to a container and its collection into two queries" {
            # act
            $actual = Resolve-UriQuery -Uri $url -Verbose

            # assert
            $actual | Should Be $expected
        }
    }

    Context "PageSize parameter is set" {
        # arrange
        $pageSize=1
        $url = "path://InfoObjects/Root Folder"
        $expected = "SELECT TOP $pageSize static,SI_CUID,SI_PARENT_CUID FROM CI_INFOOBJECTS WHERE (SI_PARENTID IN (4) AND SI_NAME='Root Folder') AND ((SI_ID>='23')) ORDER BY SI_ID"

        It "Adjusts the query accordingly" {
            # act
            $actual = Resolve-UriQuery -Uri $url -PageSize $pageSize -Verbose

            # assert
            $actual | Should Be $expected            
        }
    }

    Context "When the number of objects exceedsthe page size" {
        # arrange
        $pageSize=10
        $url = "path://InfoObjects/**[si_kind='Folder']"
        $expected = "SELECT TOP $pageSize static,SI_CUID,SI_PARENT_CUID FROM CI_INFOOBJECTS WHERE SI_PARENTID IN (23) ORDER BY SI_ID"

        It "generates multiple queries" {
            # act
            $actual = Resolve-UriQuery -Uri $url -PageSize $pageSize -Verbose

            # assert
            $actual.GetType() | Should Be System.Object[]
            $actual.Count | Should BeGreaterThan 1
        }
    }   

    Context "Pipeline" {
        # arrange
        $Uris = "path://InfoObjects/Root Folder","path://InfoObjects/Root Folder/"

        It "Accepts URIs via the pipeline" {
            # act
            $actual = $Uris | Resolve-UriQuery -Verbose

            # assert
            $actual.GetType() | Should Be System.Object[]
            $actual.Count | Should Be 2
            
        }
    }

}
