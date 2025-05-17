<#PSScriptInfo
    .VERSION
        1.0.0
    .AUTHOR
        Michael Frank
    .COMPANYNAME
        michaelsendpoint.com
    .Name
        detect_app
    .SYNOPSIS
        Detects Notepad++ using registry
    .creationdate
        16.05.2025
    .lasteditdate
        16.05.2025
#>

# ------------------------------------------------- Parameter --------------------------------------------------------------

$appname = "Notepad++"

# ------------------------------------------------- detects an app using registry ------------------------------------------

# This is for 64-bit applications on 64-bit systems
$app = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -like "*$($appname)*" }

if ($app) {
    Write-Host "Found app $($appname)!"
    exit 0
}

# This is for 32-bit applications on 64-bit systems
$app = Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -like "*$($appname)*" }

if ($app) {
    Write-Host "Found app $($appname)!"
    exit 0
}
else {
    Write-Host "Did not find app $($appname)!"
    exit 1
}