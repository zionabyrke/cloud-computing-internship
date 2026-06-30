#!/usr/bin/env bash
# Week 6 - Kubernetes & Container Orchestration
# Cloud Computing Internship | Lamina Studios, LLC.
# Intern: Renz Kirby Onia
#
# Runs on local Arch Linux with Kind. No VM_IP parameter needed.

# Task 1: Environment Setup
sudo pacman -S kubectl
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

kind create cluster --name week6
kubectl cluster-info --context kind-week6
kubectl get nodes
docker run hello-world

# Task 2: Containerize the Flask App
docker build -t myapp:1.0 .
docker run -p 5000:5000 myapp:1.0
kind load docker-image myapp:1.0 --name week6

# Task 3: Deploy App to Kubernetes
kubectl apply -f deployment.yaml
kubectl get pods
kubectl expose deployment myapp --type=NodePort --port=5000
kubectl get services
kubectl port-forward service/myapp 5000:5000

# Task 4: Configure Health Checks
kubectl apply -f deployment.yaml
kubectl get pods
kubectl describe pod <pod-name>

# Task 5: Configure Autoscaling
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl top nodes
kubectl autoscale deployment myapp --cpu-percent=50 --min=1 --max=5
kubectl get hpa -w
# In a separate terminal, open busybox shell:
# kubectl run -i --tty load-generator --image=busybox /bin/sh
# while true; do wget -q -O- http://myapp:5000; done
kubectl delete pod load-generator

# Task 6: Resilience Test
kubectl get pods -w
kubectl delete pod <pod-name>
kubectl get hpa
