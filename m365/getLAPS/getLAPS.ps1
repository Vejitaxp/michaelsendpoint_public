# Form Design
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Request LAPS password'
$form.Size = New-Object System.Drawing.Size(600,600)
$form.StartPosition = 'CenterScreen'
$form.BackColor = '#2F2F2F'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(100,70)
$OKButton.Size = New-Object System.Drawing.Size(400,250)
$OKButton.Text = 'Request LAPS'
$OKButton.Font = 'Aptos,36,style=Bold'
$OKButton.BackColor = '#1F1F1F'
$OKButton.ForeColor = '#FFFFFF'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$ExitButton = New-Object System.Windows.Forms.Button
$ExitButton.Location = New-Object System.Drawing.Point(250,450)
$ExitButton.Size = New-Object System.Drawing.Size(100,50)
$ExitButton.Text = 'EXIT'
$ExitButton.Font = 'Aptos,12'
$ExitButton.BackColor = '#1F1F1F'
$ExitButton.ForeColor = '#FFFFFF'
$ExitButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.AcceptButton = $ExitButton
$form.Controls.Add($ExitButton)

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
	$module = Get-Module -Name Az.Accounts, Az.Automation
	if (-not $module)
	{
		Install-Module -Name Az.Accounts -Force -AllowClobber -Scope CurrentUser
		Install-Module -Name Az.Automation -Force -AllowClobber -Scope CurrentUser
	}
    # Import the required modules
	Import-module Az.Accounts
	Import-module Az.Automation

	# Connect to Azure
	connect-azAccount

	# Get the current user's UPN and Entra User ID
	$upn = (Get-AzContext).Account.Id
	$userid = Get-AzAdUser -UserPrincipalName $upn

	# Start the Automation Runbook with the Entra User ID as parameter
	$param = @{
		Name                  = "ru-getLAPS"
		AutomationAccountName = "aa-getLAPS"
		ResourceGroupName     = "rg-getLAPS"
		Parameters            = @{ EntraUserID = $userid.id }
	}
	Start-AzAutomationRunbook @param

	# Disconnect from Azure
	disconnect-azAccount
}
elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel)
{
	$form.Close()
}