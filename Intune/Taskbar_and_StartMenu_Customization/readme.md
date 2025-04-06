# Taskbar and Start Menu Customization

## Creating the Taskbar settings XML

1. To configure the Taskbar with Microsoft Intune or GPO you can now automatically create the XML file you can use the Script I created from the [![PSGallery](https://powershellgallery.com/Content/Images/Branding/packageDefaultIcon.png)](https://www.powershellgallery.com/packages/New-TaskbarCustomizationXML).

```powershell
Install-Script -Name New-TaskbarCustomizationXML
```
2. As soon as you Start the Script with the command below, a Windows Explorer Dialog opens and you can select a Folder to save your Script.

```powershell
New-TaskbarCustomizationXML
```

3. Next the Script opens a list of you current Taskbar Shortcuts where you select the Shortcuts you want to add to the XML file.

> [!TIP]
> You can add multiple items when holding <span style="color:crimson">**Strg**</span> or <span style="color:crimson">**Shift**</span>.

4. Then the Script opens a list of all your installed packages (programs), where you can also select the ones you want to add to the XML file.

> [!TIP]
> If you select nothing in either list, the final XML will automatically add the nessecarry lines for a taskbar icon removal.

5. After you press OK a new Folder called <span style="color:crimson">**TaskBar_XML**</span> will appear in the Folder you selected, in which you can then find your newly created XML file. 
