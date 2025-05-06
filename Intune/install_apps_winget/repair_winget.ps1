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



# ----------------------------------------------- Repairs the winget installation -------------------------------------------

Set-Location "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"
Repair-WingetPackageManage

$app = .\winget.exe list

if($app){
    Write-Output "Winget is installed!"
}