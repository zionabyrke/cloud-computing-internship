from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from Week 6 Kubernetes App!"

@app.route("/health")
def health():
    return "OK"

@app.route("/ready")
def ready():
    return "Ready"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
