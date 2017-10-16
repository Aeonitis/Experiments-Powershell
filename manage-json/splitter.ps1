
$sampleJson = Get-Content 'sample3.json' | Out-String | ConvertFrom-Json

function Format-Json([Parameter(Mandatory, ValueFromPipeline)][String] $json) {
  $indent = 0;
  ($json -Split '\n' |
    % {
      $trimmed = $_.Trim().Replace('\r', '')
      # if ($_ -match '[\}\]]') {
      if ($trimmed -match '[\}\]]$' -or $trimmed -match '[\}\]][^"]?$') {
        # This line contains  ] or }, decrement the indentation level
        $indent--
      }
      #this is just so it keeps working when i somehow messed up the $indent counter... means there is still a bug in the script!!
      if ($indent -lt 0)
      {
        $indent = 0
      }
      $line = (' ' * $indent * 2) + $trimmed.Replace(':  ', ': ')
      if ($trimmed -match '^[\{\[]' -or $trimmed -match '[\{\[]$' ) {
        # This line contains [ or {, increment the indentation level
        $indent++
      }
      $line
  }) -Join "`n"
}

Write-Host "------------------------------------"
Write-Host $sampleJson.psobject
Write-Host "------------------------------------"

try {
  Format-Json($sampleJson)
} catch {
  Write-Host "Issue formatting JSON file"
}

Write-Host Format-Json($sampleJson)
Write-Host "---------Property Names-------------"
Write-Host $sampleJson.psobject.properties.name
Write-Host "---------Property Name[index]-------"
Write-Host $sampleJson.psobject.properties.name[5]
Write-Host "---------Members--------------------"
Write-Host $sampleJson.psobject.Members
# Write-Host "--------For Colors (Sample 1) only---------------"
# Write-Host $sampleJson.colors
# Write-Host "------------------------------------"
# Write-Host $sampleJson.colors[0]
# Write-Host "------------------------------------"
# Write-Host $sampleJson.colors[0].color
# Write-Host "------------------------------------"
# Write-Host $sampleJson.colors[1].color