<#PSScriptInfo
    .VERSION
        1.0.0
    .AUTHOR
        Michael Frank
    .COMPANYNAME
        michaelsendpoint.com
    .Name
        Install-RSAT.ps1
    .TAGS
        RSAT, Remote Server Administration Tools, Server Manager, Windows, PowerShell, Script, Active Directory Domain Services and Lightweight Directory Services Tools, PowerShell module for Azure Stack HCI, BitLocker Drive Encryption Administration Utilities, Active Directory Certificate Services Tools, DHCP Server Tools, DNS Server Tools, Failover Clustering Tools, File Services Tools, Group Policy Management Tools, IP Address Management (IPAM) Client, Data Centre Bridging LLDP Tools, Network Controller Management Tools, Network Load Balancing Tools, Remote Access Management Tools, Remote Desktop Services Tools, Server Manager, Storage Migration Service Management Tools, Storage Replica Module for Windows PowerShell, System Insights Module for Windows PowerShell, Volume Activation Tools, Windows Server Update Services Tools
    .GUID
        b75e5dbd-df6a-4070-b5e4-e026e3100c21
    .SYNOPSIS
        This PowerShell script installs or uninstalls the Remote Server Administration Tools (RSAT) features.
    .creationdate
        21.05.2025
    .lasteditdate
        21.05.2026
    .DESCRIPTION 
        This PowerShell script installs or uninstalls the Remote Server Administration Tools (RSAT) features on a Windows machine. The script can be executed with the following parameters:
        - To install RSAT features:
          %WINDIR%\SysNative\WindowsPowerShell\v1.0\powershell.exe -NoLogo -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File "install-rsat.ps1" -install
        - To uninstall RSAT features:
          %WINDIR%\SysNative\WindowsPowerShell\v1.0\powershell.exe -NoLogo -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File "install-rsat.ps1" -uninstall
    .Update
        1.0.0 - Initial release
#>

# ------------------------------------------------- Parameter
 
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True, ParameterSetName = 'install')]
    [switch]$install,
    [Parameter(Mandatory = $True, ParameterSetName = 'uninstall')]
    [switch]$uninstall
)

# ------------------------------------------------- Parameter

