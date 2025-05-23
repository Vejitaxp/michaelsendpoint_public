<#PSScriptInfo
    .VERSION
        1.0.0
    .AUTHOR
        Michael Frank
    .COMPANYNAME
        michaelsendpoint.com
    .Name
        Get-AppControlEvent
    .TAGS
        Event Logs, AppLocker, CodeIntegrity, PowerShell, Windows, CSV Export
    .SYNOPSIS
        Retrieves and exports unique events from Windows Event Logs for specified Event IDs.
    .creationdate
        15.04.2025
    .lasteditdate
        21.04.2025
    .DESCRIPTION
        This script retrieves events from the Windows Event Logs for a predefined list of Event IDs. 
        It supports two providers: Microsoft-Windows-CodeIntegrity and Microsoft-Windows-AppLocker. 
        The script filters the events for uniqueness and exports them to XML format. 
        The exported files are saved in the Intune Management Extension logs folder.
#>

# ------------------------------------------------- Logging function -------------------------------------------------------

function log
{
    Param(
        [string]$message
    )
    $date = Get-Date -Format "dd.MM.yyyy HH:mm:ss"
    $output = "$($date) - $($message)"
    return $output
}

$logpath = "$($env:ProgramData)\Microsoft\IntuneManagementExtension\Logs"
$logname = (Get-Date -Format "dd-MM-yyyy") + "_script.log"

# ------------------------------------------------- Read EventIDs ---------------------------------------------------------

$ids = @()

# Event Log Provider: CodeIntegrity - Operational
$ids += 3004, 3033, 3034, 3076, 3077, 3089, 3091

# Event Log Provider: AppLocker - MSI and Script
$ids += 8028, 8029, 8036, 8037, 8038, 8039, 8040

$ids += 3001, 3002, 3004, 3010, 3011, 3012, 3023, 3024, 3026, 3032, 3033, 3034, 3036, 3064, 3065, 3074, 3075, 3076, 3077, 3079, 3080, 3081, 3082
$ids += 3084, 3085, 3086, 3089, 3090, 3091, 3092, 3095, 3096, 3097, 3099, 3100, 3101, 3102, 3103, 3104, 3105, 3108, 3110, 3111, 3112, 3114


# ------------------------------------------------- Get start date, 30 days back from now ----------------------------------

$startdate = (Get-Date) - (New-TimeSpan -Day 30)

# ------------------------------------------------- Get events from windows logs -------------------------------------------

Start-Transcript -Path "$($logpath)\$($logname)" -Append -Verbose

$ErrorActionPreference = 'SilentlyContinue'
foreach($event in $ids) {
    $Codeintegrity = Get-WinEvent -FilterHashtable @{ LogName='*'; Id=$event; ProviderName='Microsoft-Windows-CodeIntegrity'; StartTime=$startdate; EndTime=Get-Date } | Select-Object -Unique
    if($Codeintegrity){
        log "Exportet xml file for unique $($event) events."
        $Codeintegrity | Export-Clixml -Path "$($env:programdata)\Microsoft\IntuneManagementExtension\Logs\$($event).xml"
    }
}

foreach($event in $ids) {
    $applocker = Get-WinEvent -FilterHashtable @{ LogName='*'; Id=$event; ProviderName='Microsoft-Windows-AppLocker'; StartTime=$startdate; EndTime=(Get-Date) } | Select-Object -unique
    if($applocker){
        log "Exportet xml file for unique $($event) events."
        $applocker | Export-Clixml -Path "$($env:programdata)\Microsoft\IntuneManagementExtension\Logs\$($event).xml"
    }
}

Stop-Transcript
