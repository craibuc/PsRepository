<#
.SUMMARY
    Saves the files assocated with the InfoObject to the specified path.

.PARAMETER InfoObject
    InfoObject's files to be saved.  Objects may be supplied via the pipeline.

.PARAMETER Path
    Destination directory for the files (default: '.').  Directory created if it doesn't exist.

.PARAMETER Ignore
    Skip any file that's name matches the regular expression (default: '.jpeg$')

.PARAMETER SizeLimit
    Skip any files large than this limitation (default: 10MB).

.EXAMPLE

    # Saves all RPT files (excluding instances) associated with the objects in the 'Public Folders' folder to current directory
    PS> 'SELECT * FROM ci_infoobjects WHERE si_parent_folder=23 AND si_kind='CrystalReport' AND si_instance=0' | Get-InfoObject | Get-Document -Path '.'

.NOTES

    File URIs resemble:
      - frs://Input/a_065/227/061/20833089/1a0c93263f5b27130c.rpt
      - frs://Input/a_065/227/061/20833089/1a0c93263f5c02130e.jpeg
#>

function Get-Document {

    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [Object[]]$InfoObject,

        [Parameter(Position=1, Mandatory=$true)]
        [string]$Path='.',

        [string]$Ignore='.jpeg$',

        [int32]$SizeLimit=10MB
    )

    Begin {
        Write-Debug "$($MyInvocation.MyCommand.Name)::BEGIN"

        # resolve relative directories; create non-existant ones
        if ( !(Test-Path $Path) ) { New-Item -ItemType directory -Path $Path }
        $Path = Get-Item $Path

        if ( !$global:session )
        {
            Get-LogonToken | Out-Null # don't add the token to the pipeline, as this will confuse 'down stream' processing
        }

        $folders=@()

    } # /Begin

    Process {
        foreach ($IO In $InfoObject) {
            Write-Verbose $IO.Title

            if ( !($folders.SI_ID -Contains $IO.ParentId) ) {
                $folder = Get-Folder $IO.ParentId
                Write-Verbose "*** $($folder.SI_FULL_PATH) ***"
                $folders += $folder
            }

            foreach($file In $IO.Files) {

                Write-Debug $file.Name

                if ( $file.Name -NotMatch $Ignore ) {

                    if ( $file.Size -Gt $SizeLimit ) {
                        Write-Warning ("{0} will not be saved because its file size ({1:N0} KB) exceeded the size limit of {2:N0} KB" -F $file.Name, ($file.Size/1KB), ($SizeLimit/1KB))
                    }
                    else {

                        # create a byte array sized to hold the file; cast as an object
                        # [Object]$bufferObject = New-Object System.Byte[]($file.Size)

                        # copy the file to the buffer object
                        # $file.CopyTo([ref]$bufferObject)

                        # cast the object to a byte array
                        # [Byte[]]$buffer = [Byte[]]$bufferObject

                        try {

                            $fullpath = "{0}\{1}.{2}" -F $Path, $_.Title, $file.Name.Split('.')[-1]
                            Write-Verbose ( "Saving {0:N0} KB to {1} ..." -F ($file.Size/1KB), $fullpath)

                            $file.CopyTo([ref] $fullPath)

                            # $stream = New-Object System.Io.FileStream $fullpath, 'Create'
                            # save the byte array as a file
                            # $stream.Write($buffer, 0, $buffer.Length)

                            # $stream = New-Object -TypeName System.IO.MemoryStream
                            # $stream.Write($buffer, 0, $buffer.Length)
                            # $stream.Position=0

                            # $reader = New-Object -TypeName System.Io.StreamReader $stream, System.Text.Encoding.ASCII
                            # $reader.ReadToEnd()
                        }
                        finally {
                            # if ( $stream ) {$stream.Dispose()}
                            if ($file) {$file.Dispose()}
                        }

                    } # /if SizeLimit

                } # /if NotMatch

            } # /foreach $Files

        } # /foreach $InfoObject

    } # /Process

    End { Write-Debug "$($MyInvocation.MyCommand.Name)::END" }
}
