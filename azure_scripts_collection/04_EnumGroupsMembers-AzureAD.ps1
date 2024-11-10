# Output file path
$outputFile = "GroupMembers"

# Initialize an array to store results
$results = @()

# Step 1: Get all Azure AD groups
$groups = Get-AzADGroup

# Step 2: Loop through each group and retrieve its members
foreach ($group in $groups) {
    # Get members of the current group
    $members = Get-AzADGroupMember -GroupObjectId $group.Id

    # Step 3: Loop through each member and add to results
    foreach ($member in $members) {
        $results += [PSCustomObject]@{
            "GroupName"  = $group.DisplayName
            "UserName" = $member.UserPrincipalName
            "ServiceName" = $member.DisplayName
        }
	Write-Output $member
    }
}

# Step 4: Export results to CSV|JSON
$results | Export-Csv -Path $outputFile".csv" -NoTypeInformation -Encoding UTF8
$results | ConvertTo-Json | Out-File $outputFile".json"

Write-Output "Group members exported to $outputFile"