# Week 6 Setup Notes - Kubernetes & Container Orchestration

**Intern:** Renz Kirby Onia
**Date Range:** June 29 – July 3, 2026
**Environment:** Local Arch Linux | Kind v0.23.0 | kubectl v1.35.4 | Docker 29.2.1

---

## Task 1 - Environment Setup

**June 30, 2026**

kubectl came from pacman. Kind was a manual binary download from the official site since it's not in the Arch repos.

```bash
sudo pacman -S kubectl
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

```bash
kind create cluster --name week6
kubectl cluster-info --context kind-week6
kubectl get nodes
```

First cluster start took a few minutes - Kind had to pull the node image from Docker Hub. After that, `week6-control-plane` showed `Ready`.

kubectl v1.35 is ahead of the Kind cluster server at v1.30, which triggered a version skew warning. Nothing this week actually hit that difference.

---

## Task 2 - Containerize the Flask App

**June 30, 2026**

Created `~/week-app/` with `app.py` and `Dockerfile`. The app has three routes: `/` returns a hello message, `/health` returns `OK`, and `/ready` returns `Ready` - the last two are needed for the probes in Task 4.

```bash
docker build -t myapp:1.0 .
docker run -p 5000:5000 myapp:1.0
```

Tested all three endpoints in the browser before moving on. Then loaded the image into Kind - this step is easy to miss. Kind runs in its own isolated network and can't pull from the local Docker daemon, so images have to be explicitly loaded in.

```bash
kind load docker-image myapp:1.0 --name week6
```

---

## Task 3 - Deploy App to Kubernetes

**June 30, 2026**

```bash
kubectl apply -f deployment.yaml
kubectl get pods
kubectl expose deployment myapp --type=NodePort --port=5000
kubectl get services
```

`minikube service myapp` doesn't exist in Kind. The equivalent is `kubectl port-forward`, which binds the service to a local port:

```bash
kubectl port-forward service/myapp 5000:5000
```

App responded at `http://localhost:5000`. NodePort was assigned at 30555 but port-forward is what actually made it reachable.

---

## Task 4 - Configure Health Checks

**June 30, 2026**

Added `livenessProbe` and `readinessProbe` to `deployment.yaml` pointing at `/health` and `/ready` respectively, then reapplied.

```bash
kubectl apply -f deployment.yaml
kubectl get pods
kubectl describe pod <pod-name>
```

The rolling update kept the old pod running until the new one passed its readiness check - zero downtime. `kubectl describe pod` confirmed the probes were registered:

```
Liveness:   http-get http://:5000/health delay=5s timeout=1s period=10s #failure=3
Readiness:  http-get http://:5000/ready  delay=5s timeout=1s period=5s  #failure=3
```

---

## Task 5 - Configure Autoscaling

**June 30, 2026**

Kind has no addon system, so metrics-server needed a manual deploy via the official YAML manifest. It also needs `--kubelet-insecure-tls` patched in since Kind doesn't use signed kubelet certs.

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl top nodes
```

Created the HPA:

```bash
kubectl autoscale deployment myapp --cpu-percent=50 --min=1 --max=5
kubectl get hpa -w
```

HPA showed `cpu: <unknown>/50%` and refused to scale. Spent time checking metrics-server logs before finding the actual problem: `deployment.yaml` had no CPU resource requests defined. Without a request, Kubernetes has no baseline to calculate a percentage against. Fixed by adding:

```yaml
resources:
  requests:
    cpu: 100m
  limits:
    cpu: 200m
```

Reapplied the deployment and recreated the HPA. Then opened a busybox shell to generate load:

```bash
# In a separate terminal
kubectl run -i --tty load-generator --image=busybox /bin/sh
# Inside busybox:
# while true; do wget -q -O- http://myapp:5000; done
```

Watched pods scale up in real-time with `kubectl get hpa -w`. Cleaned up after:

```bash
kubectl delete pod load-generator
```

The `--cpu-percent` flag was deprecated in kubectl v1.35 but still works.

---

## Task 6 - Resilience Test and Final Review

**June 30, 2026**

Watched pods in one terminal, deleted the running pod in another:

```bash
# Terminal 1
kubectl get pods -w

# Terminal 2
kubectl delete pod myapp-6c48f4f896-zckdh
```

Replacement pod (`myapp-6c48f4f896-bt7sw`) went through `Terminating → Pending → ContainerCreating → Running → 1/1 Ready` in 11 seconds. Deleting a pod in Kubernetes isn't really deleting anything - it's telling the Deployment controller to replace it.

Final state: 1/1 Running, 0 restarts, HPA at `2%/50%` with 1 replica.
