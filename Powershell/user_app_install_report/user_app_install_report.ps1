Param(
  [Parameter(Mandatory=$True,Position=1)]
  [string]$folder
)
Import-Module Microsoft.Graph.Beta.DeviceManagement.Actions
Connect-MgGraph -Scopes 'DeviceManagementConfiguration.Read.All, User.Read.All'
$apps = Get-MgDeviceAppManagementMobileApp | select displayname, id
foreach ($app in $apps) {
    $outfile = "$($folder)\$($app.DisplayName)_1.json"
    Get-MgBetaDeviceManagementReportUserInstallStatusReport -Filter "(ApplicationId eq '$($app.id)')" -outfile $outfile  -top 50
    $count = 50
    $iteration = 1
    $Json = Get-Content -Path $outfile | ConvertFrom-Json
    if ($json.totalrowcount -gt $count){
        Do {
            $iteration = $iteration + 1
            Get-MgBetaDeviceManagementReportUserInstallStatusReport -Filter "(ApplicationId eq '$($app.id)')" -outfile "$($folder)\$($app.DisplayName)_$($iteration).json" -skip $count -top 50
            $count = $count + 50
        } until ($count -gt $json.totalrowcount)
    }
}
Remove-Item -path "$($folder)\iAnnotate for Intune" -confirm:$false
Get-ChildItem -Path $folder -Filter "*]*" | remove-item -confirm:$false
$files = Get-ChildItem -Path $folder -Filter *.
foreach($file in $files){
  Remove-Item -path $file.fullname -confirm:$false
}
$files = Get-ChildItem -Path $folder -Filter *.json
foreach($file in $files){
  $jsondata = get-content -path $file.fullname | ConvertFrom-Json
  $data = foreach ($row in $jsonData.Values) {
  $obj = New-Object PSObject
      for ($i = 0; $i -lt $jsonData.Schema.Count; $i++) {
          $obj | Add-Member -MemberType NoteProperty -Name $jsonData.Schema[$i].Column -Value $row[$i]
      }
  $obj
  }
  if(!($data)){
  Remove-Item -path $file.fullname -confirm:$false
  }
}
$csv = @()
$files = Get-ChildItem -Path $folder -Filter *.json
foreach($file in $files){
    $app = $file.name
    $app = $app -replace "_1.json",""
    $jsondata = get-content -path $file.fullname | ConvertFrom-Json
    $data = foreach ($row in $jsonData.Values) {
        $obj = New-Object PSObject
        for ($i = 0; $i -lt $jsonData.Schema.Count; $i++) {
            $obj | Add-Member -MemberType NoteProperty -Name $jsonData.Schema[$i].Column -Value $row[$i]
        }
        $obj | Add-Member -MemberType NoteProperty -Name "App" -Value $app
        $obj
        if (get-mguser -filter "userprincipalname eq '$($obj.UserPrincipalName)' and accountEnabled eq true") {
            $csv += , $obj
        }
  }
}
$csv | Export-Csv -Path "$($folder)\report.csv" -NoTypeInformation -Delimiter ";" -Encoding unicode