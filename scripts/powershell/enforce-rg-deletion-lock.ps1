<#
.SYNOPSIS
    Deploys a custom Azure Policy that automatically applies a CanNotDelete lock
    to every resource group in the subscription, covering both existing and
    future resource groups.

.DESCRIPTION
    There is no built-in Azure Policy for locking resource groups, so this script
    creates a custom policy definition using the DeployIfNotExists effect, assigns
    it at subscription scope with a system-assigned managed identity, grants that
    identity the "Management Lock Contributor" role (required to create locks),
    and then triggers a remediation task so existing resource groups are brought
    into compliance immediately rather than waiting for their next change event.

    CanNotDelete is used rather than ReadOnly, since ReadOnly would also block
    normal read/write operations on resources inside the group. CanNotDelete only
    blocks delete operations, which matches the intent of preventing accidental
    deletion without interfering with day-to-day work.

.PARAMETER PolicyRuleFilePath
    Path to the JSON file containing the policy rule (the "if"/"then" block).
    Defaults to lock-rg-policy.json in the same folder as this script.

.PARAMETER Location
    Azure region used for the policy assignment's managed identity. Required by
    Azure even though the policy itself is not region-specific.

.PARAMETER SkipRemediation
    If set, creates and assigns the policy but does not trigger a remediation
    task. Useful if you want to review the assignment before remediating
    existing resource groups.

.NOTES
    Author: Joel Ephraim
    This is a lab/demo script — review and adapt before use in any real environment.
    Requires the Az.Resources module and an account with permissions to create
    policy definitions, assignments, and role assignments at subscription scope.
#>

param(
    [string]$PolicyRuleFilePath = "$PSScriptRoot\lock-rg-policy.json",

    [Parameter(Mandatory = $true)]
    [string]$Location,

    [switch]$SkipRemediation
)

$policyDefName   = "deploy-canNotDelete-lock-on-rg"
$assignmentName  = "enforce-rg-canNotDelete-lock"
$lockRoleName    = "Management Lock Contributor"

try {
    if (-not (Test-Path $PolicyRuleFilePath)) {
        throw "Policy rule file not found at '$PolicyRuleFilePath'. Provide -PolicyRuleFilePath or place lock-rg-policy.json alongside this script."
    }

    $context = Get-AzContext
    if (-not $context) {
        throw "No active Azure context. Run Connect-AzAccount first."
    }
    $subId = $context.Subscription.Id
    Write-Host "Using subscription: $($context.Subscription.Name) ($subId)"

    # Step 1: create the custom policy definition
    Write-Host "Creating policy definition '$policyDefName'..."
    $policyRule = Get-Content -Path $PolicyRuleFilePath -Raw

    $policyDef = New-AzPolicyDefinition `
        -Name $policyDefName `
        -DisplayName "Deploy CanNotDelete lock on Resource Groups" `
        -Description "Automatically applies a CanNotDelete lock to any resource group that doesn't already have one, covering both existing and newly created resource groups." `
        -Policy $policyRule `
        -Mode All

    # Step 2: assign the policy with a system-assigned managed identity
    Write-Host "Creating policy assignment '$assignmentName' with a system-assigned identity..."
    $assignment = New-AzPolicyAssignment `
        -Name $assignmentName `
        -PolicyDefinition $policyDef `
        -Scope "/subscriptions/$subId" `
        -Location $Location `
        -IdentityType SystemAssigned

    # Step 3: grant the managed identity permission to create locks
    Write-Host "Granting '$lockRoleName' role to the assignment's managed identity..."
    Write-Host "Waiting for identity propagation before role assignment..."
    Start-Sleep -Seconds 15

    New-AzRoleAssignment `
        -ObjectId $assignment.Identity.PrincipalId `
        -RoleDefinitionName $lockRoleName `
        -Scope "/subscriptions/$subId" `
        -ErrorAction Stop

    # Step 4: remediate existing resource groups
    if (-not $SkipRemediation) {
        Write-Host "Triggering remediation task for existing resource groups..."
        Write-Host "Allowing a short delay for role assignment to propagate before remediating..."
        Start-Sleep -Seconds 30

        $remediation = Start-AzPolicyRemediation `
            -Name "remediate-rg-locks" `
            -PolicyAssignmentId $assignment.PolicyAssignmentId

        Write-Host "Remediation task '$($remediation.Name)' started. Check status with:"
        Write-Host "  Get-AzPolicyRemediation -Name 'remediate-rg-locks' -PolicyAssignmentId '$($assignment.PolicyAssignmentId)'"
    }
    else {
        Write-Host "Skipped remediation (-SkipRemediation set). Existing resource groups will only be locked on their next update, or run remediation manually later."
    }

    Write-Host "Done. Policy assignment: $($assignment.PolicyAssignmentId)"
}
catch {
    Write-Error "Failed while deploying the resource group lock policy: $_"
}
