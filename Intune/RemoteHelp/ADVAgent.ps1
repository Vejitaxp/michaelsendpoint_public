$Location = "C:\AVDDownload"
$links = (Invoke-WebRequest -Uri "https://learn.microsoft.com/en-gb/intune/remote-help/deploy?tabs=windows#configure-remote-help-apps").Links                                                                  
$AVD = $links | where-object {$_.outerHTML -like "*Azure Virtual Desktop*"} | Get-Unique | Select-Object href                                
$BOOT = $links | where-object {$_.outerHTML -like "*Azure Virtual Desktop Agent Bootloader*"} | Get-Unique | Select-Object href

New-Item -type Directory $Location
Set-Location $Location

$files = @(
    @{
        Uri = $AVD.href
        OutFile = 'AzureVirtualDesktopAgent.msi'
    },
    @{
        Uri = $BOOT.href
        OutFile = 'AzureVirtualDesktopAgentBootloader.msi'
    }
)

$jobs = @()

foreach ($file in $files) {
    $jobs += Start-ThreadJob -Name $file.OutFile -ScriptBlock {
        $params = $Using:file
        Invoke-WebRequest @params
    }
}

Write-Host "Downloads started..."
Wait-Job -Job $jobs

foreach ($job in $jobs) {
    Receive-Job -Job $job
}

Write-Host "Downloads finished"

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

Move-Item -Path .\*.log -Destination "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"

Set-Location "C:\"

Remove-Item $Location -recurse
