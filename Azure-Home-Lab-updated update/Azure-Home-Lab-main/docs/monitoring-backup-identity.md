# Monitoring, Backup & Identity

## What this covers
Monitoring and alerting configuration, backup and disaster recovery setup using Azure Site Recovery, and role-based access control (RBAC) within the lab.

## Monitoring & Alerting
- Configured monitoring and email alerting for VM availability, so I'm notified directly if a virtual machine goes down, rather than discovering it only when checking the portal manually
- This reflects a proactive approach to infrastructure health rather than a purely reactive one

## Backup & Disaster Recovery (Azure Site Recovery)
- Created an Azure Site Recovery vault for a virtual machine
- Configured replication for the VM into the vault, to support backup and disaster recovery scenarios
- This gave me hands-on exposure to how Azure Site Recovery works in practice, beyond just reading about the concept

## Identity & Access (RBAC)
- Configured Role-Based Access Control (RBAC) within the lab, assigning appropriate roles and scoping permissions rather than granting broad or default access
- Applied this alongside least-privilege principles used elsewhere in the lab (see `access.md`)

## What I'd like to add next
- Testing an actual failover using the Azure Site Recovery vault, not just configuring replication
- Custom RBAC role creation for more granular permission scoping

---
*Notes from a personal Azure home lab project. Not a production environment. Resources were deprovisioned after this stage of learning to avoid ongoing cost on a pay-as-you-go subscription.*
