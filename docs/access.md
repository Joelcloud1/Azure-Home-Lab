# Secure Access & Identity

## What this covers
Azure Bastion configuration for secure remote access, and Entra ID administration for the lab environment.

## Azure Bastion
- Configured Azure Bastion to provide RDP/SSH access to lab VMs without assigning public IPs directly to them
- This was a deliberate choice to practice more secure access patterns rather than the simplest (but less secure) approach of exposing VMs directly

## Microsoft Entra ID
- Administered Entra ID for the lab environment
- Applied access concepts consistent with least-privilege principles, only granting the access actually needed

## What I'd like to add next
- Conditional Access policy configuration within the lab
- MFA enforcement testing

---
*Notes from a personal Azure home lab project. Not a production environment. Resources were deprovisioned after this stage of learning to avoid ongoing cost on a pay-as-you-go subscription.*
