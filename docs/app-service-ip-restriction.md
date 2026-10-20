# App Service: Restricting Access by IP Address

## Objective
Create an Azure App Service and make sure it is only accessible from two public IP addresses: mine and a colleague's. Everyone else should be blocked.

## What I built
- A **Web App** in the `TestingforJoel` resource group (Code publish, .NET 8 on Linux, West US 3)
- A new **App Service plan** on the **Basic (B1)** tier
- **Access restrictions** on the main site, set to "Enabled from select virtual networks and IP addresses", with the **unmatched rule action set to Deny**
- Two Allow rules, one per person, each a single address (`/32`)

| Priority | Name | Source | Action |
|---|---|---|---|
| 100 | allow-joel | `<my-public-ip>/32` | Allow |
| 110 | allow-Michael | `<colleague-public-ip>/32` | Allow |
| 2147483647 | Deny all | Any | Deny |

The real addresses are left out because this repo is public.

## How I approached it

**Pricing tier.** I chose Basic B1 over the Free F1 tier. I wasn't sure whether F1 supports access restrictions, and I didn't want to build the app and then find out at the step that matters. B1 costs a small amount per hour, so I plan to delete the app and plan once this is documented.

**Public network access left On.** The restriction comes from the allow list, not from turning public access off. Setting public access to Disabled would only allow private endpoints, which would block both of us.

**Deny as the unmatched action.** The rules only mean something because everything that doesn't match them is denied. Without that, the list would only add allow rules on top of an open site.

**`/32` rather than a wider range.** A `/32` is exactly one address. A `/16` would cover 65,536 addresses, which on a typical ISP means thousands of strangers. The task asked for two specific addresses, so I used the narrowest range that meets it. The trade-off is that if my address changes, I lose access until I update the rule.

**Distinct priorities.** I gave the rules different priorities (100 and 110) so the evaluation order is predictable. I couldn't find documentation saying whether App Service accepts two rules with the same priority, so I avoided finding out.

**Tags.** The Task 1 policy requires an `Environment` tag on resources, so I added `Environment: lab` to the web app and the plan when creating them.

## Testing and troubleshooting

**Finding my public IP.** My first instinct was to look up my IP from the command line in Cloud Shell. That would have returned an Azure address, not mine, and locking the app to it would have locked me out. I got my address from a browser on my own PC instead.

**Rules only apply once saved.** Clicking Add rule only adds the rule to the page. It doesn't take effect until Save is clicked at the top of the Access Restrictions page. I added my colleague's rule, left the page without saving, and found it missing afterwards. I added it again and saved.

**Loading the site isn't proof.** The site loaded for me before I added any rules and still loaded afterwards. That doesn't show the restriction works, because my own address is on the allow list.

**Shared home IP.** I then tested from my phone and the site still loaded. My phone was on my home Wi-Fi, which shares one public IP with my PC. Once I switched Wi-Fi off and used mobile data, the phone got a **403 Forbidden**. That was the real proof.

**A colleague's IP changed.** After the rules were in place, my colleague's public IP address changed and he could no longer load the app. That was the restriction doing its job, because his new address no longer matched his `/32` rule. I deleted his rule and added a new one with the same name and priority but his current address, and the app then loaded for him again.

## Validation summary
- Access restrictions saved, with the two Allow rules and Deny all showing in the list ✓
  `[Screenshot: Access Restrictions page showing both rules and Deny all]`
- Site loads from my PC (allowed address) ✓
- Site returns 403 from my phone on mobile data (address not on the list) ✓
  `[Screenshot: 403 Forbidden page]`
- My colleague's address changed and he was blocked until I replaced his rule with his current address, after which the app loaded for him ✓

## Lessons learned
- IP allow lists identify a **network**, not a person or a device. Everyone behind the same router shares one public IP, so anyone in my house can reach the app, and the same applies to my colleague's network.
- Home IP addresses can change, for example when a router restarts, so an allow list can stop matching its owner without any change in Azure. This happened to my colleague, and the fix was to replace his rule with his current address.
- Testing from an allowed address proves nothing. The test that matters is a request from an address that should be blocked.
- In the portal, a change isn't live until it's saved, and it's easy to leave the page without noticing.
- A narrow `/32` meets the requirement exactly. Wider ranges are convenient but let in people who weren't named in the task.

## What I'd like to do next
- Review the **Advanced tool site** tab, which has its own rules separate from the main site, and decide whether it needs the same restrictions
- Add authentication (for example Microsoft Entra ID) if access ever needs to be limited to specific people rather than networks
- Delete the web app and plan once the documentation is done, to avoid ongoing cost

---
*Personal Azure home lab project. Not a production environment.*
