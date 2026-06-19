# Week 3 — Networking & Security Basics

**Date Range:** June 15 – June 19, 2026
**Status:** ✅ Done
**Key Deliverable:** VPC architecture diagram

---

## Overview

Week 3 covered cloud networking using OpenStack DevStack. The module assumes a local VirtualBox setup, but due to insufficient local RAM, a new Azure VM (Standard_D2s_v3, 8GB RAM, 64GB HDD) was used as the host instead. Two things changed as a result: `HOST_IP` had to be the VM's private IP (`10.1.0.4`) rather than `127.0.0.1`, and Cirros 0.6.3 was used in place of Ubuntu since DevStack 2026.2 doesn't ship Ubuntu images.

---

## Tasks

| # | Task | Date | Status |
|---|------|------|--------|
| 1 | Azure VM Deployment for OpenStack | June 18 | ✅ |
| 2 | DevStack Installation | June 18 | ✅ |
| 3 | VPC and Subnet Configuration | June 18 | ✅ |
| 4 | Security Groups Configuration | June 18 | ✅ |
| 5 | IAM Users and RBAC | June 18 | ✅ |
| 6 | SSH Key Pairs and Secure VM Launch | June 18–19 | ✅ |
| 7 | Lab Exercises | June 19 | ✅ |

---

## VM Config (Azure Host)

| Setting | Value |
|---------|-------|
| Name | OpenStackVM |
| Resource Group | week3-openstack-rg |
| Region | East Asia |
| Image | Ubuntu 24.04 LTS |
| Size | Standard_D2s_v3 (2 vCPU, 8 GB RAM) |
| Disk | Standard HDD 64 GB |
| Public IP | 20.255.184.93 (Static) |
| Private IP | 10.1.0.4 |
| NSG | TCP 22, TCP 80 |

## OpenStack Environment

| | |
|-|-|
| DevStack | 2026.2 |
| HOST_IP | 10.1.0.4 |
| Horizon | http://10.1.0.4/dashboard |
| Image | cirros-0.6.3-x86_64-disk |
| VPC | lab-vpc — 10.0.0.0/24 |
| Router | lab-router → external gateway: public |
| Security Group | ssh-secgrp (TCP 22, ICMP) |
| cloud-vm | 10.0.0.202 fixed, 172.24.4.103 floating |

---

## Files

| File | Description |
|------|-------------|
| `README.md` | This file |
| `commands.sh` | All CLI commands by task |
| `setup-notes.md` | Task documentation |
| `local.conf` | DevStack config used during install |
| `scripts/deploy_vm.sh` | Bash automation script (Exercise 4) |

---

## Issues & Resolutions

| Issue | Resolution |
|-------|------------|
| `HOST_IP=127.0.0.1` crashes Neutron on a cloud VM | Used private IP `10.1.0.4` |
| SSH to floating IP hung despite ping working | Security group was blocking TCP 22 from the Neutron traffic source — not a routing issue |
| DevStack 2026.2 has no Ubuntu images | Used Cirros 0.6.3; SSH user is `cirros` |
| `echo` failed writing long RSA key in Cirros shell | Used `tee ~/.ssh/authorized_keys << 'EOF'` |
| Exercise 4 failed with duplicate `auto-secgrp` | Deleted both instances by UUID, reran the script |

---

## References

- [DevStack Documentation](https://docs.openstack.org/devstack/latest/)
- [Neutron Networking Guide](https://docs.openstack.org/neutron/latest/admin/intro-os-networking.html)
- [Azure Public IP Addresses](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses)
- [Azure VM States and Billing](https://learn.microsoft.com/en-us/azure/virtual-machines/states-billing)
- [OpenSSH Security](https://www.openssh.com/security.html)
