<#
.SYNOPSIS
    Get a Folder (InfoObject) given its Id

.PARAMETER FolderID
    Array of folder IDs to be located

.PARAMETER Table
    Repository 'tables' to query: ci_INFOobjects,ci_APPobjects,ci_SYSTEMobjects (default all three)

.EXAMPLE

    PS> 123, 456 | Get-Folder

#>

function Get-Folder
{

    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('SI_PARENT_FOLDER')]
        [int[]]$FolderID,

        [string[]]$Table=@('ci_INFOobjects','ci_APPobjects','ci_SYSTEMobjects')
    )

    BEGIN {
        $properties=@('SI_ID','SI_NAME','SI_CUID','SI_PARENTID','SI_PARENT_CUID','SI_UPDATE_TS','SI_PARENT_FOLDER','SI_PARENT_FOLDER_CUID')
        $collections=@('SI_PATH')
        $IDs = @()
    }

    PROCESS {
        # accumulate IDs to support a single IN query
        foreach ($ID In $FolderID) {
            $IDs += $ID
        }
    }

    END {

        # folders can appear in any 'TABLE'
        $query = "SELECT * FROM $( $Table -Join ',' ) WHERE si_id IN ( $( $IDs -Join ',' ) )"
        Write-Verbose $query

        Get-InfoObject -q $query | % {

            # hashtable
            $IO = @{}

            foreach ( $property In $properties ) {
                $IO.Add( $property, $_.Properties[$property].Value )
            }

            $IO.Add( 'SI_PATH', @() )
            for ( $i=$_.Properties['SI_PATH'].Properties['SI_NUM_FOLDERS'].Value; $i -gt 0; $i-- ) {
                $Folder = [PscustomObject]@{
                    SI_ID = $_.Properties['SI_PATH'].Properties["SI_FOLDER_ID$i"]
                    SI_NAME = $_.Properties['SI_PATH'].Properties["SI_FOLDER_NAME$i"]
                }
                $IO['SI_PATH']+=$Folder
            }

            # add current folder to path
            $IO['SI_PATH']+=[PsCustomObject]@{SI_ID=$_.Properties['SI_ID'].Value ; SI_NAME=$_.Properties['SI_NAME'].Value}

            # join elements of array/hashtable into path/to/folder format
            $IO.Add( 'SI_FULL_PATH', $( ($IO.SI_PATH | % { $_.SI_NAME}) -Join '/' ) )

            # add a method to serialize the path (useful?)
            Add-Member -MemberType ScriptMethod -InputObject $IO.SI_PATH -Name "Serialize" -Value { ($this | % { $_.SI_NAME}) -Join '/'  } -Force

            # cast and return
            [PsCustomObject]$IO

        } # %

    } # /END

} # /function
