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
        15.05.2025
    .lasteditdate
        15.05.2025
#>

# ------------------------------------------------- Parameter handover -----------------------------------------------------

Param(
    [string]$app
)

# ------------------------------------------------- Installs an app using winget -------------------------------------------

$ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
    if ($ResolveWingetPath){
           $WingetPath = $ResolveWingetPath[-1].Path
    }

$Wingetpath = Split-Path -Path $WingetPath -Parent
cd $wingetpath
.\winget.exe install --exact --id $app --silent --accept-package-agreements --accept-source-agreements --scope machine --disable-interactivity