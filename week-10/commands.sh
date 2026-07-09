#!/usr/bin/env bash
# Week 10 - Cloud Monitoring, Cost Analysis & Performance Analytics
# Cloud Computing Internship | Lamina Studios, LLC.
# Intern: Renz Kirby Onia
#
# Runs on local Arch Linux

# Task 1: Deploy monitoring stack
mkdir -p ~/cloud-monitoring && cd ~/cloud-monitoring
docker compose up -d
docker compose ps

# Task 2: Metrics and first dashboard
# Queries run in Prometheus UI at localhost:9090
# rate(node_cpu_seconds_total[1m])
# 100 - (avg by(instance)(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
# node_memory_MemAvailable_bytes
# node_filesystem_avail_bytes

# Task 3: Flask app with Prometheus client
python -m venv venv && source venv/bin/activate
pip install flask prometheus_client
python app.py

# in a second terminal:
curl http://localhost:5000/
curl http://localhost:5000/

docker compose restart prometheus
# verify target at localhost:9090/targets

# Task 4: cAdvisor
# edit docker-compose.yml to add cadvisor service (see docker-compose.yml)
# edit prometheus.yml to add cadvisor scrape job (see prometheus.yml)
sudo systemctl restart docker
docker compose down
docker compose up -d
docker info | grep -i "storage driver"
docker compose logs cadvisor

# Task 5: Cost simulation
source ~/cloud-monitoring/venv/bin/activate
pip install pandas
python cost_analysis.py
# restart app.py to expose cloud_estimated_cost gauge
# verify at localhost:9090: cloud_estimated_cost

# Task 6: Extended app and final dashboard
# app.py extended with /flaky, latency histogram, labeled cost gauge — see app.py
for i in {1..20}; do curl -s http://localhost:5000/flaky; sleep 0.2; done
# verify in Prometheus:
# app_errors_total
# app_request_latency_seconds_bucket
# cloud_estimated_cost{service="..."}
