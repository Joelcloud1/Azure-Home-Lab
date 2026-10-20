# Governance: Azure Policy Tag Enforcement

## Objective
Create an Azure Policy Initiative that ensures tags are present on resources, and restricts creation of resources if the required tag isn't defined.

## What I built
- Created an Azure Policy **Initiative** named "Enforced required tags" containing the built-in **"Require a tag on resources"** policy
- Set the required tag name to **Environment**
- The policy's effect is **Deny**, so resource creation is blocked if the Environment tag is missing
- Assigned the Initiative at the **subscription** scope

## How I approached it

**Initial attempt:** I first created a custom policy definition, but noticed its available effects only included **Audit**, which would flag non-compliant resources but not actually block their creation. Since the task required restricting creation, I moved to the built-in "Require a tag on resources" policy instead, which supports **Deny** natively and doesn't need custom JSON editing.

**Initiative vs single policy:** I built this as a full Initiative (a collection of policies bundled as one assignable unit) rather than assigning the single policy directly, since the task called for an Initiative and this structure allows additional tag policies to be added later.

**Naming:** I went back and renamed the Initiative from the default ("Require a tag on resources") to "Enforced required tags", to avoid confusion between the Initiative itself and the underlying policy it contains.

## Testing and troubleshooting

**Propagation delay:** After assignment, Azure noted that policy takes roughly 5-15 minutes to take effect. My first tests didn't show the policy enforcing anything, which turned out to be because I hadn't waited long enough.

**Resource group vs. resource scope:** This built-in policy description states it **"does not apply to resource groups"**, only individual resources. Part of my early confusion came from testing at the wrong level, once I tested by creating an actual resource (a virtual machine) without the tag, the Azure Portal correctly flagged the policy violation directly in the Tags tab of the creation wizard.

**Log Analytics workspace inconsistency:** When creating a Log Analytics workspace with the Environment tag clearly set, I initially received a `RequestDisallowedByPolicy` error naming my Initiative, even though the tag was visible on the review page. To isolate the issue, I tested creating a standard **Resource Group** with the same tag, which succeeded, confirming the policy logic itself was sound. When I retried the Log Analytics workspace afterward, it worked correctly with the tag. I wasn't able to definitively identify the cause of the earlier denial (possibly a timing/propagation issue or stale form state), but isolating the variable by testing a different resource type confirmed the policy configuration itself was not at fault.

## Validation summary
- Creating a resource **without** the Environment tag: denied by policy ✓
  `[Screenshot: VM creation wizard showing the policy violation flagged on the Tags tab]`
- Creating a resource **with** the Environment tag: allowed ✓
  `[Screenshot: Resource Group created successfully with Environment tag applied]`
- Policy correctly does **not** apply to resource groups themselves (by design of this specific built-in policy)
  `[Screenshot: Policy | Compliance page showing "Enforced required tags" as Compliant, 1 out of 1 resource]`

## Lessons learned
- Azure Policy assignments take time to propagate, don't assume a policy is broken immediately after assigning it
- Always check what scope/resource type a policy actually applies to, the same policy can behave differently at resource group vs. resource level
- When something behaves unexpectedly, isolating variables (testing with a different resource type) is a faster way to find out whether the problem is the policy or something else
- Tags are key-value pairs, the policy checks that the tag **name** exists, not what value it holds

## What I'd like to do next
- Optionally extend to resource groups using the separate built-in "Require a tag on resource groups" policy, though this wasn't part of the original task scope
- Add additional required tags (e.g. Owner, CostCentre) to the same Initiative

---
*Personal Azure home lab project. Not a production environment.*
