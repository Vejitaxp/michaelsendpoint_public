<#PSScriptInfo
    .VERSION
        1.0.0
    .AUTHOR
        Michael Frank
    .COMPANYNAME
        michaelsendpoint.com
    .Name
        repair_winget
    .SYNOPSIS
        Repairs the Windows Package Manager (winget) installation.
    .creationdate
        06.05.2025
    .lasteditdate
        06.05.2025
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

# ----------------------------------------------- Repairs the winget installation -------------------------------------------

Start-Transcript -Path "$($logpath)\$($logname)" -Append -Verbose

Set-Location "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"
Repair-WingetPackageManage

$app = .\winget.exe list

if($app){
    log "Winget is installed!"
}

Stop-Transcript