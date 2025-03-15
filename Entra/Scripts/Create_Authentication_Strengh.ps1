<#
.AUTHOR
Michael Frank

.SYNOPSIS
Create a new Authentication Strengh in Microsoft Entra ID using Microsoft Graph API.
#>

New-MgBetaIdentityConditionalAccessAuthenticationStrengthPolicy -Displayname "TPA" -AllowedCombinations "temporaryAccessPassOneTime"