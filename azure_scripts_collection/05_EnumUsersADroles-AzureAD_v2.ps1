# Output CSV file path
$outputFile = "AzureADUserDirectoryRoles_v2"

# Initialize an array to store results
$results = @()

# Step 1: Retrieve all users in Azure AD
$users = Get-AzureADUser

# Step 2: Loop through each user to retrieve assigned directory roles
foreach ($user in $users) {
    # Retrieve directory roles for the user
    $userRoles = Get-AzureADUserMembership -ObjectId $user.ObjectId

    # Step 3: For each role, store the user and role information
    foreach ($role in $userRoles) {
        $results += [PSCustomObject]@{
            "UserName" = $user.UserPrincipalName
            "RoleName" = $role.DisplayName
        }
    }
}

# Step 4: Export results to CSV
$results | Export-Csv -Path $outputFile".csv" -NoTypeInformation -Encoding UTF8
$results | ConvertTo-Json | Out-File $outputFile".json"

Write-Output "Results exported to $outputFile"
