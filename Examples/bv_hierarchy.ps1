import-module PsRepository -Force

<#
Dependencies:
    - PsRepository (https://github.com/craibuc/PsRepository)
    - Join-Object (https://github.com/RamblingCookieMonster/PowerShell/blob/master/Join-Object.ps1)
#>

<#
.SMUUARY
Get all Business Views from the repository
#>
function Get-BusinessView
{

    [CmdletBinding()]
    Param(
        [string]$SI_CUID
    )

    $query = "SELECT * FROM ci_APPobjects WHERE si_kind='MetaData.BusinessView'"
    if ($SI_CUID) { $query += " AND si_cuid='$SI_CUID'"}

    Get-InfoObject -Query $query | % {

        $IO = @{}
        
        foreach ( $property In @('SI_ID','SI_NAME','SI_CUID','SI_KIND') ) {
            $IO.Add( $_.Properties[$property].Name, $_.Properties[$property].Value )
        }

        # foreach ( $collection In @('SI_METADATA_CHILDREN','SI_METADATA_ALL_DESCENDANTS') ) {
        #     $IO.Add( $collection, @() )
        #     foreach ($property In $_.Properties[$collection].Properties) {
        #         if ( $property.Name -ne 'SI_TOTAL') { $IO[$collection] += $property.value }
        #     }
        # }

        [PsCustomObject]$IO

    }

}

Write-Host "Retrieving business views..."
$io_bv = Get-BusinessView
# $io_bv | Select-Object @{name='SI_CUID_BV';expression={$_.SI_CUID}}, @{name='SI_NAME_BV';expression={$_.SI_NAME}} | ConvertTo-Csv -NoTypeInformation | Out-File ~\Desktop\bv.txt
# $io_bv | Format-Table

<#
.SUMMARY
Get all Lists of Value from repository
#>
function Get-LoV
{

    [CmdletBinding()]
    Param()

    $query = "SELECT * FROM ci_APPobjects WHERE si_kind='MetaData.MetaDataRepositoryInfo' AND si_instance=0"
    Get-InfoObject -Query $query | % {

        $IO = @{}
    
        foreach ( $property In @('SI_ID','SI_NAME','SI_CUID','SI_KIND') ) {
            $IO.Add( $_.Properties[$property].Name, $_.Properties[$property].Value )
        }

        $IO.Add('SI_METADATA_BVCONN_ATTRIBUTES', $_.Properties['SI_METADATA_PROPERTIES'].Properties['SI_METADATA_BVCONN_ATTRIBUTES'].Value )

        # foreach ( $collection In @('SI_METADATA_CHILDREN','SI_METADATA_ALL_DESCENDANTS') ) {
        #     $IO.Add( $collection, @() )
        #     foreach ($property In $_.Properties[$collection].Properties) {
        #         if ( $property.Name -ne 'SI_TOTAL') { $IO[$collection] += $property.value }
        #     }
        # }

        # foreach ( $collection In @('SI_METADATA_PROPERTIES') ) {
        #     $IO.Add( $collection, @() )
        #     foreach ($property In $_.Properties[$collection].Properties) {
        #         if ( $property.Name -ne 'SI_TOTAL') { $IO[$collection] += $property.value }
        #     }
        # }

        [PsCustomObject]$IO

    }

}

Write-Host "Retrieving lists of value..."
$io_lov = Get-LoV
# $io_lov | Select-Object @{name='SI_CUID_LOV';expression={$_.SI_CUID}}, @{name='SI_NAME_LOV';expression={$_.SI_NAME}}, @{name='SI_CUID_BV';expression={$_.SI_METADATA_BVCONN_ATTRIBUTES}} | ConvertTo-Csv -NoTypeInformation | Out-File ~\Desktop\lov.txt
# $io_lov | Format-Table

# combine BV + LOV
$io_bv_lov = Join-Object -Left $io_bv -Right $io_lov -LeftJoinProperty SI_CUID -RightJoinProperty SI_METADATA_BVCONN_ATTRIBUTES -Type AllInLeft -RightProperties SI_CUID, SI_NAME -Suffix '_LOV' |
    Select-Object @{name='SI_CUID_BV';expression={$_.SI_CUID}}, @{name='SI_NAME_BV';expression={$_.SI_NAME}}, SI_CUID_LOV, SI_NAME_LOV
# $io_bv_lov | format-list

<#
.SUMMARY
Get all Prompt Groups from repository
#>
function Get-PromptGroup
{

    [CmdletBinding()]
    Param()

    # query the repository
    $query = "SELECT * FROM ci_APPobjects WHERE si_kind='RepositoryPromptGroup'"
    Get-InfoObject -Query $query | % {

        $IO = @{}
    
        foreach ( $property In @('SI_ID','SI_NAME','SI_CUID') ) {
            $IO.Add( $_.Properties[$property].Name, $_.Properties[$property].Value )
        }

        foreach ( $collection In @('SI_METADATA_CHILDREN') ) {
            $IO.Add( $collection, @() )
            foreach ($property In $_.Properties[$collection].Properties) {
                if ( $property.Name -ne 'SI_TOTAL') { $IO[$collection] += $property.value }
            }
        }

        $IO.Add('SI_CUID_LOV', $IO.SI_METADATA_CHILDREN[0] )

        [PsCustomObject]$IO

    }
}

Write-Host "Retrieving prompt groups..."
$io_pg = Get-PromptGroup
# $io_pg | Select-Object @{name='SI_CUID_PG';expression={$_.SI_CUID}}, @{name='SI_NAME_PG';expression={$_.SI_NAME}}, SI_CUID_LOV | ConvertTo-Csv -NoTypeInformation | Out-File ~\Desktop\pg.txt
# $io_pg | Format-Table

# combine BV/LOV + PG
$io_bv_lov_pg = Join-Object -Left $io_bv_lov -Right $io_pg -LeftJoinProperty SI_CUID_LOV -RightJoinProperty SI_CUID_LOV -Type AllInLeft -RightProperties SI_CUID, SI_NAME -Suffix '_PG' |
    Select-Object SI_CUID_BV, SI_NAME_BV, SI_CUID_LOV, SI_NAME_LOV, SI_CUID_PG, SI_NAME_PG
# $io_bv_lov_pg | format-list

<#
.SUMMARY
Extract dynamic parameters from all Crystal Reports from the repository
#>
function Get-DynamicParameters
{

    [CmdletBinding()]
    Param(
        [string]$SI_CUID
    )

    # query the repository
    $query = "SELECT TOP 10000 * FROM ci_infoobjects WHERE si_kind='CrystalReport' AND si_instance=0" # + " AND si_cuid in ('ASxtcZZPx_NOnaR2RdZEDbw','Ae4kACVnsalOn2oLd0giEc0')"
    if ($SI_CUID) { $query += " AND si_cuid='$SI_CUID'"}
    $query += " ORDER BY si_name"

    Get-InfoObject -Query $query | % {

        Write-Verbose ("{1} [{0}]" -f $_.Properties['SI_CUID'], $_.Properties['SI_NAME'])
        $io = $_

        # get the CUIDs of the prompt groups (PG) that may be associated w/ the reports
        # enumerate InfoObject.ProcessingInfo.Properties['SI_PROMPTS'] collection; 
        # examine each $_.Properties['SI_PROMPT?'].Properties['SI_GROUP_ID']
        $_.ProcessingInfo.Properties['SI_PROMPTS'].Properties | ? { $_.Name -ne 'SI_NUM_PROMPTS' } | % {

            if ( $_.Properties['SI_GROUP_ID'] ) {
                [PsCustomObject]@{
                    SI_ID = $io.Properties['SI_ID'].Value
                    SI_CUID = $io.Properties['SI_CUID'].Value
                    SI_NAME = $io.Properties['SI_NAME'].Value
                    SI_PARENT_FOLDER = $io.Properties['SI_PARENT_FOLDER'].Value
                    SI_PARENT_FOLDER_CUID = $io.Properties['SI_PARENT_FOLDER_CUID'].Value
                    PARAMETER_NAME = $_.Properties['SI_NAME'].Value
                    # extract CUID from URI (eor://cms:6400/AccGouUJqBRLhn3xG7IB6h8)
                    SI_CUID_PG = $_.Properties['SI_GROUP_ID'].Value.Split('/')[-1]
                 }
            }

        } # /SI_PROMPTS
    }

}

Write-Host "Retrieving dynamic parameters..."
$io_rpt = Get-DynamicParameters # -SI_CUID 'ASxtcZZPx_NOnaR2RdZEDbw' 
# $io_rpt | ConvertTo-Csv -NoTypeInformation | Out-File ~\Desktop\rpt.txt
# $io_rpt | format-list

# get unique list of folder IDs
$io_fldr = $io_rpt | SELECT si_parent_folder -unique | Get-Folder

# combine RPT + FOLDER
$io_rpt_fldr = Join-Object -Left $io_rpt -Right $io_fldr -LeftJoinProperty SI_PARENT_FOLDER -RightJoinProperty SI_ID -Type AllInLeft -RightProperties SI_FULL_PATH |
    Select-Object @{name='SI_ID_RPT';expression={$_.SI_ID}}, @{name='SI_CUID_RPT';expression={$_.SI_CUID}}, @{name='SI_NAME_RPT';expression={$_.SI_NAME}}, SI_FULL_PATH, PARAMETER_NAME, SI_CUID_PG

# display intermediate results
# $io_rpt_fldr | ConvertTo-Csv -NoTypeInformation | Out-File ~\Desktop\rpt_fldr.txt
# $io_rpt_fldr | format-list

# combine BV/LOV/PG + RPT/FLDR
$hierarchy = Join-Object -Left $io_bv_lov_pg -Right $io_rpt_fldr -LeftJoinProperty SI_CUID_PG -RightJoinProperty SI_CUID_PG -Type AllInLeft
$hierarchy | sort SI_NAME_BV, SI_NAME_LOV,SI_NAME_PG, SI_NAME_RPT | SELECT SI_NAME_BV, SI_NAME_LOV, SI_NAME_PG, SI_FULL_PATH, SI_NAME_RPT, PARAMETER_NAME | Format-Table
$hierarchy | sort SI_NAME_BV, SI_NAME_LOV,SI_NAME_PG, SI_NAME_RPT | SELECT SI_CUID_BV, SI_NAME_BV, SI_CUID_LOV, SI_NAME_LOV, SI_CUID_PG, SI_NAME_PG, SI_FULL_PATH, SI_CUID_RPT, SI_NAME_RPT, PARAMETER_NAME | ConvertTo-Csv -NoTypeInformation | Out-File ~\Desktop\hierarchy.txt