<#
.AUTHOR
Michael Frank

.SYNOPSIS
This PowerShell script creates a named location in Entra ID Conditional Access using Microsoft Graph API.

.DESCRIPTION
This PowerShell script creates a named location in Entra ID Conditional Access policies using Microsoft Graph API.
It defines a list of specific countries and regions, including unknown locations, to enhance security by identifying untrusted or high-risk geographic areas.
#>

Import-Module Microsoft.Graph.Beta.Identity.SignIns

Connect-MgGraph -Scopes "Policy.ReadWrite.ConditionalAccess"

$params = @{
"@odata.type" = "#microsoft.graph.countryNamedLocation"
DisplayName = "Unknown and untrusted countries and regions"
CountriesAndRegions = @(
    "RU"
    "CN"
    "IR"
    "KP"
    "BY"
)
IncludeUnknownCountriesAndRegions = $true
}

New-MgBetaIdentityConditionalAccessNamedLocation -BodyParameter $params