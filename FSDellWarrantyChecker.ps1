# Last updated 2025-04-04T19:22:00-4
# Author: Luke Nichols
# Git repo URL: https://github.com/jlukenichols/FSDellWarrantyChecker

### Begin Modules ###

### End Modules ###

### Begin Functions ###

function Get-FreshServiceInventoryData {
    ##TODO: Write the function
}

# Function for generating Dell API auth token
Function New-DellAuthToken {
    #Mostly taken from https://www.undocumented-features.com/2020/06/30/powershell-oauth-authentication-two-ways/ but adapted to the Dell API
    Param (
        [string]$clientID,
        [string]$clientSecret
    )

    $requestAccessTokenUri = "https://apigtwb2c.us.dell.com/auth/oauth/v2/token" # Production Endpoint    
    #$body = "client_id=$($clientID)&client_secret=$($clientSecret)&grant_type=client_credentials" # Is this even needed for anything?
    #$contentType = "application/x-www-form-urlencoded" # Is this even needed for anything?
    try {
        #Retrieve token
        $Auth = Invoke-WebRequest "$($requestAccessTokenUri)?client_id=$($clientID)&client_secret=$($clientSecret)&grant_type=client_credentials" -Method Post -UseBasicParsing #https://www.powershellgallery.com/packages/Get-DellWarranty/2.0.0.0

        #Convert result from JSON to PS object
        $Auth = ($Auth | ConvertFrom-Json)

        $script:AuthenticationResult = $Auth.access_token
        $script:TokenExpiration = (get-date).AddSeconds($Auth.expires_in)
    } catch {
        throw
    }
    ##TODO: Rewrite this to not used scoped variables, just output the content in a PSCustomObject which we can pass between functions instead
}

# Function for retrieving Dell warranty data using token from Get-AuthToken
Function Get-DellWarrantyData {
    Param (
        [string]$AuthToken,
        [string]$DellSvcTag
    )

    $warrantyCheckUri = "https://apigtwb2c.us.dell.com/PROD/sbil/eapi/v5/asset-entitlements"
    $headers = @{
        'Authorization' = "Bearer $AuthToken"
    }
    $parameters = @{
        'servicetags' = $DellSvcTag
    }
    
    try {
        $APIResults = Invoke-RestMethod -Uri $warrantyCheckUri -Headers $headers -Body $parameters -Method GET
        $APIResults = ($APIResults | ConvertTo-Json | ConvertFrom-Json)
        return $APIResults
    } catch {
        throw
    }
}

function Export-DellWarrantyData {
    ##TODO: Write the function
}
function Update-FreshServiceInventoryData {
    ##TODO: Write the function
}
# Dot-source functions for writing to log files
. .\functions\Write-Log.ps1

### End Functions ###

### Begin Main Script Body ###

# Dot-source default settings file
. $MyPSScriptRoot\DefaultSettings.ps1
# Dot-source custom settings file if it exists. This will overwrite any duplicate values from DefaultSettings.ps1
if (Test-Path $MyPSScriptRoot\CustomSettings.ps1) {
    . $MyPSScriptRoot\CustomSettings.ps1
    
}

# Clean out old log files
Delete-OldFiles -NumberOfDays $LogRotationIntervalInDays -PathToLogs "$($myPSScriptRoot)\logs"

### End Main Script Body ###

break
exit