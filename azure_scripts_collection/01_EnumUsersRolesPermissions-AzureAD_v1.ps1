# Output file path
$outputFile = "UserRolesPermissions"

# Initialize an array to store results
$results = @()

# Step 1: Get all Azure AD users
$users = Get-AzADUser

# Step 2: Loop through each user
foreach ($user in $users) {
    # Step 3: Get all Role Assignments for each user
    $roleAssignments = Get-AzRoleAssignment -ObjectId $user.Id

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
                    "UserName"       = $user.UserPrincipalName
                    "Scope"          = $scope
                    "Role"           = $roleName
                    "AllowedAction"  = $action
                }
            }
        }
    }
}

# Step 6: Export results to CSV|JSON
$results | Export-Csv -Path $outputFile".csv" -NoTypeInformation -Encoding UTF8
$results | ConvertTo-Json | Out-File $outputFile".json"


Write-Output "Results exported to $outputFile as csv and json file"