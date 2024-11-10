# Define output file
$outputFile = "HighPrivilegeUsers"

# Define high-privilege Azure AD Directory Roles
$highPrivilegeADRoles = @(
    "Global Administrator",
    "Privileged Role Administrator",
    "Application Administrator",
    "Cloud Application Administrator"
)

# Define high-privilege Azure Resource Roles
$highPrivilegeAzureRoles = @(
    "Owner",
    "Contributor",
    "User Access Administrator"
)

# Initialize array to store results
$results = @()

# Fetch Azure AD Directory Roles with high privilege
foreach ($roleName in $highPrivilegeADRoles) {
    $role = Get-AzureADDirectoryRole | Where-Object {$_.DisplayName -eq $roleName}
    if ($role) {
        $members = Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId
        foreach ($member in $members) {
            $results += [PSCustomObject]@{
                UserName = $member.UserPrincipalName
		UserName2 = $member.DisplayName
                RoleName = $role.DisplayName
                Scope    = "Azure AD Directory"
            }
        }
    }
}

# Fetch high-privilege Azure Resource Role assignments
foreach ($roleName in $highPrivilegeAzureRoles) {
    $roleDefinition = Get-AzRoleDefinition -Name $roleName
    if ($roleDefinition) {
        $assignments = Get-AzRoleAssignment -RoleDefinitionId $roleDefinition.Id
        foreach ($assignment in $assignments) {
            # Check if the principal type is User
            if ($assignment.PrincipalType -eq "User") {
                $user = Get-AzADUser -ObjectId $assignment.ObjectId
                $results += [PSCustomObject]@{
                    UserName = $user.UserPrincipalName
                    RoleName = $roleDefinition.RoleName
                    Scope    = $assignment.Scope
                }
            }
        }
    }
}

# Export results to CSV|JSON
$results | Export-Csv -Path $outputFile".csv" -NoTypeInformation -Encoding UTF8
$results | ConvertTo-Json | Out-File $outputFile".json"


Write-Output "High-privilege users exported to $outputFile"
