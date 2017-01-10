# PsRepository
PowerShell module to interact with BusinesObjects Enterprise's .Net SDK.

## Usage

~~~powershell
# add reference to module to current PowerShell session
PS> Import-Module PsRepository

# query the repository
PS> Get-InfoObject "SELECT * FROM ci_infoobjects WHERE si_id=23"

# supply credentials
cmdlet Get-LogonToken at command pipeline position 1
Supply values for the following parameters:
server: SERVER
authentication: secWinAd
account: MY_ACCOUNT
password: ********

# results are returned to the pipeline (for additional processing as desired)
Interface                : Root Folder
COM_CLASS                : System.__ComObject
COM_INTERFACE            : System.__ComObject
Title                    : Root Folder
Description              :
ParentID                 : 4
Keyword                  :
MarkedAsRead             : False
Properties               : {, 23, Root Folder, 0...}
ID                       : 23
...
CultureInfo              : en-US
~~~

## Examples

### Explore an InfoObject's PropertyBag (similar to /AdminTools)

~~~powershell
$IOs = Get-InfoObjects -Query "SELECT * FROM ci_INFOobjects WHERE si_kind='CrystalReport' AND si_instance=0" | % {

  Write-Host $_.Title
  
  # Base
  foreach ($property In $_.Properties) {
    if ( $property.Container ) { Write-Host ( "{0}: {1}" -F $Property.Name, 'Container' ) }
    else { Write-Host ( "{0}: {1}" -F $Property.Name, $Property.Value ) }
  }
  
  # ProcessingInfo
  foreach ($property In $_.ProcessingInfo.Properties) {
    if ( $property.Container ) { Write-Host ( "{0}: {1}" -F $Property.Name, 'Container' ) }
    else { Write-Host ( "{0}: {1}" -F $Property.Name, $Property.Value ) }
  }
  
}
~~~

### Use URI syntax to query the InfoStore

~~~powershell
# convert the Uri to SQL, then query the repository to get the InfoObjects
PS> Resolve-UriQuery -Uri 'path://InfoObjects/Root Folder' | Get-InfoObject

Interface                : Root Folder
COM_CLASS                : System.__ComObject
COM_INTERFACE            : System.__ComObject
Title                    : Root Folder
Description              :
ParentID                 : 4
Keyword                  :
MarkedAsRead             : False
Properties               : {, 23, Root Folder, 0...}
...    
~~~

### Other

 - [bv_hierarchy.ps1](Examples/bv_hierarchy.ps1) demonstrates how to connect BusinessViews -> Lists of Value -> Prompt Groups -> Crystal Reports
 
# Personnel
 - Author: Craig Buchanan
 - Contributors: ?
 
