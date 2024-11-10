# Ensure Microsoft Graph module is installed
#if (!(Get-Module -ListAvailable -Name Microsoft.Graph)) {
#    Install-Module Microsoft.Graph -Scope CurrentUser -Force
#}

# Import the Graph module
#Import-Module Microsoft.Graph

# Connect to Microsoft Graph with necessary permissions
#Connect-MgGraph -Scopes "Application.Read.All", "OAuth2PermissionGrant.Read.All"

# Initialize an array to store results
$results = @()

# Retrieve all service principals (applications)
$servicePrincipals = Get-MgServicePrincipal -All

# Enumerate OAuth2PermissionGrants (to find third-party applications)
foreach ($sp in $servicePrincipals) {
    # Check if the application is a third-party application
    if ($sp.AppOwnerOrganizationId -ne (Get-MgOrganization).Id) {
        # Get OAuth2PermissionGrants for the third-party application
        $oauthGrants = Get-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $sp.Id -ErrorAction SilentlyContinue
        foreach ($grant in $oauthGrants) {
            $results += [pscustomobject]@{
                ApplicationName     = $sp.DisplayName
                ApplicationId       = $sp.AppId
                ResourceId          = $grant.ResourceId
                ResourceDisplayName = $grant.ResourceDisplayName
                Scope               = $grant.Scope
                ConsentType         = $grant.ConsentType
            }
        }
    }
}

# Output results in table format and export to CSV|JSON
$results | Format-Table -AutoSize
$results | Export-Csv -Path "ThirdPartyApplicationsConsent.csv" -NoTypeInformation -Force
$results | ConvertTo-Json | Out-File "ThirdPartyApplicationsConsent.json"

Write-Host "Third-party applications with consent have been saved to ThirdPartyApplicationsConsent csv and json"
