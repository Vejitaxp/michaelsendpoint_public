param (
    [Parameter(Mandatory = $true)]
    [string]$DriverFolder
)

# Get all INF files in the specified folder
$infFiles = Get-ChildItem -Path $DriverFolder -Filter *.inf -Recurse

# Get the newest driver by Driver Version from the INF files
$driverInfos = foreach ($inf in $infFiles) {
    $versionLine = Select-String -Path $inf.FullName -Pattern 'DriverVer' | Select-Object -First 1
    if ($versionLine) {
        # Extract the version part (format: DriverVer=mm/dd/yyyy,xx.xx.xx.xx)
        if ($versionLine.Line -match 'DriverVer\s*=\s*[^,]+,([0-9\.]+)') {
            [PSCustomObject]@{
                File    = $inf
                Version = [version]$matches[1]
            }
        }
    }
}
$newestDriver = $driverInfos | Sort-Object Version -Descending | Select-Object -First 1

if ($newestDriver) {
    # Install the driver using pnputil
    pnputil.exe /add-driver "$($newestDriver.File.FullName)" /install | Out-Null

    # Get the driver name from the INF file (assumes the first [Strings] entry for printer name)
    $driverNameLine = Select-String -Path $newestDriver.File.FullName -Pattern 'HP_Mombi_Driver_Name=' | Select-Object -First 1
    if ($driverNameLine -and $driverNameLine.Line -match 'HP_Mombi_Driver_Name\s*=\s*"?(.+?)"?$') {
        $driverName = $matches[1]
        # Install the printer driver
        Add-PrinterDriver -Name $driverName
        Write-Host "Installed printer driver: $driverName"
    } else {
        Write-Warning "Could not determine driver name from INF file."
    }
} else {
    Write-Warning "No suitable driver found."
}