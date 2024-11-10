# Ensure Microsoft Graph module is installed
#if (!(Get-Module -ListAvailable -Name Microsoft.Graph)) {
#    Install-Module Microsoft.Graph -Scope CurrentUser -Force
#}

# Import the Graph module
#Import-Module Microsoft.Graph

# Connect to Microsoft Graph
#Connect-MgGraph -Scopes "Application.Read.All", "Directory.Read.All"

# Retrieve all service principals
$servicePrincipals = Get-MgServicePrincipal -All

# Initialize an array to store results
$results = @()

# Loop through each service principal
foreach ($sp in $servicePrincipals) {
    # Retrieve the OAuth2 permission grants (consents) for the current service principal
    $consents = Get-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $sp.Id

    # Process each consent for the service principal
    foreach ($consent in $consents) {
        # Create a custom object with relevant information
        $results += [pscustomobject]@{
            ServicePrincipalName = $sp.DisplayName
            ServicePrincipalId   = $sp.Id
            ClientId             = $consent.ClientId
            Scope                = $consent.Scope
            ConsentType          = $consent.ConsentType
            ExpiryDateTime       = $consent.ExpiryDateTime
        }
    }
}

# Output results to the console in table format
$results | Format-Table -AutoSize

# Optionally, save the results to a CSV|JSON file
$results | Export-Csv -Path "ServicePrincipalConsents.csv" -NoTypeInformation -Force
$results | ConvertTo-Json | Out-File "ServicePrincipalConsents.json"

Write-Host "Consent grants for service principals have been saved to ServicePrincipalConsents"
