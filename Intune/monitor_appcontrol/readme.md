# Monitoring App Control for Business Audit Logs

This script retrieves events from the Windows Event Logs for a predefined list of Event IDs. 
It supports two providers: Microsoft-Windows-CodeIntegrity and Microsoft-Windows-AppLocker. 
The script filters the events for uniqueness and exports them to both CSV and XML formats. 
The exported files are saved in the Intune Management Extension logs folder.

It belongs to this (Article)[https://michaelsendpoint.com/intune/monitor_appcontrol.html].
