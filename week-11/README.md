# Week 11 - Multi-Cloud & Hybrid Architectures

**Date Range:** July 6 – July 10, 2026
**Status:** ✅ Done
**Key Deliverable:** Terraform-managed OpenStack + AWS deployment, rclone sync across S3 and Google Drive

---

## Overview

Week 11 combined OpenStack, Terraform, and rclone. The module assumes a fresh VirtualBox setup - instead, the Week 3 `OpenStackVM` on Azure was reused since DevStack 2026.2 was already installed there. That saved the 38-minute install but introduced the `br-ex` bridge issue from last time, which came back after the VM was restarted.

Terraform was run as `azureuser` from the Ubuntu home directory, not as `stack`, Terraform refused to initialize from the stack user's home path. Credentials were hardcoded in the provider block as a result.

The module originally called for LocalStack to simulate AWS. LocalStack now requires an auth token for any meaningful use, so real AWS was used instead. The Google Drive OAuth flow needs a browser, which the VM doesn't have, authorized from the local Arch machine and pasted the token back into the rclone config prompt on the VM.

---

## Tasks

| # | Task | Date | Status |
|---|------|------|--------|
| 1 | Environment Setup on OpenStackVM | July 9 | ✅ |
| 2 | OpenStack Network, VM, and Floating IP | July 9 | ✅ |
| 3 | Deploy OpenStack Instances via Terraform | July 8 | ✅ |
| 4 | Multi-cloud Deployment (OpenStack + AWS S3) | July 9 | ✅ |
| 5 | Cloud Storage Synchronization with rclone | July 9 | ✅ |
| 6 | Architecture Documentation | July 9 | ✅ |
| 7 | Full Resource Cleanup | July 9 | ✅ |

---

## Environment

| | |
|-|-|
| Host VM | OpenStackVM (Azure, reused from Week 3) |
| OpenStack | DevStack 2026.2, HOST_IP 10.1.0.4 |
| Terraform | 1.15.7 |
| OpenStack provider | terraform-provider-openstack 3.4 |
| AWS provider | terraform-provider-aws 5.x |
| AWS CLI | v2 (manual install) |
| rclone | apt install |
| Docker | docker.io |

---

## Files

| File | Description |
|------|-------------|
| `README.md` | This file |
| `commands.sh` | All commands by task |
| `setup-notes.md` | Task documentation |
| `terraform/versions.tf` | Provider version constraints |
| `terraform/provider.tf` | OpenStack and AWS provider config |
| `terraform/main.tf` | Two Cirros instances + S3 bucket |

---

## Issues & Resolutions

| Issue | Resolution |
|-------|------------|
| `br-ex` bridge down and missing IPv4 after VM restart | Brought the link up and reassigned `172.24.4.1/24` manually |
| `terraform init` failed from `stack` user home path | Ran Terraform as `azureuser` from `/home/azureuser` instead |
| LocalStack requires paid auth token | Switched to real AWS (same classmate account from Week 9) |
| Ubuntu 24.04 has no `awscli` in apt | Installed from the AWS official installer |
| Google Drive OAuth requires a browser | Ran `rclone authorize "drive"` on local Arch machine, pasted the token back into the VM config prompt |

---

## References

- [DevStack Documentation](https://docs.openstack.org/devstack/latest/)
- [Terraform OpenStack Provider](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs)
- [rclone Google Drive Config](https://rclone.org/drive/)
- [LocalStack FAQ - Auth Tokens](https://docs.localstack.cloud/aws/getting-started/faq/)
