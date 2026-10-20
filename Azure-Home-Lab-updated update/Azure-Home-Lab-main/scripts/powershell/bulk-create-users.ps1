<#
.SYNOPSIS
    Bulk creates user accounts from a CSV file in Microsoft Entra ID / Azure AD.

.DESCRIPTION
    Reads a list of new users from a CSV file and creates each account,
    reducing manual account-creation time during onboarding.
    Built and refined with AI-assisted development (Copilot) to troubleshoot
    syntax and confirm correct cmdlet usage.

.NOTES
    Author: Joel Ephraim
    Requires: AzureAD or Microsoft Graph PowerShell module
    This is a lab/demo script — review and adapt before use in any real environment.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$CsvPath
)

# Expected CSV columns: DisplayName, UserPrincipalName, MailNickname, Department

if (-not (Test-Path $CsvPath)) {
    Write-Error "CSV file not found at path: $CsvPath"
    exit 1
}

$users = Import-Csv -Path $CsvPath

foreach ($user in $users) {
    try {
        $passwordProfile = @{
            Password                      = [System.Web.Security.Membership]::GeneratePassword(12, 2)
            ForceChangePasswordNextSignIn = $true
        }

        New-MgUser -DisplayName $user.DisplayName `
            -UserPrincipalName $user.UserPrincipalName `
            -MailNickname $user.MailNickname `
            -AccountEnabled `
            -PasswordProfile $passwordProfile `
            -Department $user.Department

        Write-Output "Created user: $($user.DisplayName)"
    }
    catch {
        Write-Warning "Failed to create user $($user.DisplayName): $_"
    }
}

Write-Output "Bulk user provisioning complete."
