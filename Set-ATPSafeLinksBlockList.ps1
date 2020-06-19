<#
.DESCRIPTION
    Set-ATPSafeLinksBlockList provides a way to bulk add URLs to the Safe Links block list.
    All of the blocked URLs must be pushed up at once. There is not a mechanism to add a single URL to the policy outside the GUI.
    
.DEPENDENCIES
  This uses modern authentication so you need the Exchange Online Powershell Module. 
  You must have access in O365 to update Safe Links policies.
  You must have a CSV with the first column being "URL"
  The CSV can have as many other columns and details as you want.
    
.NOTES
    Version       : 2.0
    Author        : Blake Bourgeois
    Creation Date : 3/13/2019
#>

# QOL: Function checks for connection to Azure, and initates one if necessary
function Check-EXOPSStatus{
        if(Get-Command Connect-EXOPSSession -ErrorAction SilentlyContinue){
            if(Get-AtpPolicyForO365 -ErrorAction SilentlyContinue)
                {write-host "   You're already connected to Exchange Online." -ForegroundColor Green}
            else{
                Connect-EXOPSSession
                }
            }
        else{
            write-host "   Connecting to Azure AD..." -ForegroundColor Yellow
            #this module is really stupid so you have to import it
            $MFAExchangeModule = ((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter CreateExoPSSession.ps1 -Recurse ).FullName | Select-Object -Last 1) 
            . $MFAExchangeModule

            ## Connect to Exchange Online ##
            Connect-EXOPSSession
            if(Get-AtpPolicyForO365 -ErrorAction SilentlyContinue){
                write-host "   Successfully connected to Exchange Online!" -ForegroundColor Green
            }
        }
}

Check-EXOPSStatus

## Build the blocklist ##

# You will need to edit this path to the blocklist CSV.
$path = ""
$blocklist = import-csv $path
Write-Host "Blocklist has been imported." -ForegroundColor Green

# concatenate all the URLS
$blockliststring = ""
foreach($item in $blocklist){
$blockliststring = $blockliststring + ", " + $item.URL
}

# take off the leading ", "
$blockliststring = $blockliststring.Substring(2)

# in testing the command would fail when passing the $blockliststring as a variable
# to get around this we'll concatenate the command and the blocklist string and then we can execute it 
# this works where passing the variable does not, though use of iex might set off some flags...

# create the command
$commandstring = "Set-ATPPolicyForO365 -Identity Default -BlockUrls $blockliststring"

Write-Host "Preparing to execute following command: $commandstring" -ForegroundColor Yellow
# excute the full command
iex $commandstring

Write-Host "Complete." -ForegroundColor Green
