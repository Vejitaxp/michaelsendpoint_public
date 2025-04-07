# Taskbar and Start Menu Customization

## Creating the Taskbar settings XML

1. Configure the taskbar with Microsoft Intune or GPO by automatically creating the XML file using the script I created from the [PSGallery](https://www.powershellgallery.com/packages/New-TaskbarCustomizationXML).

```powershell
Install-Script -Name New-TaskbarCustomizationXML
```
2. As soon as you Start the Script with the command below, a Windows Explorer Dialog opens and you can select a Folder to save your Script.

```powershell
New-TaskbarCustomizationXML
```

3. Next, the script opens a list of your current taskbar shortcuts. Select the shortcuts you want to add to the XML file.

> [!TIP]
> You can add multiple items when holding **Strg** or **Shift**.

4. The script opens a list of all your installed packages (programs). Select the ones you want to add to the XML file.

> [!TIP]
> If you select nothing in either list, the final XML will automatically add the nessecarry lines for a taskbar icon removal.

5. Pressing OK will create a new folder called *TaskBar_XML** in the folder you selected. You can then find your new XML file in this folder.
