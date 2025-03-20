<#
.SYNOPSIS
This script connects to the Universal Print service using the Universal Print PowerShell module, retrieves all printers, and shares each printer with a share name matching its display name.

.DESCRIPTION
The script uses the `UniversalPrintManagement` module to connect to the Universal Print service.
It retrieves a list of all printers using the `Get-UPPrinter` cmdlet and iterates through each printer.
For each printer, it creates a new printer share using the `New-UPPrinterShare` cmdlet, setting the share name to match the printer's display name.
The script does not prompt for confirmation before creating each share.

.NOTES
- Requires the Universal Print PowerShell module (`UniversalPrintManagement`) to be installed.
- Use `Install-Module UniversalPrintManagement` to install the module if not already installed.
#>

Import-Module UniversalPrintManagement
connect-uPService

$printers = get-upprinter
foreach($printer in $printers.results){
    new-upprintershare -PrinterId $printer.id -ShareName $printer.displayname -confirm
}