try {
 
    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'
 
    $logDir = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"
    if (-not (Test-Path -Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }
 
    $logFile = ('{0}\RSATInstall.log' -f $logDir)

    # ------------------------------------------------- Log function
    function Write-Log {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Message,
            [ValidateSet('INFO', 'ERROR')]
            [string]$Level = 'INFO'
        )
 
        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss' -ErrorAction Stop
        $line = ('{0} {1}: {2}{3}' -f $timestamp, $Level, $Message, [Environment]::NewLine)
        [System.IO.File]::AppendAllText($logFile, $line, [System.Text.UTF8Encoding]::new($false))
    }


    # ------------------------------------------------- Capture current RSAT Windows capabilities

    $RSATCaps = Get-WindowsCapability -Online -Name RSAT* -ErrorAction Stop

    # ------------------------------------------------- Uninstallation process

    if ($uninstall) {
        $featuresToUninstall = $RSATCaps | Where-Object { $_.State -eq 'Installed' -and  $_.Name -notlike "Rsat.ServerManager*" -and $_.Name -notlike "Rsat.GroupPolicy*" -and $_.Name -notlike "Rsat.ActiveDirectory*" }
        Write-Log -Message ('RSAT uninstall candidates (without ServerManager/GroupPolicy/ActiveDirectory): {0}' -f (($featuresToUninstall | Select-Object -ExpandProperty Name) -join ', ')) -ErrorAction Stop
        if ($featuresToUninstall) {
            $featuresToUninstall |
            ForEach-Object {
                $capabilityName = $_.Name
                $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
                Write-Log -Message ('RSAT uninstall starts. Target capability: {0}' -f $capabilityName) -ErrorAction Stop
                try {
                    Remove-WindowsCapability -Online -Name $capabilityName -WarningAction SilentlyContinue *> $null
                    $stopwatch.Stop()
                    Write-Log -Message ('RSAT uninstall SUCCESS. Target capability: {0}. DurationSeconds: {1:N2}' -f $capabilityName, $stopwatch.Elapsed.TotalSeconds) -ErrorAction Stop
                }
                catch {
                    $stopwatch.Stop()
                    Write-Log -Message ('RSAT uninstall FAILED. Target capability: {0}. DurationSeconds: {1:N2}. Error: {2}' -f $capabilityName, $stopwatch.Elapsed.TotalSeconds, $_.Exception.Message) -Level ERROR -ErrorAction Stop
                    throw
                }
            }
            Write-Log -Message ('RSAT uninstall completed. Targeted capabilities: {0}' -f $featuresToUninstall.Count) -ErrorAction Stop
        }
 
 
        $featuresToUninstall = (Get-WindowsCapability -Online -Name RSAT* -ErrorAction Stop) | Where-Object { $_.State -eq 'Installed' -and  $_.Name -notlike "Rsat.ServerManager*" }
        Write-Log -Message ('RSAT uninstall candidates (without ServerManager): {0}' -f (($featuresToUninstall | Select-Object -ExpandProperty Name) -join ', ')) -ErrorAction Stop
        if ($featuresToUninstall) {
            $featuresToUninstall |
            ForEach-Object {
                $capabilityName = $_.Name
                $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
                Write-Log -Message ('RSAT uninstall starts. Target capability: {0}' -f $capabilityName) -ErrorAction Stop
                try {
                    Remove-WindowsCapability -Online -Name $capabilityName -WarningAction SilentlyContinue *> $null
                    $stopwatch.Stop()
                    Write-Log -Message ('RSAT uninstall SUCCESS. Target capability: {0}. DurationSeconds: {1:N2}' -f $capabilityName, $stopwatch.Elapsed.TotalSeconds) -ErrorAction Stop
                }
                catch {
                    $stopwatch.Stop()
                    Write-Log -Message ('RSAT uninstall FAILED. Target capability: {0}. DurationSeconds: {1:N2}. Error: {2}' -f $capabilityName, $stopwatch.Elapsed.TotalSeconds, $_.Exception.Message) -Level ERROR -ErrorAction Stop
                    throw
                }
            }
            Write-Log -Message ('RSAT uninstall completed. Targeted capabilities: {0}' -f $featuresToUninstall.Count) -ErrorAction Stop
        }
 
 
        $featuresToUninstall = (Get-WindowsCapability -Online -Name RSAT* -ErrorAction Stop) | Where-Object { $_.State -eq 'Installed' }
        Write-Log -Message ('RSAT uninstall candidates (all installed): {0}' -f (($featuresToUninstall | Select-Object -ExpandProperty Name) -join ', ')) -ErrorAction Stop
        if ($featuresToUninstall) {
            $featuresToUninstall |
            ForEach-Object {
                $capabilityName = $_.Name
                $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
                Write-Log -Message ('RSAT uninstall starts. Target capability: {0}' -f $capabilityName) -ErrorAction Stop
                try {
                    Remove-WindowsCapability -Online -Name $capabilityName -WarningAction SilentlyContinue *> $null
                    $stopwatch.Stop()
                    Write-Log -Message ('RSAT uninstall SUCCESS. Target capability: {0}. DurationSeconds: {1:N2}' -f $capabilityName, $stopwatch.Elapsed.TotalSeconds) -ErrorAction Stop
                }
                catch {
                    $stopwatch.Stop()
                    Write-Log -Message ('RSAT uninstall FAILED. Target capability: {0}. DurationSeconds: {1:N2}. Error: {2}' -f $capabilityName, $stopwatch.Elapsed.TotalSeconds, $_.Exception.Message) -Level ERROR -ErrorAction Stop
                    throw
                }
            }
            Write-Log -Message ('RSAT uninstall completed. Targeted capabilities: {0}' -f $featuresToUninstall.Count) -ErrorAction Stop
        }
 
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Remote Server Administration Tools" -Force -ErrorAction SilentlyContinue
        Exit
    }

    # ------------------------------------------------- Windows Multiple Choice Form

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    [System.Windows.Forms.Application]::EnableVisualStyles()

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'RSAT Installer'
    $form.MinimumSize = New-Object System.Drawing.Size(650,550)
    $form.StartPosition = 'CenterScreen'
    $form.AutoSize = $true
    $form.AutoSizeMode = 'GrowAndShrink'
    $form.MaximizeBox  = $false
    $form.MinimizeBox  = $false
    $form.BackColor  = 'RoyalBlue'
    $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Windows\regedit.exe")

    # ------------------------------------------------- Removes Menubar and makes the Window still movable

    $form.FormBorderStyle = "None"

    $dragPosition = [System.Drawing.Point]::Empty

    $form.Add_MouseDown({
        param($sender, $e)
        if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
            # Fixed: Added the missing $ sign here
            $script:dragPosition = $e.Location
        }
    })

    $form.Add_MouseMove({
        param($sender, $e)
        if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
            $mousePos = [System.Windows.Forms.Cursor]::Position
            $form.Location = New-Object System.Drawing.Point(
                ($mousePos.X - $script:dragPosition.X), 
                ($mousePos.Y - $script:dragPosition.Y)
            )
        }
    })

    # ------------------------------------------------- Install Button

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Point(610,470)
    $OKButton.Size = New-Object System.Drawing.Size(100,45)
    $OKbutton.FlatStyle = "Flat"
    $OKbutton.FlatAppearance.BorderSize = 0
    $OKButton.Text = 'Install'
    $OKButton.BackColor = 'DarkBlue'
    $OKButton.Font = New-Object System.Drawing.Font('Segoe UI', 14, [System.Drawing.FontStyle]::Bold)
    $OKButton.ForeColor = [System.Drawing.Color]::White
    $OKbutton.FlatAppearance.MouseOverBackColor = "#3399FF"
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $OKButton
    $form.Controls.Add($OKButton)

    # ------------------------------------------------- Cancel Button

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Point(450,470)
    $CancelButton.Size = New-Object System.Drawing.Size(100,45)
    $Cancelbutton.FlatStyle = "Flat"
    $Cancelbutton.FlatAppearance.BorderSize = 0
    $CancelButton.Text = 'Cancel'
    $CancelButton.BackColor = 'DarkBlue'
    $CancelButton.Font = New-Object System.Drawing.Font('Segoe UI', 14, [System.Drawing.FontStyle]::Bold)
    $CancelButton.ForeColor = [System.Drawing.Color]::White
    $Cancelbutton.FlatAppearance.MouseOverBackColor = "#3399FF"
    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.AcceptButton = $CancelButton
    $form.Controls.Add($CancelButton)

    # ------------------------------------------------- Titel Icon

    $icon = New-Object System.Windows.Forms.PictureBox
    $icon.Size = '16,16'
    $icon.Location = '10,10'
    $icon.SizeMode = 'Zoom'
    $icon.Image = [Drawing.Image]::FromFile("E:\michaelsendpoint Code\Intune\RSAT-install\Administrative-Tools.png")
    $form.Controls.Add($icon)

    # ------------------------------------------------- Titel label

    $titel = New-Object System.Windows.Forms.Label
    $titel.Location = New-Object System.Drawing.Point(30,10)
    $titel.Size = New-Object System.Drawing.Size(200,20)
    $titel.Text = 'RSAT Installer'
    $titel.Font = New-Object System.Drawing.Font('Verdana', 10)
    $form.Controls.Add($titel)

    # ------------------------------------------------- Text

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(470,50)
    $label.Size = New-Object System.Drawing.Size(270,50)
    $label.Text = 'Remote Server Administration Tools (RSAT) for Windows'
    $label.Font = New-Object System.Drawing.Font('Segoe UI', 14, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($label)

    $label2 = New-Object System.Windows.Forms.Label
    $label2.Location = New-Object System.Drawing.Point(470,120)
    $label2.Size = New-Object System.Drawing.Size(240,100)
    $label2.Text = 'RSAT enables IT administrators to remotely manage roles and features in Windows Server.'
    $label2.Font = New-Object System.Drawing.Font('Segoe UI', 11)
    $form.Controls.Add($label2)

    $label3 = New-Object System.Windows.Forms.Label
    $label3.Location = New-Object System.Drawing.Point(470,220)
    $label3.Size = New-Object System.Drawing.Size(240,50)
    $label3.Text = 'Select RSAT capabilities.'
    $label3.Font = New-Object System.Drawing.Font('Segoe UI', 11)
    $form.Controls.Add($label3)

    # ------------------------------------------------- Checked Listbox

    $listBox = New-Object System.Windows.Forms.checkedListBox
    $listBox.Location = New-Object System.Drawing.Point(30,50)
    $listBox.Size = New-Object System.Drawing.Size(400, 480)
    $listBox.Font = New-Object System.Drawing.Font('Segoe UI', 10)

    foreach ($RSATCap in $RSATCaps){
        [void] $listBox.Items.Add("$($RSATCap.Displayname)")
    }

    $form.Controls.Add($listBox)
    $form.Topmost = $true

    $result = $form.ShowDialog()

    # ------------------------------------------------- Execution

    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $featureList = $listBox.CheckedItems
        $links # Shows the selected items in the console
        Write-Log -Message ('RSAT installation STARTS.') -ErrorAction Stop
 
        if ($install) {
            # Map selected display names back to capability objects
            $featuresToInstall = @()
            foreach ($selectedName in $featureList) {
                $cap = $RSATCaps | Where-Object { $_.DisplayName -eq $selectedName -and $_.State -eq 'NotPresent' }
                if ($cap) {
                    $featuresToInstall += $cap
                }
            }

            Write-Log -Message ('RSAT install candidates: {0}' -f (($featuresToInstall | Select-Object -ExpandProperty Name) -join ', ')) -ErrorAction Stop
            
            if ($featuresToInstall) {
                # ------------------------------------------------- Create Progress Form
                $progressForm = New-Object System.Windows.Forms.Form
                $progressForm.Text = 'RSAT Installation Progress'
                $progressForm.Width = 500
                $progressForm.Height = 250
                $progressForm.StartPosition = 'CenterScreen'
                $progressForm.BackColor = 'RoyalBlue'
                $progressForm.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Windows\regedit.exe")
                $progressForm.ControlBox = $false
                $progressForm.Topmost = $true
                $progressForm.FormBorderStyle = "None"


                $dragPosition = [System.Drawing.Point]::Empty

                $progressForm.Add_MouseDown({
                    param($sender, $e)
                    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
                        # Fixed: Added the missing $ sign here
                        $script:dragPosition = $e.Location
                    }
                })

                $progressForm.Add_MouseMove({
                    param($sender, $e)
                    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
                        $mousePos = [System.Windows.Forms.Cursor]::Position
                        $progressForm.Location = New-Object System.Drawing.Point(
                            ($mousePos.X - $script:dragPosition.X), 
                            ($mousePos.Y - $script:dragPosition.Y)
                        )
                    }
                })


                # Title Label
                $progressTitle = New-Object System.Windows.Forms.Label
                $progressTitle.Location = New-Object System.Drawing.Point(20, 20)
                $progressTitle.Size = New-Object System.Drawing.Size(460, 30)
                $progressTitle.Text = 'Installing Remote Server Administration Tools'
                $progressTitle.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
                $progressTitle.ForeColor = [System.Drawing.Color]::White
                $progressForm.Controls.Add($progressTitle)

                # Progress Bar
                $progressBar = New-Object System.Windows.Forms.ProgressBar
                $progressBar.Location = New-Object System.Drawing.Point(20, 80)
                $progressBar.Size = New-Object System.Drawing.Size(440, 30)
                $progressBar.Maximum = $featuresToInstall.Count
                $progressBar.Value = 0
                $progressForm.Controls.Add($progressBar)

                # Status Label
                $statusLabel = New-Object System.Windows.Forms.Label
                $statusLabel.Location = New-Object System.Drawing.Point(20, 120)
                $statusLabel.Size = New-Object System.Drawing.Size(440, 60)
                $statusLabel.Text = "Initializing..."
                $statusLabel.Font = New-Object System.Drawing.Font('Segoe UI', 10)
                $statusLabel.ForeColor = [System.Drawing.Color]::White
                $statusLabel.AutoSize = $true
                $progressForm.Controls.Add($statusLabel)

                # Finish Button
                $finishButton = New-Object System.Windows.Forms.Button
                $finishButton.Location = New-Object System.Drawing.Point(380, 190)
                $finishButton.Size = New-Object System.Drawing.Size(100, 35)
                $finishButton.Text = 'Finish'
                $finishButton.BackColor = 'DarkBlue'
                $finishButton.ForeColor = [System.Drawing.Color]::White
                $finishButton.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
                $finishButton.FlatStyle = "Flat"
                $finishButton.FlatAppearance.BorderSize = 0
                $finishButton.Enabled = $false
                $finishButton.Add_Click({
                    $progressForm.Close()
                })
                $progressForm.Controls.Add($finishButton)

                $progressForm.Show()
                [System.Windows.Forms.Application]::DoEvents()

                # ------------------------------------------------- Installation loop
                $currentIndex = 0
                $featuresToInstall |
                ForEach-Object {
                    $currentIndex++
                    $capabilityName = $_.Name
                    $displayName = $_.DisplayName
                    
                    # Update progress UI
                    $statusLabel.Text = "Installing: $displayName`r`n[$currentIndex of $($featuresToInstall.Count)]"
                    $progressBar.Value = $currentIndex - 1
                    [System.Windows.Forms.Application]::DoEvents()
                    
                    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
                    Write-Log -Message ('RSAT install starts. Target capability: {0}' -f $capabilityName) -ErrorAction Stop
                    try {
                        Add-WindowsCapability -Online -Name $capabilityName -WarningAction SilentlyContinue *> $null
                        $stopwatch.Stop()
                        Write-Log -Message ('RSAT install SUCCESS. Target capability: {0}. DurationSeconds: {1:N2}' -f $capabilityName, $stopwatch.Elapsed.TotalSeconds) -ErrorAction Stop
                        
                        # Update progress bar to completed
                        $progressBar.Value = $currentIndex
                        [System.Windows.Forms.Application]::DoEvents()
                    }
                    catch {
                        $stopwatch.Stop()
                        Write-Log -Message ('RSAT install FAILED. Target capability: {0}. DurationSeconds: {1:N2}. Error: {2}' -f $capabilityName, $stopwatch.Elapsed.TotalSeconds, $_.Exception.Message) -Level ERROR -ErrorAction Stop
                        $statusLabel.Text = "Installation FAILED: $displayName"
                        [System.Windows.Forms.Application]::DoEvents()
                        $progressForm.Close()
                        throw
                    }
                }

                # Mark completion
                $statusLabel.Text = "Installation Complete!`r`nAll selected RSAT features have been installed successfully."
                $progressBar.Value = $featuresToInstall.Count
                $finishButton.Enabled = $true
                $finishButton.BackColor = 'DarkBlue'
                $finishButton.Focus()
                [System.Windows.Forms.Application]::DoEvents()
            }
    
            Write-Log -Message ('RSAT install completed. Targeted capabilities: {0}' -f $featuresToInstall.Count) -ErrorAction Stop
    
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Remote Server Administration Tools" -Force
            New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Remote Server Administration Tools" -Name "Developer" -Value "Microsoft" -Force
            New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Remote Server Administration Tools" -Name "CurrentVersion" -Value "2.1" -Force
        }
    }

    if ($result -eq [System.Windows.Forms.DialogResult]::Cancel)
    {
        Write-Log -Message ('RSAT installation CANCELD.') -ErrorAction Stop
        Exit
    }
}
catch {
    Write-Log -Message ('"{0}" in "{1}:{2} char:{3}"' -f $_.Exception.Message, $_.InvocationInfo.PSCommandPath, $_.InvocationInfo.ScriptLineNumber, $_.InvocationInfo.OffsetInLine) -Level ERROR -ErrorAction SilentlyContinue
    Exit 1
}