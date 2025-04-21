# :computer: Monitoring App Control for Business Audit Logs

## Get-AppControlEvent
This script retrieves events from the Windows Event Logs for a predefined list of Event IDs. 
It supports two providers: Microsoft-Windows-CodeIntegrity and Microsoft-Windows-AppLocker. 
The script filters the events for uniqueness and exports them to both CSV and XML formats. 
The exported files are saved in the Intune Management Extension logs folder.

## New-AppControlAuditPolicy

This script generates a Code Integrity (AppControl) audit policy.
It creates the policy in the Intune Management Extension log folder, converts it into a supplemental policy.


**Learn more about these scripts and how to use them in my Article: [Monitor App Control for Business Audit Logs | Intune](https://michaelsendpoint.com/intune/monitor_appcontrol.html).**
