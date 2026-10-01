# Governance: Resource Group Deletion Locks

## Objective
Ensure resource groups are locked to prevent accidental deletion, deciding which lock type is most appropriate, and covering both existing and future resource groups.

## What I built
- A **custom Azure Policy definition** using the `DeployIfNotExists` effect, since no built-in policy exists for automatically locking resource groups
- The policy targets `Microsoft.Resources/subscriptions/resourceGroups` and checks for a lock at level **CanNotDelete**; if missing, it deploys one automatically
- Assigned the policy at **subscription** scope with a **system-assigned managed identity**, granted the **Owner** role so it has permission to create locks
- Ran a **remediation task** to retroactively apply the lock to resource groups that already existed before the policy was assigned
- Built and ran this via **PowerShell (Az module)** in Azure Cloud Shell, as a reusable script (`enforce-rg-deletion-lock.ps1` + `lock-rg-policy.json`) rather than one-off manual commands

## Lock type decision: CanNotDelete vs ReadOnly
Azure offers two lock levels. I chose **CanNotDelete** over **ReadOnly**:
- **ReadOnly** blocks all modifications to resources in the group, not just deletion. This would break normal day-to-day operations (e.g. updating a VM's tags, scaling a resource) for anything sitting inside a locked resource group.
- **CanNotDelete** only blocks delete operations, while still allowing normal read/write. This matches the actual intent of the task, preventing *accidental deletion* specifically, not freezing the resource group entirely.

## How I approached it

**No built-in policy available.** Unlike the tagging and diagnostic settings tasks, there's no built-in Azure Policy for "lock this resource group." Locking is something Azure treats as a distinct resource type (`Microsoft.Authorization/locks`) rather than a property you can just flip on via a standard built-in, so this required writing a custom policy definition.

**Why DeployIfNotExists instead of Deny.** Deny would only stop *new* non-compliant resource groups from being created, it can't retroactively fix ones that already exist, and it can't "create a missing lock" the way DeployIfNotExists can. Since the task explicitly required covering both existing and future resource groups, DeployIfNotExists plus a remediation task was the only effect that actually satisfies both halves of the requirement.

**Permission required for lock creation.** I initially assumed a narrowly-scoped role like "Management Lock Contributor" existed for this, and gave the managed identity that role name. It doesn't actually exist under that name, the command failed with `Cannot find role definition with name 'Management Lock Contributor'`. Checking Microsoft's own documentation on resource locks confirmed that creating or deleting locks requires `Microsoft.Authorization/locks/*` permissions, and only the built-in **Owner** or **User Access Administrator** roles include that by default, there's no narrower built-in role scoped just to lock management. I granted **Owner** to the policy's managed identity to move forward. This is broader access than feels ideal for a single-purpose automation identity, in a production environment I'd look at building a custom RBAC role scoped tightly to `Microsoft.Authorization/locks/*` instead of using a built-in Owner grant.

## Testing and troubleshooting

**Az module property naming.** The script initially referenced `$assignment.Identity.PrincipalId`, based on how the object is commonly documented. On my Az module version, the identity info actually comes back as flattened top-level properties instead (`IdentityPrincipalId`, `IdentityTenantId`, `IdentityType`), not nested under an `Identity` object. This caused a `Cannot validate argument on parameter 'ObjectId'` error since the nested path returned nothing. Running `Get-AzPolicyAssignment ... | Format-List *` on the actual returned object showed the real property names, which resolved it. Similarly, `Start-AzPolicyRemediation` and `Get-AzPolicyRemediation` don't share the same parameter name for the same concept (`-PolicyAssignmentId` works on one, not the other) — a reminder that Az module cmdlets aren't always internally consistent, and it's worth checking the actual returned object rather than assuming documented property names will match what comes back.

**Cloud Shell file handling.** Working in Azure Cloud Shell rather than a local terminal meant files downloaded to my own machine didn't automatically exist inside the Cloud Shell session. Used the built-in `code <filename>` editor inside Cloud Shell to create both files directly rather than transferring them in. Also worth noting Cloud Shell sessions are ephemeral by default (no persistent storage configured), so files don't survive between sessions unless a storage account is attached.

**Remediation result:** ran cleanly against existing resource groups, 5 successful deployments, 0 failures.
```
DeploymentStatusSuccessfulDeployment : 5
DeploymentStatusFailedDeployment     : 0
ProvisioningState                    : Succeeded
```

## Validation summary
- Existing resource group (`avatar`), locked by remediation ✓
  `Get-AzResourceLock` confirms `level: CanNotDelete`
- New resource group created via the **Portal** (`neida`), not PowerShell, still got auto-locked by the policy ✓ — confirms the policy applies at the platform level regardless of which tool creates the resource group
- Attempted deletion of a locked resource group correctly blocked by Azure itself ✓
  `[Screenshot: Portal notification — "Delete resource group neida failed. The resource group neida is locked and can't be deleted."]`

## Lessons learned
- Not every governance requirement has a built-in policy, sometimes a custom policy definition is the only option, and that's a normal part of the job, not a sign something's being done wrong
- DeployIfNotExists only catches things going forward from assignment; a separate remediation task is required to bring existing resources into compliance
- The permission a managed identity needs isn't always intuitive or narrowly scoped, some Azure operations (like lock management) only map to broad built-in roles, which is a real trade-off worth flagging rather than glossing over
- Don't trust documented property/parameter names blindly, when a script errors on something like `ObjectId is null`, inspecting the actual returned object (`Format-List *`) is faster than guessing
- Testing via a different tool than the one used to build the policy (Portal vs PowerShell) is a good way to prove a policy works at the platform level, not just for one specific workflow

## What I'd like to do next
- Build a scoped custom RBAC role for lock management instead of granting Owner to the policy's managed identity
- Script the teardown process (remove locks → remove policy assignment → remove role assignment → remove policy definition) to match the deploy script, since removing the policy doesn't retroactively remove locks it already created

---
*Personal Azure home lab project. Not a production environment.*
