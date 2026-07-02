# Week 7 - Infrastructure as Code (Terraform)

**Date Range:** June 29 – July 3, 2026
**Status:** ✅ Done
**Key Deliverable:** Terraform-managed Azure VM with VNet and subnets

---

## Overview

Week 7 was Terraform. The module was written entirely for AWS, but AWS credits had already run out from a previous course where an EC2 was left running for a month. Azure was used instead, which turned out to be a lot more work - AWS gives you a default VPC for free, but Azure requires a resource group, VNet, subnet, NSG, NIC, and public IP to all be explicitly defined before a VM can exist. All the same end goals from the module were met, just with more resources in the config files.

The accidental main.tf overwrite in Task 3 was the only real incident. Terraform caught it through a plan error before anything was applied, so nothing was lost in Azure - just had to restore the missing blocks.

---

## Tasks

| # | Task | Date | Status |
|---|------|------|--------|
| 1 | Environment Setup | July 1 | ✅ |
| 2 | First VM Deployment using Terraform | July 1 | ✅ |
| 3 | Variables and Outputs | July 1 | ✅ |
| 4 | Expanding the Virtual Network | July 1 | ✅ |
| 5 | Combining VM and New Subnet | July 1 | ✅ |
| 6 | Lifecycle Testing and Teardown | July 1 | ✅ |

---

## Environment

| | |
|-|-|
| Machine | Local Arch Linux |
| Terraform | v1.15.1 |
| Azure CLI | via pipx |
| Cloud | Azure (Azure for Students) |
| Project dir | `~/terraform-week7` |
| SSH key | `~/.ssh/week7_key` |

---

## Files

| File | Description |
|------|-------------|
| `README.md` | This file |
| `commands.sh` | All commands by task |
| `setup-notes.md` | Task documentation |
| `terraform/providers.tf` | azurerm provider config |
| `terraform/network.tf` | Resource group, VNet, subnets, NSG |
| `terraform/main.tf` | Public IP, NIC, and VM resources |
| `terraform/variables.tf` | VM size, image, and admin username |
| `terraform/outputs.tf` | VM ID and public IP outputs |

---

## AWS → Azure Translation

The module used AWS resources. Every equivalent was manually mapped to `azurerm`:

| Module (AWS) | This week (Azure) |
|---|---|
| `aws_vpc` | `azurerm_virtual_network` |
| `aws_subnet` | `azurerm_subnet` |
| `aws_security_group` | `azurerm_network_security_group` |
| `aws_instance` (EC2) | `azurerm_linux_virtual_machine` |
| `aws_key_pair` | SSH public key in `admin_ssh_key` block |
| `aws sts get-caller-identity` | `az account show` |
| `aws ec2 describe-instances` | `az vm show` / `terraform output` |

Azure also requires a `azurerm_resource_group`, `azurerm_public_ip`, and `azurerm_network_interface` which have no direct AWS equivalent since AWS handles those implicitly.

---

## Issues & Resolutions

| Issue | Resolution |
|-------|------------|
| Module written entirely for AWS, no active AWS account | Translated all resources to `azurerm` equivalents using Azure for Students |
| Azure requires resource group, VNet, subnet, NSG, NIC before any VM can exist | Built minimum networking in Task 2 before touching the VM resource |
| Accidentally overwrote `main.tf`, lost 3 resource blocks | Caught by `terraform plan` error before apply - restored missing blocks manually |

---

## References

- [Terraform Registry - azurerm Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Virtual Network Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/)
- [Azure Public IP Addresses](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses)
- [Terraform CLI Documentation](https://developer.hashicorp.com/terraform/cli)
