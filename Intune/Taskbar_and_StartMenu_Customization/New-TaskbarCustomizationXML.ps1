<#PSScriptInfo
    .VERSION
        1.1.0
    .AUTHOR
        Michael Frank
    .COMPANYNAME
        michaelsendpoint.com
    .Name
        New-TaskbarCustomizationXML
    .TAGS
        Taskbar, XML, Customization, Windows, PowerShell, Script, TaskbarLayoutModification.xml, Taskbar Layout Modification
    .GUID
        9a813673-2f44-4b7e-ad7d-30e27f4a3817
    .SYNOPSIS
        Generates a custom Taskbar layout XML file based on user-selected shortcuts and applications for Windows systems.
    .creationdate
        30.03.2025
    .lasteditdate
        30.03.2025
    .DESCRIPTION
        This script automates the creation of a custom Taskbar layout XML file for Windows systems.
        It allows users to select shortcuts and applications to be pinned to the Taskbar.
        The script retrieves existing Taskbar shortcuts and installed applications, presenting them in graphical selection forms.
        Selected items are then used to generate an XML file that defines the Taskbar layout.
        It includes functionality to convert file paths to environment variable-based paths for portability.
        The XML file is structured according to Microsoft's Taskbar layout schema.
        The script ensures user-friendly interaction through Windows Forms and handles file creation and formatting programmatically.
        It is designed for IT administrators or advanced users customizing Windows environments.
#>

# ------------------------------------------------- Windows Folder Selection Form

Add-Type -AssemblyName System.Windows.Forms
$browser = New-Object System.Windows.Forms.FolderBrowserDialog
$null = $browser.ShowDialog()
$Folder = $browser.SelectedPath

if (!($Folder)) {
    exit
}

# ------------------------------------------------- Function to convert paths to environment variables

function Convert-PathToEnvVariable {
    param (
        [string]$Path
    )

    # Define a hashtable of common environment variables and their values
    $envVariables = @{
        '%APPDATA%' = $env:APPDATA
        '%USERPROFILE%' = $env:USERPROFILE
        '%PROGRAMDATA%' = $env:ProgramData
        '%WINDIR%' = $env:windir
    }

    # Replace parts of the path with environment variables
    foreach ($envVar in $envVariables.GetEnumerator()) {
        if ($Path -like "$($envVar.Value)*") {
            $Path = $Path -replace [regex]::Escape($envVar.Value), $envVar.Key
        }
    }

    return $Path
}

# ------------------------------------------------- Get system Parameters

# Create new folders for the XML and JSON files
$xmlfolder = New-Item -Path "$($Folder)\TaskBar_XML" -ItemType Directory -Force

$user_apps = get-startapps #gets all installed apps from the user


# Get the list of shortcuts in the taskbar
$appdatafolder = "$($env:APPDATA)\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
$taskbarshortcuts = Get-ChildItem -Path $appdatafolder -Filter *.lnk

$startmenushortcuts = @()

$startmenushortcuts += get-childitem -path "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs" -recurse -filter "*.lnk"
$startmenushortcuts += get-childitem -path "$($env:ProgramData)\Microsoft\Windows\Start Menu\Programs" -recurse -filter "*.lnk"
$startmenushortcuts += get-childitem -path "$($env:ProgramData)\Microsoft\Windows\Start Menu" -recurse -filter "*.lnk"

# Create an array to store the details of the shortcuts
$taskbarShortcutsDetails = @()
# Create a WScript.Shell COM object
$wshShell = New-Object -ComObject WScript.Shell
# Iterate through each shortcut and resolve the target path and parameters
foreach ($shortcut in $startmenushortcuts) {
    $shortcutPath = $shortcut.FullName
    $shortcutObject = $wshShell.CreateShortcut($shortcutPath) 
    # Create a custom object to store the shortcut details
    $shortcutDetails = [PSCustomObject]@{
        Name         = $shortcut.Name
        ShortcutPath = $shortcutPath
        TargetPath   = $shortcutObject.TargetPath
        Arguments    = $shortcutObject.Arguments
    }
    # Add the details to the array
    $taskbarShortcutsDetails += $shortcutDetails
}


# ------------------------------------------------- Windows Multiple Choice Form for current Taskbar Shortcuts

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Taskbar Shortcuts Selector'
$form.Size = New-Object System.Drawing.Size(400,600)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(280,70)
$OKButton.Size = New-Object System.Drawing.Size(75,30)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(300,50)
$label.Text = 'Please select the shortcuts you want to add to the Taskbar file:'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.Listbox
$listBox.Location = New-Object System.Drawing.Point(10,70)
$listBox.Size = New-Object System.Drawing.Size(260,20)

