<#
.SUMMARY
    Open a Crystal ReportAppFactory

.Parameter ID

.Parameter KeepOpen

.EXAMPLE

PS> Open-ReportDocument -ID 123456

#>
function Open-ReportDocument {

    [CmdletBinding()]
    param(
        [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [Alias('SI_ID')]
        [int[]]$ID,
        [switch]$KeepOpen
    )

    Begin {
        Write-Debug "$($MyInvocation.MyCommand.Name)::Begin"

        if ( !$global:session )
        {
            Get-LogonToken | Out-Null # don't add the token to the pipeline, as this will confuse 'down stream' processing
        }

        # $reportAppFactory = [CrystalDecisions.ReportAppServer.ClientDoc.ReportAppFactory]$enterpriseService.Interface
        $enterpriseService = [CrystalDecisions.Enterprise.EnterpriseService]$global:session.GetService("RASReportFactory")
    } # /Begin
    Process {
        Write-Debug "$($MyInvocation.MyCommand.Name)::Process"

        foreach ( $Item In $ID) {
            try {
                # throws cast error
                # $reportDocument = $reportAppFactory.OpenDocument($ID,0)

                $reportDocument = $enterpriseService.Interface.OpenDocument($Item, 0)
                $reportDocument
            }
            catch { Write-Error $_.Exception.Message}
            finally {
                if ( $reportDocument -And -Not $KeepOpen ) {
                    Write-Debug "Closing $Item"
                    $reportDocument.Close()
                }                
            }
        } # /foreach

    } # /Process
    End {Write-Debug "$($MyInvocation.MyCommand.Name)::End"}
    
}
