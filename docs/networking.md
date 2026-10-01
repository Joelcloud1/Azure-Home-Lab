# Networking & Application Gateway

## What this covers
Virtual networking setup for the home lab, and configuration of Application Gateway to manage traffic distribution across virtual machines.

## Virtual Networking
- Configured a virtual network (VNet) to host lab resources
- Set up subnets to segment resources appropriately

## Application Gateway
- Deployed Application Gateway to manage and distribute traffic across virtual machines
- Used it as part of testing how traffic could be handled during simulated spikes, alongside Virtual Machine Scale Sets (see `scaling.md`)

## Secure Access
- Used Azure Bastion for RDP/SSH access rather than exposing VMs with public IPs directly (see `access.md` for detail)

## Linux VM Web Server Troubleshooting
- Deployed a Linux VM in Azure and installed Apache as a web server
- When the site wasn't loading via the VM's public IP in the browser, used AI-assisted troubleshooting to investigate systematically rather than guessing
- Checked the Apache service and used `curl localhost` to test whether the server was actually responding on the machine itself, confirming Apache was running correctly
- Since the server was responding locally but not loading in Chrome, tested the public IP address from a separate device (phone) to isolate whether the issue was server-side or client-side, confirming the site was in fact accessible externally
- This narrowed the issue down to something specific to the original browser/device rather than the server or network configuration itself

## What I'd like to add next
- NSG (Network Security Group) rule documentation and testing
- Private DNS zone configuration for internal name resolution

---
*Notes from a personal Azure home lab project. Not a production environment. Resources were deprovisioned after this stage of learning to avoid ongoing cost on a pay-as-you-go subscription. Troubleshooting on the web server project was AI-assisted (ChatGPT), used to help identify diagnostic commands and interpret results.*
