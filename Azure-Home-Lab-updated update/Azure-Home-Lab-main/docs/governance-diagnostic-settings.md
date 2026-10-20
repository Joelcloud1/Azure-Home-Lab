# Governance: Diagnostic Settings Enforcement for Storage Accounts

## Objective
Create an Azure Policy that ensures diagnostic logs are configured for all new and existing storage accounts.

## What I built
- Assigned the built-in policy **"Configure diagnostic settings for Storage Accounts to Log Analytics workspace"** (DeployIfNotExists effect) at subscription scope, pointing to my "Analytical" Log Analytics workspace
- Later extended coverage by separately assigning **"Configure diagnostic settings for Blob Services to Log Analytics workspace"**, since the account-level policy alone does not cover individual storage services (Blob, Queue, Table, File)
- Used **System assigned managed identity** for both assignments, since each is a standalone assignment that doesn't need to share an identity with anything else
- Ran a **remediation task** for each policy to bring existing storage accounts into compliance, since DeployIfNotExists only acts automatically on resources created or updated after assignment

## How I approached it

**Finding the right policy:** I initially searched for the exact policy name from memory and couldn't find it in the portal search. I re-verified the correct name against Microsoft's own documentation before continuing, rather than guessing at alternatives, and the original name turned out to be correct, the issue was with how I was searching, not the policy's existence.

**Testing on a real resource:** I initially tried to verify this policy against an existing Log Analytics workspace, not realising a Log Analytics workspace is a different resource type entirely from a storage account, and this policy only applies to `Microsoft.Storage/storageAccounts`. Once I created an actual storage account ("oya") to test against, this was resolved.

**Understanding "0 out of" compliance:** Early on, the Compliance page showed "100% (0 out of ...)" for this policy, which I initially misread as a good sign. It actually meant zero resources had been evaluated yet, not that everything was compliant. Waiting for a proper evaluation cycle (and checking the resource count, not just the percentage) gave an accurate picture.

**Scope decision:** When assigning, I was prompted with a default scope narrower than the full subscription. Since the task asked for "all new and existing storage accounts," I widened the assignment to subscription level rather than leaving it scoped to a single resource group.

## Validation summary
- New storage account ("oya") created and evaluated by the policy
  `[Screenshot: Policy compliance page showing "oya" as Compliant]`
- Diagnostic settings confirmed **Enabled** at the storage account level
  `[Screenshot: oya | Diagnostic settings page showing "oya" row as Enabled]`
- Blob, Queue, Table, and File sub-services initially showed **Disabled** under the account-level policy alone, confirming this policy's documented scope limitation
  `[Screenshot: Diagnostic settings showing blob/queue/table/file rows as Disabled before Blob policy was added]`
- After separately assigning the Blob-specific policy and running remediation, the "blob" row updated to **Enabled**
  `[Screenshot: Diagnostic settings showing "blob" row as Enabled after remediation]`

## Lessons learned
- A single built-in policy doesn't always cover everything implied by a task, storage diagnostics required separate policies for the account level and each individual service (Blob, Queue, Table, File)
- Compliance percentages can be misleading on their own, "100%" with "0 out of 0" resources evaluated is not the same as genuine compliance, check the resource count too
- DeployIfNotExists policies need a remediation task to retroactively fix existing resources; they only apply automatically going forward from the point of assignment
- Confirm the actual resource type a policy applies to before testing against something similarly named (a Log Analytics workspace is not a storage account)

## What I'd like to do next
- Add the remaining Queue, Table, and File service diagnostic policies to achieve full coverage across all storage sub-services
- Bundle all storage diagnostic policies into a single Initiative, similar to the tag enforcement Initiative, for cleaner management

---
*Personal Azure home lab project. Not a production environment.*
