#!/usr/bin/env bash
# Week 5 - Virtualization & Containerization
# Cloud Computing Internship | Lamina Studios, LLC.
# Intern: Renz Kirby Onia
#
# Runs on local Arch Linux. No VM_IP parameter needed.

# --- Task 1 ---
sudo usermod -aG docker $USER
docker --version
docker run hello-world

# --- Task 2 ---
docker pull python:3.11
docker run -d -p 8080:80 nginx
docker ps
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

# --- Task 3 ---
mkdir ~/my-flask-app && cd ~/my-flask-app
echo "flask" > requirements.txt
# write app.py and Dockerfile — see my-flask-app/ in this repo
docker build -t my-flask-app .

# --- Task 4 ---
docker run -d -p 5000:5000 my-flask-app
docker ps
docker logs <container_id>
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

# --- Task 5 ---
docker run -d -p 5000:5000 -v $(pwd):/app my-flask-app
# edit app.py, then restart to sync
docker restart <container_id>

docker rm -f $(docker ps -aq)

docker network create my-bridge-network
docker run -d --name nginx-container --network my-bridge-network nginx
docker run -d --name flask-container --network my-bridge-network -p 5000:5000 my-flask-app
docker network inspect my-bridge-network

# --- Task 6 ---
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker image prune -a
docker volume prune

docker build -t my-flask-app .
docker login
docker tag my-flask-app zionabyrke/my-flask-app
docker push zionabyrke/my-flask-app
