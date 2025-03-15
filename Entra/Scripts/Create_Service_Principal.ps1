<#
.AUTHOR
Michael Frank

.SYNOPSIS
This PowerShell script creates service principals for specific Microsoft services in Microsoft Entra ID using Microsoft Graph API.

.DESCRIPTION
This PowerShell script using Microsoft Graph API creates service principals for the services Microsoft 365 Copilot, Microsoft Security Copilot and Microsoft Intune Enrollment.
#>

# Import the required modules
Import-Module Microsoft.Graph.Applications

# Connect with the appropriate scopes to create service principals
Connect-MgGraph -Scopes "Application.ReadWrite.All"

# Create service principal for the service Enterprise Copilot Platform (Microsoft 365 Copilot)
New-MgServicePrincipal -AppId fb8d773d-7ef8-4ec0-a117-179f88add510

# Create service principal for the service Security Copilot (Microsoft Security Copilot) 
New-MgServicePrincipal -AppId bb5ffd56-39eb-458c-a53a-775ba21277da

# Create service principal for the service Intune Enrollment (Microsoft Intune Enrollment)
New-MgServicePrincipal -AppId d4ebce55-015a-49b5-a083-c84d1797ae8c