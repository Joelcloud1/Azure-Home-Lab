# Azure Home Lab

A personal Azure infrastructure project built to develop hands-on cloud administration and automation skills, in support of studying towards the Microsoft Azure Administrator Associate (AZ-104) certification.

## Overview

This lab environment simulates a small production-style Azure setup, covering compute, storage, networking, identity, scaling, and secure access. It was built and iterated on manually and with AI-assisted tools (Microsoft Copilot, ChatGPT) to accelerate learning and troubleshoot issues along the way.

## What's in this lab

### Compute & Virtualisation
- Deployed and manage Windows and Linux virtual machines
- Implemented **Virtual Machine Scale Sets** to handle simulated traffic spikes and test autoscaling behaviour

### Storage & Disk Management
- Managed and resized virtual machine disks, including partitioning and expanding storage
- Configured **Azure Storage Accounts** for file and data storage
- Copied files into a storage account container with **AzCopy** using a limited-permission SAS token, and separately using my own sign-in (see `azcopy-file-transfer.md`)

### Networking & Secure Access
- Configured virtual networking for the lab environment
- Deployed **Application Gateway** to manage and distribute traffic across virtual machines
- Configured **Azure Bastion** alongside RDP/SSH for secure remote access to VMs, without exposing public IPs
- Built an **App Service** restricted to two specific IP addresses using access restrictions, and tested the block from outside the allowed network (see `app-service-ip-restriction.md`)

### Identity & Access
- Administered **Microsoft Entra ID** for the lab environment
- Configured **Role-Based Access Control (RBAC)**, assigning appropriate roles and scoping permissions
- Applied identity and access concepts consistent with least-privilege principles

### Deployment & Environment Management
- Built and tested changes in a **staging environment** before promoting to production
- Practiced controlled, safe deployment workflows, including managing which environment was live at a given time
- Troubleshot real issues along the way, including a Linux VM web server (Apache) accessibility issue and an Azure Bastion connection issue, both documented in detail in the docs folder

### Monitoring, Backup & Disaster Recovery
- Configured monitoring and **email alerting** for VM availability
- Created an **Azure Site Recovery** vault and configured replication for a virtual machine to support backup and disaster recovery scenarios

### Governance
- Built an **Azure Policy Initiative** enforcing a required `Environment` tag on resources, with a **Deny** effect so untagged resources can't be created
- Tested, troubleshot, and documented the behaviour, including resource-group vs. resource-level scope and a policy propagation delay (see `governance-tag-policy.md`)
- Assigned **DeployIfNotExists** policies to enforce diagnostic logging on all storage accounts (new and existing), with a remediation task to fix pre-existing resources (see `governance-diagnostic-settings.md`)
- Built a **custom DeployIfNotExists policy** to auto-apply a `CanNotDelete` lock to resource groups, covering both existing and future ones, with a PowerShell script for repeatable deployment (see `governance-rg-locks.md`)

### Automation
- Wrote **PowerShell** scripts to automate repetitive administrative tasks
- Used AI-assisted development (Microsoft Copilot and ChatGPT) to troubleshoot scripting and infrastructure issues, explain resource behaviour, and resolve deployment problems faster

## Repository structure

```
azure-home-lab/
├── README.md                          # This file
├── docs/
│   ├── networking.md                  # Networking, Application Gateway & Linux VM web server troubleshooting
│   ├── storage.md                     # Disk & storage account configuration
│   ├── scaling.md                     # VM Scale Sets, staging deployment & Bastion troubleshooting
│   ├── access.md                      # Bastion, RDP/SSH, and Entra ID setup
│   ├── monitoring-backup-identity.md  # Monitoring/alerting, Azure Site Recovery, and RBAC
│   ├── governance-tag-policy.md       # Azure Policy Initiative enforcing required tags
│   ├── governance-diagnostic-settings.md  # Diagnostic logging policy for storage accounts
│   ├── governance-rg-locks.md         # Custom policy auto-locking resource groups against deletion
│   ├── app-service-ip-restriction.md  # App Service locked down to two IP addresses
│   └── azcopy-file-transfer.md        # Copying files to a storage account with AzCopy
└── scripts/
    └── powershell/
        └── (automation scripts used in the lab)
```

## Certifications supporting this work

- Microsoft Certified: Azure Fundamentals (AZ-900)
- Currently studying: Azure Administrator Associate (AZ-104)

## Notes

This is a personal learning project, not a production environment. Configurations reflect a home-lab scale, built to gain genuine, defensible hands-on experience with core Azure administration concepts ahead of AZ-104 certification and IT/cloud support roles.

As this lab was built on a pay-as-you-go Azure subscription, resources were deliberately deprovisioned after each stage of learning to avoid ongoing cost, this documentation reflects work completed and later torn down responsibly, rather than infrastructure still running live today. I'm happy to walk through any part of this in detail, including redeploying elements on request during a technical discussion.
