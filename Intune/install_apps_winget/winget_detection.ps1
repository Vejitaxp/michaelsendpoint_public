# Detection

$ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
    if ($ResolveWingetPath){
           $WingetPath = $ResolveWingetPath[-1].Path
    }
$wingetexe = $ResolveWingetPath 

if (Test-path $wingetexe)
{ Write-host "Found Winget"}