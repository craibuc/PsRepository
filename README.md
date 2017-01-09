# PsRepository

## Usage

~~~powershell
# add reference to module to current PowerShell session
PS> Import-<Module PsRepository

# Query the repository
PS> Get-InfoObject "SELECT * FROM ci_infoobjects WHERE si_id=23"

# supply credentials
cmdlet Get-LogonToken at command pipeline position 1
Supply values for the following parameters:
server: SERVER
authentication: secWinAd
account: MY_ACCOUNT
password: ********

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
Instance                 : False
Locale                   : ceLocaleEnglishUS
Actions                  : {Rename, Delete, Properties, New}
ParentInfoObjects        : {23}
Picture                  : System.__ComObject
Files                    :
SchedulingInfo           :
ProcessingInfo           :
SecurityInfo             : CrystalDecisions.Enterprise.SecurityInfo
PluginInterface          : CrystalDecisions.Enterprise.PluginInterface
CUID                     : ASHnC0S_Pw5LhKFbZ.iA_j4
GUID                     : ASGgVi7IW21JpZuAZBL7Q7I
RUID                     : ASHnC0S_Pw5LhKFbZ.iA_j4
ParentCUID               : AXNWWTizCNNBrOt2AVUPfyE
ProgID                   : CrystalEnterprise.Folder
ObjectType               : 1
Parent                   : BOEDEV
SendToDestination        : CrystalDecisions.Enterprise.Destination
Kind                     : Folder
IsDirty                  : True
Locked                   :
LockStatus               :
DeliverToInboxPrincipals : {}
SecurityInfo2            : CrystalDecisions.Enterprise.SecurityInfo2
Delta                    : 
LockInfo                 :
MLTitleLocales           : {EN, AR, CS, DA...}
MLDescriptionLocales     :
FallBackLocale           : en_US
FileLocales              :
PluginIcon               : 0
CustomizedPluginName     :
ParentKind               : Folder
SpecificKind             : Folder
ParentProgID             : CrystalEnterprise.Folder
SpecificProgID           : CrystalEnterprise.Folder
AlertNotification        : CrystalDecisions.Enterprise.AlertNotification
CultureInfo              : en-US
~~~
