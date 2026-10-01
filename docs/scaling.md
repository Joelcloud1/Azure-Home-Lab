# Scaling & Deployment

## What this covers
Virtual Machine Scale Sets configuration for handling traffic spikes, and the staging-to-production deployment workflow used in the lab.

## Virtual Machine Scale Sets
- Implemented VM Scale Sets to test how the environment could automatically handle increased load
- Used this alongside Application Gateway (see `networking.md`) to distribute traffic across scaled instances

## Staging & Deployment Workflow
- Built and tested changes in a staging environment before promoting to production
- Practiced managing which environment was "live" at any given time, to support safe, controlled deployments
- When issues came up during staging deployments (for example, a resource not behaving as expected), used Microsoft Copilot to help diagnose the cause and identify a fix, this was genuinely useful for understanding *why* something was misconfigured, not just how to fix it

## Troubleshooting Example: Azure Bastion Connection Issue
While testing Azure Bastion for secure VM access, I hit a problem connecting through the browser. Rather than making unnecessary changes to the VM or its network configuration, I investigated the actual cause and found that the browser's pop-up blocker was preventing the connection window from opening. Once I adjusted the browser setting, the connection worked immediately. This reinforced the value of identifying the real cause of a problem before making infrastructure changes, and choosing the simplest fix that actually addresses the issue.

## What I'd like to add next
- Formal autoscale rules (CPU-based triggers) with documented before/after testing
- A simple CI-style script to automate the staging-to-production promotion step

---
*Notes from a personal Azure home lab project. Not a production environment. Resources were deprovisioned after this stage of learning to avoid ongoing cost on a pay-as-you-go subscription.*
