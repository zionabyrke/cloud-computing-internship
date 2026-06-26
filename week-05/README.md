# Week 5 - Virtualization & Containerization

**Date Range:** June 22 – June 26, 2026
**Status:** ✅ Done
**Key Deliverable:** Dockerfile + container instructions

---

## Overview

Week 5 ran entirely on local Arch Linux instead of a cloud VM - Docker was already installed from prior projects. Covered the full Docker workflow: pulling images, writing a Dockerfile for a Flask app, running and testing containers, volume mounts, custom bridge networking, cleanup, and pushing to Docker Hub. The optional Docker Hub push from the module was completed

The bridge networking section felt the most like Week 3's VPC work - same concept of isolated subnets, just scoped locally instead of in a cloud provider

---

## Tasks

| # | Task | Date | Status |
|---|------|------|--------|
| 1 | Docker Installation and Verification | June 26 | ✅ |
| 2 | Docker Images and Containers | June 26 | ✅ |
| 3 | Dockerfile Basics | June 26 | ✅ |
| 4 | Running and Testing Docker Containers | June 26 | ✅ |
| 5 | Docker Volumes and Networking | June 26 | ✅ |
| 6 | Cleanup, Documentation, and Docker Hub Push | June 26 | ✅ |

---

## Environment

| | |
|-|-|
| Machine | Local Arch Linux |
| Docker | 29.2.1 (build a5c7197) |
| Image base | python:3.11-slim |
| Flask app | my-flask-app → zionabyrke/my-flask-app on Docker Hub |

---

## Files

| File | Description |
|------|-------------|
| `README.md` | This file |
| `commands.sh` | All commands by task |
| `setup-notes.md` | Task documentation |
| `my-flask-app/app.py` | Flask application |
| `my-flask-app/requirements.txt` | Python dependencies |
| `my-flask-app/Dockerfile` | Docker build instructions |

---

## Issues & Resolutions

| Issue | Resolution |
|-------|------------|
| `docker run hello-world` returned permission denied | User wasn't in the docker group - ran `sudo usermod -aG docker $USER` |
| Port 5000 already allocated when running `flask-container` after volume mount step | `docker rm -f $(docker ps -aq)` to force-remove everything including stopped containers |
| `nginx-container` name conflict on recreation | Stopped container still existed - `docker rm -f nginx-container` before recreating |
| `docker tag` failed with "no such image" after prune | `docker image prune -a` removed `my-flask-app` - rebuilt before tagging |

---

## Docker Hub

[zionabyrke/my-flask-app](https://hub.docker.com/r/zionabyrke/my-flask-app)

---

## References

- [Docker Overview](https://docs.docker.com/get-started/overview/)
- [Dockerfile Reference](https://docs.docker.com/reference/dockerfile/)
- [docker run Reference](https://docs.docker.com/reference/cli/docker/container/run/)
- [Use Volumes](https://docs.docker.com/storage/volumes/)
- [Networking Overview](https://docs.docker.com/network/)
- [docker image prune](https://docs.docker.com/reference/cli/docker/image/prune/)
- [Flask Documentation](https://flask.palletsprojects.com/en/3.0.x/)
