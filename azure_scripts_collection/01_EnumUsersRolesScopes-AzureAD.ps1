$outputFile = "Users_with_roles"

# Get all users in Azure AD
$users = Get-AzADUser

# Loop through each user and list role assignments
foreach ($user in $users) {
    $assignments = Get-AzRoleAssignment -ObjectId $user.Id
    foreach ($assignment in $assignments) {
        [PSCustomObject]@{
            User  = $user.UserPrincipalName
            Role  = $assignment.RoleDefinitionName
            Scope = $assignment.Scope
        }
    }
}
$all = [PSCustomObject]
#$all

$all | ConvertTo-Json | Out-File $outputFile".json"
