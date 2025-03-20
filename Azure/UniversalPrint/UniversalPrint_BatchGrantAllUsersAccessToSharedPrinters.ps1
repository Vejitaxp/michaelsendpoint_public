<#
.SYNOPSIS
This script connects to the Universal Print service using the Universal Print PowerShell module and grants all users access to all shared printers.

.DESCRIPTION
The script uses the `UniversalPrintManagement` module to connect to the Universal Print service.
It retrieves a list of all shared printers using the `Get-UPPrinterShare` cmdlet and iterates through each shared printer.
For each shared printer, it grants access to all users using the `Grant-UPAccess` cmdlet.

.NOTES
- Requires the Universal Print PowerShell module (`UniversalPrintManagement`) to be installed.
- Use `Install-Module UniversalPrintManagement` to install the module if not already installed.
#>

Import-Module UniversalPrintManagement
connect-uPService
 
$Shares = Get-UPPrinterShare
foreach($share in $shares.results){Grant-UPAccess -ShareID $share.id -AllUsersAccess}