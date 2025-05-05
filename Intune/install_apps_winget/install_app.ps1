<#PSScriptInfo
    .VERSION
        1.0.0
    .AUTHOR
        Michael Frank
    .COMPANYNAME
        michaelsendpoint.com
    .Name
        install_app
    .SYNOPSIS
        Installs an app using winget
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

# ------------------------------------------------- Installs an app using winget -------------------------------------------

Start-Transcript -Path "$($logpath)\$($logname)" -Append -Verbose

    Param(
        [string]$app
    )
    Set-Location "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"
    $output = .\winget.exe install --id $app --scope "machine" --exact --silent --accept-source-agreements --accept-package-agreements --Verbose --disable-interactivity --force --log "$($logpath)\$($logname)"
    log $output
    return $output

Stop-Transcript