<#PSScriptInfo
    .VERSION
        1.1.0
    .AUTHOR
        Michael Frank
    .COMPANYNAME
        michaelsendpoint.com
    .Name
        InstallAVDAgent.ps1
    .SYNOPSIS
        Download and install the Azure Virtual Desktop Agent & Azure Virtual Desktop Agent Bootloader.
    .creationdate
        22.09.2026
    .lasteditdate
        23.09.2026
#>

# Force TLS 1.2 and suppress GUI progress output to maximize download speed in PS 5.1
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'

# ------------------------------------------------- Parameter --------------------------------------------------------------

$Location = "C:\AVDDownload"
$Uri = "https://learn.microsoft.com/en-gb/intune/remote-help/deploy?tabs=windows#configure-remote-help-apps"

# ------------------------------------------------- Get Download Links -----------------------------------------------------

# Request raw HTML with BasicParsing (no IE dependency)
$webResponse = Invoke-WebRequest -Uri $Uri -UseBasicParsing

# Extract MSI links using RegEx directly from raw HTML
$avdMatch  = [regex]::Match($webResponse.Content, 'href="([^"]+)"[^>]*>Azure Virtual Desktop Agent<\/a>')
$bootMatch = [regex]::Match($webResponse.Content, 'href="([^"]+)"[^>]*>Azure Virtual Desktop Agent Bootloader<\/a>')

$AVDUri  = $avdMatch.Groups[1].Value
$BootUri = $bootMatch.Groups[1].Value

# ------------------------------------------------- Download ---------------------------------------------------------------

New-Item -type Directory $Location
Set-Location $Location

$files = @(
    @{
        Uri = $AVDUri
        OutFile = 'AzureVirtualDesktopAgent.msi'
    },
    @{
        Uri = $BootUri
        OutFile = 'AzureVirtualDesktopAgentBootloader.msi'
    }
)

Write-Host "Downloads started..."

foreach ($file in $files) {
    Write-Host "Downloading $($file.OutFile)..."
    Invoke-WebRequest -Uri $file.Uri -OutFile $file.OutFile -UseBasicParsing
}

Write-Host "Downloads finished."

# ------------------------------------------------- Installation ------------------------------------------------------------

$files = Get-ChildItem -Path .\*.msi

Write-Host "Install started..."

Foreach ($file in $files) {
  $DataStamp = get-date -Format yyyyMMddTHHmmss
  $logFile = '{0}-{1}.log' -f $file.fullname,$DataStamp
  $MSIArguments = @(
      "/i"
      ('"{0}"' -f $file.fullname)
      "/qn"
      "/norestart"
      "/L*v"
      $logFile
  )
  Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow 
}

Write-Host "Install finished"

# ------------------------------------------------- Move logs --------------------------------------------------------------

Move-Item -Path .\*.log -Destination "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"

Set-Location "C:\"

Remove-Item $Location -recurse
