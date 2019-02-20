# Set-ExecutionPolicy Bypass -scope Process -Force
# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted



# BQRO just means BurghQuayRegistrationOffice
$URIBQRODomain = 'https://burghquayregistrationoffice.inis.gov.ie'
$URIBQROSubpathForAppointments = '/Website/AMSREG/AMSRegWeb.nsf/(getAppsNear)?openpage'
# $URIBQROSubpathForAppointments = '/Website/AMSREG/AMSRegWeb.nsf/(getApps4DTAvailability)?openpage'
# $requestHeaders = @{
#     Accept = '*/*'      # Cross-origin resource sharing
#     Origin = 'null'     # Cross-origin resource sharing
#     # Connection = 'keep-alive'
# }

$requestHeaders = @{}
$requestHeaders.Add("User-agent", "script/powershell")
$requestHeaders.Add("Accept", "*/*")
$requestHeaders.Add("Accept-Language", "en-US,en;q=0.5")
$requestHeaders.Add("Accept-Encoding", "gzip, deflate, br")
$requestHeaders.Add("Origin", "null")
# $requestHeaders.Add("Connection", "keep-alive")

# Not sure what '$1' category does when I use (cat = '$1') in params yet...
enum appointmentCategoryType {
    Study
    Work
    Other
}

# enum typeRegisteredWithINIS {
#     isRegistered("Renewal")
#     isNotRegistered "New"
# }


# Invoke-WebRequest -Uri "http://httpbin.org/headers" -Headers $headers
# $URLToPing = ()
# "http://burghquayregistrationoffice.inis.gov.ie/Website/AMSREG/AMSRegWeb.nsf/(getAppsNear)?openpage=&dt=&cat=$1&sbcat=All&typ=Renewal"

# $requestParams = @{
#     openPage = ''
#     dt = ''
#     cat = '$1'
#     sbcat = 'All'
#     typ = 'Renewal'
# }

$requestParams = @{}
$requestParams.Add("openPage","")
$requestParams.Add("dt","")
# $requestParams.Add("cat", (appointmentCategoryType.Work))
$requestParams.Add("cat", "All")
$requestParams.Add("sbcat","All")
$requestParams.Add("typ", "Renewal")

$requestJSONBody = $requestParams | ConvertTo-Json


function NotifyAbruptly() {
    # TODO Script to be added in future
    # ./notifyWithToast.ps1

    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup("Slot found!!",0,"INIS Checker")
}

$response = New-Object -TypeName psobject

function postToBQRO() {
    $PathOfBQROURL = $URIBQRODomain + $URIBQROSubpathForAppointments
    Write-Host "POST to URI " $PathOfBQROURL " with body: " $requestJSONBody
    $response = Invoke-RestMethod -Method Post -Uri $PathOfBQROURL -ContentType 'application/json' -Header $requestHeaders -Body $requestJSONBody -ErrorAction SilentlyContinue
}

function getToBQRO() {
    $SampleBQROURL = "http://burghquayregistrationoffice.inis.gov.ie/Website/AMSREG/AMSRegWeb.nsf/(getAppsNear)?openpage=&dt=&cat=All&sbcat=All&typ=Renewal"
    Write-Host "GET to URI " $SampleBQROURL
    $response = Invoke-RestMethod -Method Get -Uri $SampleBQROURL -ContentType 'application/json' -Header $requestHeaders -ErrorAction SilentlyContinue
}

do{
    Write-Host -NoNewline "Attempt at " (Get-Date).ToString("[HH:mm:ss]") " | "
    
    try {
        getToBQRO
        # postToBQRO
    }   catch   {
        Write-Host $_.Exception.Message -ForegroundColor Yellow
    }
    
    if ($response.empty -match 'TRUE') {
        Write-Host "."
    } elseif (-not ([string]::IsNullOrEmpty($response.slots))) {
        Write-Host "FOUND A SLOT!"
        Write-Host $response.slots
        NotifyAbruptly
    } else {
        Write-Host "Unexpected Behaviour, will try again..."
    }
    Start-Sleep -Seconds 20
} until ($infinity)


# $response = Invoke-RestMethod -Method Post -Uri $FullBQROURL -ContentType 'application/json' -Header $requestHeaders -Body $requestJSONBody 
# $response = Invoke-RestMethod -Method Get -Uri $SampleBQROURL -ContentType 'application/json' -Header $requestHeaders

Write-Host "Result ###############################"
Write-Host $response.empty
Write-Host $response.error
Write-Host $response.slots
Write-Host $response.items
Write-Host $response

# $requestJSON = $requestParams | ConvertTo-Json
# $token = Invoke-RestMethod -Method Get -Uri $token_url -Headers @{ "Authorization" = "username=$username;password=$password"}
# $response = Invoke-RestMethod -Method Post -Uri $post_data_url -Headers @{ "X-Access-Token" = "$token"} -ContentType 'application/json' -Body $requestJSON 
# $response
