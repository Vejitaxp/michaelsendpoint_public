$app = winget list "agilebits.1password" -e

If (!($app[$app.count-1] -eq "No installed package found matching input criteria.")) {
	Write-Host ("Found it!")
	exit 0
}
else {
	Write-Host ("Didn`t find it!")
	exit 1
}