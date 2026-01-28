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
	# Install and/or Import the required modules
	$required = 'Az.Accounts','Az.Automation'
	
	foreach ($name in $required) {
	  if (-not (Get-Module -ListAvailable -Name $name)) {
	    Write-Host "Installing module $name..."
	    Install-Module -Name $name -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
	  }
	  Import-Module $name -ErrorAction Stop
	}

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
