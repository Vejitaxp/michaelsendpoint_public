# Taskbar and Start Menu Customization

## Creating the Taskbar settings XML

1. To configure the Taskbar with Microsoft Intune or GPO you can now automatically create the XML file you can use the Script I created from the [![Connect on LinkedIn](https://camo.githubusercontent.com/8f98e3b61b0da5c27840993910262b51ccea010d137c4ce6d2f17ce846a703df/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f436f6e6e656374206f6e204c696e6b6564496e2d626c75653f7374796c653d666f722d7468652d6261646765266c6f676f3d6c696e6b6564696e266c6f676f436f6c6f723d7768697465 'LinkedIn: Michael Frank')](https://www.linkedin.com/in/michael-frank-26b86222b)
2. [PSGallery](https://www.powershellgallery.com/packages/New-TaskbarCustomizationXML).

[![Test](https://powershellgallery.com/Content/Images/Branding/packageDefaultIcon.png)]

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
