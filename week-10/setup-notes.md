# Week 10 Setup Notes - Cloud Monitoring, Cost Analysis & Performance Analytics

**Intern:** Renz Kirby Onia
**Date Range:** July 6–10, 2026
**Environment:** Local Arch Linux | Docker 29.2.1 | Docker Compose v5.1.0 | Python 3.14.4

---

## Task 1 - Monitoring Stack Deployment

**July 8, 2026**

```bash
mkdir -p ~/cloud-monitoring && cd ~/cloud-monitoring
docker compose up -d
docker compose ps
```

Wrote `docker-compose.yml` for Prometheus, Grafana, and Node Exporter, and `prometheus.yml` with the `node_exporter` scrape job. All three containers came up clean. Prometheus at `localhost:9090`, Grafana at `localhost:3000` (default login `admin`/`admin`).

---

## Task 2 - Metrics Monitoring and First Dashboard

**July 8, 2026**

Ran queries in the Prometheus UI to confirm Node Exporter was scraping the host:

```
rate(node_cpu_seconds_total[1m])
node_memory_MemAvailable_bytes
node_filesystem_avail_bytes
```

Added Prometheus as a Grafana data source at `http://prometheus:9090` - the container hostname, not `localhost`, since Grafana runs inside the Docker network. Data source test passed.

Built the first panel using:

```
100 - (avg by(instance)(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

Showed live CPU usage percentage.

---

## Task 3 - Application with Prometheus Client

**July 8, 2026**

Arch's system Python rejects pip installs without a venv (PEP 668, same as Week 4). Created one first:

```bash
python -m venv venv && source venv/bin/activate
pip install flask prometheus_client
```

Wrote `app.py` with a request `Counter` on port 8000 (Prometheus scrape endpoint) and Flask on port 5000. Ran it, hit the root route a few times, queried `app_requests_total` in Prometheus - returned 3, matching Flask's access logs.

`host.docker.internal` doesn't resolve on native Linux (it's a Docker Desktop thing). Fixed by adding to the Prometheus service in `docker-compose.yml`:

```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

Added the `python_app` scrape target to `prometheus.yml`, restarted Prometheus, and confirmed the target showed `UP` at `localhost:9090/targets`.

---

## Task 4 - Container Monitoring with cAdvisor

**July 8, 2026**

Added cAdvisor to `docker-compose.yml` and `prometheus.yml`, then brought the stack back up. Two failures in sequence:

**First failure - cgroup v2:**

```
Cannot detect current cgroup on cgroup v2
```

Arch uses cgroup v2. Fixed by adding to the cAdvisor service:

```yaml
privileged: true
volumes:
  - /sys/fs/cgroup:/sys/fs/cgroup:ro
```

**Second failure - read-write layer ID:**

```
failed to identify the read-write layer ID
```

This one was the containerd snapshotter. Docker's `containerd-snapshotter` feature doesn't play well with cAdvisor. Fixed by adding to `/etc/docker/daemon.json`:

```json
{
  "features": {
    "containerd-snapshotter": false
  }
}
```

Then:

```bash
sudo systemctl restart docker
docker compose down
docker compose up -d
docker info | grep -i "storage driver"
```

Storage driver confirmed as `overlay2`. cAdvisor logs clean. Queried `container_cpu_usage_seconds_total` and `container_memory_usage_bytes` in Prometheus - both returned per-container data.

---

## Task 5 - Cloud Cost Simulation

**July 8, 2026**

Kubecost and OpenCost were optional in the module and skipped - both require a real cloud account with pay-as-you-go billing. Simulated cost data using Python instead.

```bash
source ~/cloud-monitoring/venv/bin/activate
pip install pandas
python cost_analysis.py
```

`cost_analysis.py` computes `Usage × Cost_per_unit` for Compute, Storage, and Network, prints the breakdown, and logs the total. Total came to `16.8`.

Added a `cloud_estimated_cost` Gauge to `app.py` and set it to the total. Verified in Prometheus, then added the panel to the Grafana dashboard.

---

## Task 6 - Consolidated Grafana Dashboard

**July 8, 2026**

Checked the module's Day 6 panel list against what the current `app.py` actually exposed - missing error rate, response latency, and per-service cost. Extended `app.py`:

- `/flaky` route with ~30% simulated failure rate, incrementing `app_errors_total` on failures
- `app_request_latency_seconds` Histogram wrapping the request handler
- `cloud_estimated_cost` converted to a labeled Gauge with a `service` dimension

```python
ERROR_COUNT = Counter('app_errors_total', 'Total App Errors')
REQUEST_LATENCY = Histogram('app_request_latency_seconds', 'Request latency')
CLOUD_COST = Gauge('cloud_estimated_cost', 'Estimated cost', ['service'])
```

Sent 20 test requests to generate data:

```bash
for i in {1..20}; do curl -s http://localhost:5000/flaky; sleep 0.2; done
```

6 of 20 hit the error path (~30%). Average latency ~121ms. Cost split: Compute=6, Storage=10, Network=0.8.

Built the remaining Grafana panels:

- Infrastructure: CPU utilization, memory usage, disk I/O
- Application: request rate, error rate, response latency
- Containers: container CPU, container memory
- Cost: estimated cost by service

Final dashboard: 10 panels. Cost per request panel was skipped - the app never tracked cost at per-request granularity, so there was nothing to query.
