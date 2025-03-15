<#
.AUTHOR
Michael Frank

.SYNOPSIS
Imports conditional access from JSON files into Entra ID.

.DESCRIPTION
This PowerShell script imports conditional access policies from JSON files into Microsoft Entra ID using Microsoft Graph API.
It reads conditional access definitions from JSON files in a specified directory and creates the corresponding conditional access policies in Entra ID.

.PARAMETER FilePath
The JSON files in the "CA" child folder containing the conditional access definitions.
#>

# Import the required modules
Import-Module Microsoft.Graph.Beta.Identity.SignIns

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Policy.Read.All, Policy.ReadWrite.ConditionalAccess, Application.Read.All, Group.ReadWrite.All"

# Define the path to the directory containing your JSON files
$ScriptPath = ($MyInvocation.MyCommand).Path
$ScriptDirectory = Split-Path $ScriptPath -Parent
$jsonFilesDirectory = "$($ScriptDirectory)\ConditionalAccess"

# Get all JSON files in the directory
$jsonFiles = Get-ChildItem -Path $jsonFilesDirectory -Filter *.json

# Loop through each JSON file
foreach ($jsonFile in $jsonFiles) {
    try {
        # Read the content of the JSON file and convert it to a PowerShell object
        $policyJson = Get-Content -Path $jsonFile.FullName | ConvertFrom-Json

        #Arrays for included and excluded groups
        $incl = @()
        $excl = @()
        $inclloc = @()
        $exclloc = @()

        # Gets the included Group Names from the json file and converts it into the ID, then feeds it back
        $includedgroups = $policyjson.conditions.users.includegroups
        if($includedgroups){
            foreach ($includedgroup in $includedgroups) {
                $inclid = get-mggroup -all | where-Object{$_.Displayname -eq $includedgroup} | Select-Object ID
                # Checks if the Group Name in the json file is already an ID and if so, tries to find the name by ID
                if(!($inclid)){
                    $inclid = get-mggroup -all | where-Object{$_.id -eq $includedgroup} | Select-Object ID
                }
                $incl += $inclid.id
            }
            $policyjson.conditions.users.includegroups = $incl
        }

        # Gets the excluded Group Names from the json file and converts it into the ID, then feeds it back
        $excludedgroups = $policyjson.conditions.users.excludegroups
        if($excludedgroups){
            foreach ($excludedgroup in $excludedgroups) {
                $exclid = get-mggroup -all | where-Object{$_.Displayname -eq $excludedgroup} | Select-Object ID
                # Checks if the Group Name in the json file is already an ID and if so, tries to find the name by ID
                if(!($exclid)){
                    $exclid = get-mggroup -all | where-Object{$_.id -eq $excludedgroup} | Select-Object ID
                }
                $excl += $exclid.Id
            }
            $policyjson.conditions.users.excludegroups = $excl
        }

        # Gets the included named locations from the json file and converts it into the ID, then feeds it back
        $incllocations = $policyjson.conditions.locations.includeLocations
        if(($incllocations) -and (!($incllocations -eq "AllTrusted") -and !($incllocations -eq "All"))){
            foreach ($incllocation in $incllocations) {
                $incllocid = Get-MgBetaIdentityConditionalAccessNamedLocation -all | where-Object{$_.Displayname -eq $incllocation} | Select-Object ID
                # Checks if the location in the json file is already an ID and if so, tries to find the location by ID
                if(!($incllocid)){
                    $incllocid = Get-MgBetaIdentityConditionalAccessNamedLocation -all | where-Object{$_.id -eq $incllocation} | Select-Object ID
                }
                $inclloc += $incllocid.Id
            }
            $policyjson.conditions.locations.includeLocations = $inclloc
        }

        # Gets the excluded named locations from the json file and converts it into the ID, then feeds it back
        $excllocations = $policyjson.conditions.locations.excludeLocations
        if(($excllocations) -and (!($excllocations -eq "AllTrusted") -and !($excllocations -eq "All"))){
            foreach ($excllocation in $excllocations) {
                $excllocid = Get-MgBetaIdentityConditionalAccessNamedLocation -all | where-Object{$_.Displayname -eq $excllocation} | Select-Object ID
                # Checks if the location in the json file is already an ID and if so, tries to find the location by ID
                if(!($excllocid)){
                    $excllocid = Get-MgBetaIdentityConditionalAccessNamedLocation -all | where-Object{$_.id -eq $excllocation} | Select-Object ID
                }
                $exclloc += $excllocid.Id
            }
            $policyjson.conditions.locations.excludeLocations = $exclloc
        }

        # Gets the Authenticationstrengh from the json file and converts it into the ID, then feeds it back
        $authstrengh = $policyjson.grantControls.authenticationStrength.displayName
        if($authstrengh){
            $authstrenghid = Get-MgBetaIdentityConditionalAccessAuthenticationStrengthPolicy | where-Object{$_.Displayname -eq $authstrengh} | Select-Object ID
            # Checks if the authentication strengh in the json file is already an ID and if so, tries to find the authentication strengh by ID
            if(!($authstrenghid)){
                $authstrenghid = Get-MgBetaIdentityConditionalAccessAuthenticationStrengthPolicy | where-Object{$_.id -eq $authstrengh} | Select-Object ID
            }
            $policyjson.grantControls.authenticationStrength.id = $authstrenghid.id
        }

        # Create a custom object
        $policyObject = [PSCustomObject]@{
            displayName     = $policyJson.displayName
            conditions      = $policyJson.conditions
            grantControls   = $policyJson.grantControls
            sessionControls = $policyJson.sessionControls
            state           = $policyJson.state
        }

        # Convert the custom object to JSON with a depth of 10
        $policyJsonString = $policyObject | ConvertTo-Json -Depth 10

        # Create the Conditional Access policy using the Microsoft Graph API
        $null = New-MgbetaIdentityConditionalAccessPolicy -Body $policyJsonString
    
        # Print a success message
        Write-Host "Policy created successfully: $($policyJson.displayName) " -ForegroundColor Green
    }
    catch {
        # Print an error message if an exception occurs
        Write-Host "An error occurred while creating the policy: $_" -ForegroundColor Red
    }
}