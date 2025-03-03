<#
.SYNOPSIS
Imports configuration policies from JSON files into Microsoft Graph.

.DESCRIPTION
This script connects to the Microsoft Graph API and imports configuration policies from JSON files located in the 'ConfigurationProfiles' directory relative to the script's location.
The script first connects to the Microsoft Graph API using the 'DeviceManagementConfiguration.ReadWrite.All' scope.
For each JSON file in the 'ConfigurationProfiles' directory, the script reads the content, converts it to a PowerShell object, and attempts to create a new configuration policy in Microsoft Graph.
If the creation fails, it attempts to create a new device configuration instead.

.NOTES
This script requires the Microsoft Graph PowerShell SDK to be installed and configured.
#>

# Import needed modules
import-module Microsoft.Graph.Beta.DeviceManagement

# Connect to Microsoft Graph
Connect-MgGraph -Scopes 'DeviceManagementConfiguration.ReadWrite.All'

# Define the path to the directory containing your JSON files
$ScriptPath = ($MyInvocation.MyCommand).Path
$ScriptDirectory = Split-Path $ScriptPath -Parent
$jsonFilesDirectory = "$($ScriptDirectory)\ConfigurationProfiles"

# Get all JSON files in the directory
$jsonFiles = Get-ChildItem -Path $jsonFilesDirectory -Filter *.json

# Loop through each JSON file
foreach ($jsonFile in $jsonFiles) {
	# Read the content of the JSON file and convert it to a PowerShell object
	$Json = Get-Content -Path $jsonFile.FullName | convertfrom-json -ashashtable

	Try {
		#without Error Action ptentioal Errors would not be terminating. Only terminating Errors are catched by the 'catch'.
		New-MgBetaDeviceManagementConfigurationPolicy -AdditionalProperties $json -ErrorAction Stop
	}
	catch {
		#In the Configuration Policy Option in Intune are 2 differnet species of policies. Thats why the catch is needed
		New-MgBetaDeviceManagementDeviceConfiguration -AdditionalProperties $json
	}
	finally {
		Write-Host "Created configuration $($json.displayName)$($json.name) policy successfully"
	}
}