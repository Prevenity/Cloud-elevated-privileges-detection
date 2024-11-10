# Connect to Azure (you'll be prompted to log in)
#Connect-AzAccount

# Get all Service Principals
$servicePrincipals = Get-AzADServicePrincipal

# Initialize array to store output data
$results = @()

foreach ($sp in $servicePrincipals) {
    Write-Output "Processing Service Principal: $($sp.DisplayName)"

    # Retrieve role assignments for the Service Principal
    $roleAssignments = Get-AzRoleAssignment -ObjectId $sp.Id -ErrorAction SilentlyContinue

    foreach ($role in $roleAssignments) {
        # Retrieve details for each role assignment
        $roleDetails = @{
            ServicePrincipalName = $sp.DisplayName
            ServicePrincipalId   = $sp.Id
            RoleName             = $role.RoleDefinitionName
            RoleId               = $role.RoleDefinitionId
            Scope                = $role.Scope
        }
        
        # Add role assignment details to results array
        $results += $roleDetails
    }
}

# Output results to console
$results | ForEach-Object {
    Write-Output "Service Principal: $($_.ServicePrincipalName)"
    Write-Output " - Role: $($_.RoleName) | Role ID: $($_.RoleId) | Scope: $($_.Scope)"
    Write-Output ""
}

# Export results to a JSON file for analysis
$results | ConvertTo-Json | Out-File "ServicePrincipalRoleAssignments.json"

Write-Output "Role assignment collection complete. Results exported to ServicePrincipalRoleAssignments.json"
