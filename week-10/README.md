# Week 10 - Cloud Monitoring, Cost Analysis & Performance Analytics

**Date Range:** July 6 – July 10, 2026
**Status:** ✅ Done
**Key Deliverable:** Consolidated Grafana dashboard with infrastructure, application, container, and cost panels

---

## Overview

Week 10 was Prometheus and Grafana - deploying the monitoring stack via Docker Compose, wiring a Flask app to expose custom metrics, getting cAdvisor running on a cgroup v2 Arch system (which took a few extra steps), simulating cost data as Prometheus gauges, and building a 10-panel Grafana dashboard covering the full module scope.

The first three tasks were familiar ground from Week 5. The config files like `prometheus.yml`, the cAdvisor cgroup mounts, and the `extra_hosts` fix for `host.docker.internal` on native Linux - are where this week's actual work was. Kubecost and OpenCost were listed as optional in the module and skipped; cost data was simulated through the Prometheus Python client instead.

---

## Tasks

| # | Task | Date | Status |
|---|------|------|--------|
| 1 | Monitoring Stack Deployment | July 8 | ✅ |
| 2 | Metrics Monitoring and First Dashboard | July 8 | ✅ |
| 3 | Application with Prometheus Client | July 8 | ✅ |
| 4 | Container Monitoring with cAdvisor | July 8 | ✅ |
| 5 | Cloud Cost Simulation | July 8 | ✅ |
| 6 | Consolidated Grafana Dashboard | July 8 | ✅ |

---

## Environment

| | |
|-|-|
| Machine | Local Arch Linux |
| Docker | 29.2.1 |
| Docker Compose | v5.1.0 |
| Python | 3.14.4 (venv) |
| cAdvisor | v0.49.1 |
| Grafana panels | 10 |

---

## Files

| File | Description |
|------|-------------|
| `README.md` | This file |
| `commands.sh` | All commands by task |
| `setup-notes.md` | Task documentation |
| `cloud-monitoring/docker-compose.yml` | Full stack with Prometheus, Grafana, Node Exporter, cAdvisor |
| `cloud-monitoring/prometheus.yml` | Scrape configs for all four targets |
| `cloud-monitoring/app.py` | Flask app with request counter, error counter, latency histogram, cost gauge |
| `cloud-monitoring/cost_analysis.py` | Cost simulation script |

---

## Issues & Resolutions

| Issue | Resolution |
|-------|------------|
| `host.docker.internal` unresolved on native Linux | Added `extra_hosts: host.docker.internal:host-gateway` to the Prometheus service |
| cAdvisor: `Cannot detect current cgroup on cgroup v2` | Added `privileged: true` and mounted `/sys/fs/cgroup:/sys/fs/cgroup:ro` |
| cAdvisor: `failed to identify the read-write layer ID` after cgroup fix | Disabled containerd snapshotter in `/etc/docker/daemon.json`, restarted Docker daemon, rebuilt all containers |
| Task 6 had no error rate, latency, or per-service cost data | Extended `app.py` with `/flaky` endpoint, latency `Histogram`, and labeled `Gauge` |
| Cost per request panel not created | App never tracked cost at per-request granularity - omitted |

---

## References

- [Docker Compose Release Notes](https://docs.docker.com/compose/release-notes/)
- [OpenCost Docs](https://opencost.io/docs/)
