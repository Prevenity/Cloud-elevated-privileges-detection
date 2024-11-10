# Ensure Microsoft Graph module is installed
#if (!(Get-Module -ListAvailable -Name Microsoft.Graph)) {
#    Install-Module Microsoft.Graph -Scope CurrentUser -Force
#}

# Import the Graph module
#Import-Module Microsoft.Graph

# Connect to Microsoft Graph with necessary permissions
#Connect-MgGraph -Scopes "Application.Read.All", "AppRoleAssignment.Read.All", "OAuth2PermissionGrant.Read.All"

# Define high-privileged permissions to filter for
$highPrivilegedPermissions = @(
    "Application.ReadWrite.All",
    "AppRoleAssignment.ReadWrite.All",
    "Directory.ReadWrite.All",
    "RoleManagement.ReadWrite.Directory",
    "full_access_as_app"
)

# Initialize an array to store results
$results = @()

# Retrieve all service principals
$servicePrincipals = Get-MgServicePrincipal -All

# Enumerate OAuth2PermissionGrants (delegated permissions)
foreach ($sp in $servicePrincipals) {
    $oauthGrants = Get-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $sp.Id -ErrorAction SilentlyContinue
    foreach ($grant in $oauthGrants) {
        # Check if the permission scope is high-privileged
        $scopes = $grant.Scope -split " "
        foreach ($scope in $scopes) {
            if ($highPrivilegedPermissions -contains $scope) {
                $results += [pscustomobject]@{
                    ApplicationName     = $sp.DisplayName
                    ApplicationId       = $sp.AppId
                    PermissionType      = "Delegated"
                    Scope               = $scope
                    ConsentType         = $grant.ConsentType
                    ResourceId          = $grant.ResourceId
                    ResourceDisplayName = $grant.ResourceDisplayName
                }
            }
        }
    }
}

# Enumerate AppRoleAssignments (application permissions)
foreach ($sp in $servicePrincipals) {
    $appRoleAssignments = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -ErrorAction SilentlyContinue
    foreach ($assignment in $appRoleAssignments) {
        # Retrieve the AppRole details to check the permission name
        $roleDefinition = Get-MgServicePrincipal -ServicePrincipalId $assignment.ResourceId | Select-Object -ExpandProperty AppRoles | Where-Object { $_.Id -eq $assignment.AppRoleId }
        if ($roleDefinition && ($highPrivilegedPermissions -contains $roleDefinition.Value)) {
            $results += [pscustomobject]@{
                ApplicationName     = $sp.DisplayName
                ApplicationId       = $sp.AppId
                PermissionType      = "Application"
                Scope               = $roleDefinition.Value
                ResourceId          = $assignment.ResourceId
                ResourceDisplayName = $assignment.ResourceDisplayName
            }
        }
    }
}

# Output the results in a table format and export to a CSV
$results | Format-Table -AutoSize
$results | Export-Csv -Path "HighPrivilegedPermissionsAssignments.csv" -NoTypeInformation -Force
$results | ConvertTo-Json | Out-File "HighPrivilegedPermissionsAssignments.json"

Write-Host "High privileged permissions assignments have been saved to HighPrivilegedPermissionsAssignments csv and json"
