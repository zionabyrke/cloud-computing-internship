# Week 4 - Storage & Database Services

**Date Range:** June 22 – June 26, 2026
**Status:** ✅ Done
**Key Deliverable:** Database connectivity report

---

## Overview

Reused HelloCloudVM from Weeks 1–2. The public IP was gone since it was deleted after Week 2, so a new static IP had to be attached in the Portal before anything else. The week covered UFW, MySQL, a Flask REST API wired to the database, and exposing it publicly. The less obvious thing I ran into: UFW and Azure NSG are two completely separate firewalls. Opening a port in one does nothing for the other.

---

## Tasks

| # | Task | Date | Status |
|---|------|------|--------|
| 1 | VM Access and System Verification | June 23 | ✅ |
| 2 | UFW Firewall Configuration | June 23 | ✅ |
| 3 | MySQL Deployment and Configuration | June 23 | ✅ |
| 4 | Database, User, Schema, and Test Data | June 23 | ✅ |
| 5 | Flask Web Application | June 23 | ✅ |
| 6 | External Access and Background Process | June 23 | ✅ |

---

## VM Config

| | |
|-|-|
| VM | HelloCloudVM (reused from Weeks 1–2) |
| OS | Ubuntu 24.04 LTS |
| Public IP | 20.24.220.135 (new static, previous was deleted) |
| NSG Rules Added | TCP 5000 (Allow-5000, priority 320) |

---

## Files

| File | Description |
|------|-------------|
| `README.md` | This file |
| `commands.sh` | All commands by task |
| `setup-notes.md` | Task documentation |
| `app/app.py` | Flask application |

---

## Issues & Resolutions

| Issue | Resolution |
|-------|------------|
| Port 5000 open in UFW but unreachable externally | UFW and Azure NSG are separate - added TCP 5000 inbound rule in the Portal |
| `mysql_secure_installation` never asked for a root password | Ubuntu 24.04 uses `auth_socket` by default; root access goes through `sudo` |
| `pip3 install` failed on Ubuntu 24.04 | PEP 668 - added `--break-system-packages` flag |

---

## References

- [Azure - Filter Network Traffic with NSG](https://learn.microsoft.com/en-us/azure/virtual-network/tutorial-filter-network-traffic)
- [MySQL 8.0 - Connection Interfaces](https://dev.mysql.com/doc/refman/8.0/en/connection-interfaces.html)
- [PEP 668 - Externally Managed Environments](https://peps.python.org/pep-0668/)
- [Flask Quickstart](https://flask.palletsprojects.com/en/3.0.x/quickstart/)
- [nohup Invocation](https://www.gnu.org/software/coreutils/manual/html_node/nohup-invocation.html)
- [UFW](https://help.ubuntu.com/community/UFW)
