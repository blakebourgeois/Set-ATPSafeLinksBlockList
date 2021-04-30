<#
.DESCRIPTION
    Set-ATPSafeLinksBlockList provides a way to bulk add URLs to the Safe Links block list.
    All of the blocked URLs must be pushed up at once. There is not a mechanism to add a single URL to the policy outside the GUI.
    
.DEPENDENCIES
  This uses modern authentication so you need the Exchange Online Powershell Module (ExchangeOnlineManagement). 
  You must have access in O365 to update Safe Links policies.
  You must have a CSV with the first column being "URL"
  The CSV can have as many other columns and details as you want.
    
.NOTES
    Version       : 2.1
    Author        : Blake Bourgeois
    Creation Date : 3/13/2019
    Modified      : 4/30/2021
#>


# previously used the legacy exchange module, this now uses EXO v2
# to install, run Install-Module ExchangeOnlineManagement
# prevents need for re-authentication if you've already run and imported this in current sesssion
try{Get-ATPPolicyForO365 | Out-Null
    Write-Host "You're already connected to Exchange Online!" -ForegroundColor Green}
catch{Connect-ExchangeOnline
    Write-Host "Successfully connected to Exchange Online!" -ForegroundColor Green}

## Build the blocklist ##

# You will need to edit this path to your actual blocklist csv.
$path = "blocklist.csv"
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

#NOTE: it is possible to ADD and REMOVE specific values - https://docs.microsoft.com/en-us/powershell/module/exchange/set-atppolicyforo365?view=exchange-ps
#however this method uses the CSV as the source of record, so the block list is always synced with the csv rather than having to specify specific URLs to add and remove.
# you COULD pull down the CSV and diff it against the contents of the policy and make the proper removals/additions that way--which is honestly probably better than this IEX method...maybe for next update

# create the command
$commandstring = "Set-ATPPolicyForO365 -Identity Default -BlockUrls $blockliststring"

Write-Host "Preparing to execute following command: $commandstring" -ForegroundColor Yellow
# excute the full command
iex $commandstring

Write-Host "Complete." -ForegroundColor Green
