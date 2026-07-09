import random
import time
from flask import Flask
from prometheus_client import start_http_server, Counter, Histogram, Gauge

app = Flask(__name__)

REQUEST_COUNT = Counter('app_requests_total', 'Total App Requests')
ERROR_COUNT = Counter('app_errors_total', 'Total App Errors')
REQUEST_LATENCY = Histogram('app_request_latency_seconds', 'Request latency in seconds')

CLOUD_COST = Gauge('cloud_estimated_cost', 'Estimated cloud cost by service', ['service'])
CLOUD_COST.labels(service='Compute').set(6.0)
CLOUD_COST.labels(service='Storage').set(10.0)
CLOUD_COST.labels(service='Network').set(0.8)

@app.route("/")
def home():
    REQUEST_COUNT.inc()
    return "Cloud Service Running"

@app.route("/flaky")
def flaky():
    start = time.time()
    REQUEST_COUNT.inc()
    if random.random() < 0.3:
        ERROR_COUNT.inc()
        REQUEST_LATENCY.observe(time.time() - start)
        return "Error", 500
    REQUEST_LATENCY.observe(time.time() - start)
    return "OK"

if __name__ == "__main__":
    start_http_server(8000)
    app.run(host="0.0.0.0", port=5000)
