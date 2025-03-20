<#
.SYNOPSIS
This script connects to the Universal Print service using the Universal Print PowerShell module and removes all shared printers.

.DESCRIPTION
The script uses the `UniversalPrintManagement` module to connect to the Universal Print service.
It retrieves a list of all shared printers using the `Get-UPPrinterShare` cmdlet and iterates through each shared printer.
For each shared printer, it removes the share using the `Remove-UPPrinterShare` cmdlet, not prompting for confirmation before removal.

.NOTES
- Requires the Universal Print PowerShell module (`UniversalPrintManagement`) to be installed.
- Use `Install-Module UniversalPrintManagement` to install the module if not already installed.
#>

Import-Module UniversalPrintManagement
connect-uPService

$shares = get-upPrinterShare
foreach($share in $shares.results){remove-upprintershare -ShareID $share.id -confirm}