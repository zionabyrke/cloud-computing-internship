# Week 6 - Kubernetes & Container Orchestration

**Date Range:** June 29 – July 3, 2026
**Status:** ✅ Done
**Key Deliverable:** Working Kubernetes cluster deployment

---

## Overview

Week 6 was Kubernetes - deploying a containerized Flask app, configuring health probes, getting the HPA to actually work, and testing pod self-healing. Kind was used instead of Minikube because the local machine only has 8GB RAM and Minikube spins up a full VM. Kind runs inside Docker, so it's lighter and fit the setup better.

A few things diverged from the module because of this: `kubectl port-forward` replaced `minikube service`, and metrics-server had to be deployed via YAML manifest and patched manually instead of using `minikube addons enable`. The HPA debugging also took longer than expected - the problem turned out to be a missing CPU resource request in `deployment.yaml`, not metrics-server itself.

---

## Tasks

| # | Task | Date | Status |
|---|------|------|--------|
| 1 | Environment Setup | June 30 | ✅ |
| 2 | Containerize the Flask App | June 30 | ✅ |
| 3 | Deploy App to Kubernetes | June 30 | ✅ |
| 4 | Configure Health Checks | June 30 | ✅ |
| 5 | Configure Autoscaling | June 30 | ✅ |
| 6 | Resilience Test and Final Review | June 30 | ✅ |

---

## Environment

| | |
|-|-|
| Machine | Local Arch Linux |
| Docker | 29.2.1 |
| Kind | v0.23.0 |
| kubectl | v1.35.4 |
| Cluster | week6 (Kind) |
| App image | myapp:1.0 |

---

## Files

| File | Description |
|------|-------------|
| `README.md` | This file |
| `commands.sh` | All commands by task |
| `setup-notes.md` | Task documentation |
| `week-app/app.py` | Flask app with `/`, `/health`, `/ready` endpoints |
| `week-app/Dockerfile` | Docker build instructions |
| `week-app/deployment.yaml` | Kubernetes Deployment + Service manifest |

---

## Kind vs Minikube - Key Differences This Week

| Module instruction | What was done instead |
|---|---|
| `minikube start` | `kind create cluster --name week6` |
| `minikube addons enable metrics-server` | YAML manifest + `--kubelet-insecure-tls` patch |
| `minikube service myapp` | `kubectl port-forward service/myapp 5000:5000` |

---

## Issues & Resolutions

| Issue | Resolution |
|-------|------------|
| kubectl v1.35 ahead of cluster server v1.30 | Version skew warning only - no functional impact this week |
| `minikube service myapp` not available in Kind | `kubectl port-forward service/myapp 5000:5000` |
| metrics-server not available as a Kind addon | Deployed via official YAML manifest, patched with `--kubelet-insecure-tls` |
| HPA showed `cpu: <unknown>/50%` | Missing CPU resource requests in `deployment.yaml` - added `requests: cpu: 100m`, `limits: cpu: 200m`, recreated HPA |

---

## References

- [Install kubectl on Linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [Kind Quick Start](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [metrics-server releases](https://github.com/kubernetes-sigs/metrics-server/releases)
- [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Dockerfile Reference](https://docs.docker.com/reference/dockerfile/)
