# Ensure Microsoft Graph module is installed
#if (!(Get-Module -ListAvailable -Name Microsoft.Graph)) {
#    Install-Module Microsoft.Graph -Scope CurrentUser -Force
#}

# Import the Graph module
#Import-Module Microsoft.Graph

# Connect to Microsoft Graph with the required permissions
#Connect-MgGraph -Scopes "Application.Read.All", "Directory.Read.All"

# Specify the object ID of the service principal (application) you want to investigate
$servicePrincipalId = "7fe3b8a0-e4fc-4b6a-aaac-fbcae7381890"

# Retrieve OAuth2PermissionGrants (granted delegated permissions)
$oauthGrants = Get-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $servicePrincipalId

# Retrieve AppRoleAssignments (granted application permissions)
$appRoleAssignments = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $servicePrincipalId

# Initialize an array to store results
$results = @()

# Process each OAuth2PermissionGrant for delegated permissions
foreach ($grant in $oauthGrants) {
    $results += [pscustomobject]@{
        PermissionType       = "Delegated"
        ServicePrincipalName = (Get-MgServicePrincipal -ServicePrincipalId $servicePrincipalId).DisplayName
        ResourceId           = $grant.ResourceId
        ClientId             = $grant.ClientId
        Scope                = $grant.Scope
        ConsentType          = $grant.ConsentType
        ExpiryDateTime       = $grant.ExpiryDateTime
    }
}

# Process each AppRoleAssignment for application permissions
foreach ($appRoleAssignment in $appRoleAssignments) {
    $results += [pscustomobject]@{
        PermissionType       = "Application"
        ServicePrincipalName = (Get-MgServicePrincipal -ServicePrincipalId $servicePrincipalId).DisplayName
        ResourceId           = $appRoleAssignment.ResourceId
        AppRoleId            = $appRoleAssignment.AppRoleId
        RoleName             = $appRoleAssignment.ResourceDisplayName
    }
}

# Output results to the console in table format
$results | Format-Table -AutoSize

# Optionally, save the results to a CSV|JSON file for further analysis
$results | Export-Csv -Path "GrantedPermissions.csv" -NoTypeInformation -Force
$results | ConvertTo-Json | Out-File "GrantedPermissions.json"

Write-Host "Granted permissions for service principal have been saved to GrantedPermissions csv and json"