$listBox.SelectionMode = 'MultiExtended'

foreach ($shortcut in $taskbarshortcuts){
    [void] $listBox.Items.Add("$($shortcut.Name)")
}

$listBox.Height = 500
$form.Controls.Add($listBox)
$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $links = $listBox.SelectedItems
    #$links # Shows the selected items in the console
}

# ------------------------------------------------- Windows Multiple Choice Form for current installed Apps

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Taskbar App Selector'
$form.Size = New-Object System.Drawing.Size(400,600)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(280,70)
$OKButton.Size = New-Object System.Drawing.Size(75,30)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(300,50)
$label.Text = 'Please select the addition apps you want to add to the Taskbar file:'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.Listbox
$listBox.Location = New-Object System.Drawing.Point(10,70)
$listBox.Size = New-Object System.Drawing.Size(260,20)

$listBox.SelectionMode = 'MultiExtended'

foreach ($user_app in $user_apps){
    [void] $listBox.Items.Add("$($user_app.Name)")
}

$listBox.Height = 500
$form.Controls.Add($listBox)
$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $apps = $listBox.SelectedItems
    #$apps # Shows the selected items in the console
}

# ------------------------------------------------- Create the XML File

# Create the XML file
$XmlWriter = New-Object System.XMl.XmlTextWriter("$($xmlfolder)\TaskbarLayoutModification.xml", $Null)
# indent all nodes with tabs
$XmlWriter.Formatting = 'Indented'
$XmlWriter.Indentation = 1
$XmlWriter.IndentChar = "`t"

# Write the XML declaration with version and encoding
$XmlWriter.WriteProcessingInstruction("xml", 'version="1.0" encoding="utf-8"')

# Add the LayoutModificationTemplate element
$XmlWriter.WriteStartElement('LayoutModificationTemplate')
$XmlWriter.WriteAttributeString('xmlns', 'http://schemas.microsoft.com/Start/2014/LayoutModification')
$XmlWriter.WriteAttributeString('xmlns:defaultlayout', 'http://schemas.microsoft.com/Start/2014/FullDefaultLayout')
$XmlWriter.WriteAttributeString('xmlns:start', 'http://schemas.microsoft.com/Start/2014/StartLayout')
$XmlWriter.WriteAttributeString('xmlns:taskbar', 'http://schemas.microsoft.com/Start/2014/TaskbarLayout')
$XmlWriter.WriteAttributeString('Version', '1')

# Add CustomTaskbarLayoutCollection element
$XmlWriter.WriteStartElement('CustomTaskbarLayoutCollection')
$XmlWriter.WriteAttributeString('PinListPlacement', 'Replace')

# Add another defaultlayout:TaskbarLayout element with Region attribute
$XmlWriter.WriteStartElement('defaultlayout:TaskbarLayout')

# Add taskbar:TaskbarPinList
$XmlWriter.WriteStartElement('taskbar:TaskbarPinList')

# Add taskbar:DesktopApp ID elements
foreach($app in $apps){

    $name = $user_apps | where-object{$_.name -eq $app} | select-object appid

    $XmlWriter.WriteStartElement('taskbar:DesktopApp')
    $XmlWriter.WriteAttributeString('DesktopApplicationID', $name.AppID)
    $XmlWriter.WriteEndElement()
}

# Add taskbar:DesktopApp elements
foreach($link in $links){

    $name = $taskbarShortcutsDetails | where-object{$_.name -eq $link}
    $convertedPath = Convert-PathToEnvVariable -Path $name[0].ShortcutPath

    $convertedPath = $convertedPath + $name[0].Arguments

    $XmlWriter.WriteStartElement('taskbar:DesktopApp')
    $XmlWriter.WriteAttributeString('DesktopApplicationLinkPath', $convertedPath)
    $XmlWriter.WriteEndElement()
}

if(!$links -and !$apps){
    $XmlWriter.WriteStartElement('taskbar:DesktopApp')
    $XmlWriter.WriteAttributeString('DesktopApplicationLinkPath', '#leaveempty')
    $XmlWriter.WriteEndElement()
}

# Close taskbar:TaskbarPinList
$XmlWriter.WriteEndElement()

# Close defaultlayout:TaskbarLayout
$XmlWriter.WriteEndElement()

# Close CustomTaskbarLayoutCollection
$XmlWriter.WriteEndElement()

# Close LayoutModificationTemplate
$XmlWriter.WriteEndElement()

# End the XML document
$XmlWriter.Flush()
$XmlWriter.Close()