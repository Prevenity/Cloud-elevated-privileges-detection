# Ensure Microsoft Graph module is installed
#if (!(Get-Module -ListAvailable -Name Microsoft.Graph)) {
#    Install-Module Microsoft.Graph -Scope CurrentUser -Force
#}

# Import the Graph module
#Import-Module Microsoft.Graph

# Connect to Microsoft Graph
#Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All"

# Retrieve all users in Azure AD
$users = Get-MgUser -All

# Initialize an array to store results
$results = @()

# Loop through each user
foreach ($user in $users) {
    # Retrieve the OAuth2 permission grants (consents) for the current user
    $consents = Get-MgUserOauth2PermissionGrant -UserId $user.Id

    # Process each consent for the user
    foreach ($consent in $consents) {
        # Create a custom object with relevant information
        $results += [pscustomobject]@{
            UserName          = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            ClientId          = $consent.ClientId
            Scope             = $consent.Scope
            ConsentType       = $consent.ConsentType
            ExpiryDateTime    = $consent.ExpiryDateTime
        }
    }
}

# Output results to the console in table format
$results | Format-Table -AutoSize

# Optionally, save the results to a CSV|JSON file
$results | Export-Csv -Path "UserConsents.csv" -NoTypeInformation -Force
$results | ConvertTo-Json | Out-File "UserConsents.json"

Write-Host "Consent grants for users have been saved to UserConsents csv and json"
