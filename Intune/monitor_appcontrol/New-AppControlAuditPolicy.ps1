<#PSScriptInfo
    .VERSION
        1.0.0
    .AUTHOR
        Michael Frank
    .COMPANYNAME
        michaelsendpoint.com
    .Name
        New-AppControlAuditPolicy
    .TAGS
        AppControl, AuditPolicy, Intune, CIPolicy, Logging, PowerShell
    .SYNOPSIS
        Creates and converts an AppControl audit policy for Intune-managed devices.
    .creationdate
        21.04.2025
    .lasteditdate
        21.04.2025
    .DESCRIPTION
        This script generates a Code Integrity (AppControl) audit policy. 
        It creates the policy in the Intune Management Extension log folder, converts it into 
        a supplemental policy.
#>

# ------------------------------------------------- Logging  ----------------------------------------------------------------

$logpath = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs"
$logname = (Get-Date -Format "dd-MM-yyyy") + "_script.log"

# ------------------------------------------------- Create audit policy and convert it --------------------------------------
Start-Transcript -Path "$($logpath)\$($logname)" -Append -Verbose

# When running this command manually, it will print warnings for event logs that describe files that are no longer present on the system.
# There will be no exceptions added for files that are no longer on the system. 
New-CIPolicy -FilePath "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\$($env:computername)_policy.xml" -Audit -Level FilePublisher -Fallback SignedVersion,FilePublisher,Hash -UserPEs -MultiplePolicyFormat

# Convert the newly created base policy into a supplemental policy to use it alongside the default Microsoft base policy.
Set-CIPolicyIdInfo -FilePath "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs\$($env:computername)_policy.xml" -SupplementsBasePolicyID "{2DA0F72D-1688-4097-847D-C42C39E631BC}"

Stop-Transcript