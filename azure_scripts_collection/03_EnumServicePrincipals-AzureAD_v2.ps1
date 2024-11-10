# Output file path
$outputFile = "ServicePrincipalRolesv2.csv"

# Initialize an array to store results
$results = @()

# Step 1: Get all Service Principals
$servicePrincipals = Get-AzADServicePrincipal

# Step 2: Loop through each Service Principal
foreach ($sp in $servicePrincipals) {
    # Step 3: Get all Role Assignments for each Service Principal
    $roleAssignments = Get-AzRoleAssignment -ObjectId $sp.Id

    # Step 4: Loop through each Role Assignment and retrieve permissions
    foreach ($roleAssignment in $roleAssignments) {
        $roleName = $roleAssignment.RoleDefinitionName
        $scope = $roleAssignment.Scope

        # Step 5: Retrieve the Role Definition for detailed permissions
        $roleDefinition = Get-AzRoleDefinition -Name $roleName

        if ($roleDefinition -ne $null) {
            # For each allowed action, add a new entry to the results array
            foreach ($action in $roleDefinition.Actions) {
                $results += [PSCustomObject]@{
                    "ServicePrincipalName" = $sp.DisplayName
                    "Scope"                = $scope
                    "Role"                 = $roleName
                    "AllowedAction"        = $action
                }
            }
        }
    }
}

# Step 6: Export results to CSV
$results | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

Write-Output "Results exported to $outputFile"
