# Week 5 Setup Notes - Virtualization & Containerization

**Intern:** Renz Kirby Onia
**Date Range:** June 22–26, 2026
**Environment:** Local Arch Linux | Docker 29.2.1

---

## Task 1 - Docker Installation and Verification

**June 26, 2026**

Docker was already installed from prior projects. Checked the version first to confirm no update was needed, then ran `hello-world` to verify everything still worked.

The first `docker run` without `sudo` threw a permission denied error on the daemon socket. Fixed by adding the current user to the docker group - requires a logout/login to take effect.

```bash
sudo usermod -aG docker $USER
docker --version
docker run hello-world
```

---

## Task 2 - Docker Images and Containers

**June 26, 2026**

Pulled `python:3.11` for use in later tasks, then ran Nginx on port 8080 to verify port mapping and browser access worked before touching the Flask app.

```bash
docker pull python:3.11
docker run -d -p 8080:80 nginx
docker ps
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
```

Nginx welcome page loaded at `http://localhost:8080`. Stopped and removed all containers before moving on.

---

## Task 3 - Dockerfile Basics

**June 26, 2026**

```bash
mkdir ~/my-flask-app && cd ~/my-flask-app
echo "flask" > requirements.txt
```

Wrote `app.py` returning "Hello from Flask in Docker!" and a `Dockerfile` (see `my-flask-app/`). The `--no-cache-dir` flag on the pip install step keeps the image smaller by not writing the pip cache into the layer.

```bash
docker build -t my-flask-app .
```

Build log confirmed: base image pulled, working directory set, Flask installed, source files copied.

---

## Task 4 - Running and Testing Docker Containers

**June 26, 2026**

```bash
docker run -d -p 5000:5000 my-flask-app
docker ps
docker logs <container_id>
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
```

Browser at `http://localhost:5000` returned "Hello from Flask in Docker!". Container logs showed the Flask dev server running on `0.0.0.0:5000` and logging each GET request as HTTP 200 - confirms the app was actually handling requests inside the container, not just the host.

---

## Task 5 - Docker Volumes and Networking

**June 26, 2026**

### Volume mount

Running with `-v $(pwd):/app` binds the local project directory into the container. Edited `app.py` on the host, restarted the container, and the updated message showed in the browser without a rebuild. Worth noting: hot reloading isn't automatic here since the Dockerfile uses `CMD ["python", "app.py"]` without Flask's debug mode - changes only take effect after a manual restart.

```bash
docker run -d -p 5000:5000 -v $(pwd):/app my-flask-app
docker restart <container_id>
```

### Bridge networking

Took a few attempts. Port 5000 was still allocated from the volume mount container, so running `flask-container` failed immediately. Used `docker rm -f $(docker ps -aq)` to clear everything - but that also removed `nginx-container`. When recreating it, Docker complained the name was already in use because the stopped container still existed. Had to remove it explicitly before starting fresh.

```bash
docker rm -f $(docker ps -aq)
docker rm -f nginx-container
docker rm -f flask-container

docker network create my-bridge-network
docker run -d --name nginx-container --network my-bridge-network nginx
docker run -d --name flask-container --network my-bridge-network -p 5000:5000 my-flask-app
docker network inspect my-bridge-network
```

`network inspect` showed both containers on the `172.19.0.0/16` subnet: `nginx-container` at `172.19.0.2` and `flask-container` at `172.19.0.3`. Containers on the same bridge network can reach each other by name - Docker's built-in DNS handles resolution.

---

## Task 6 - Cleanup, Documentation, and Docker Hub Push

**June 26, 2026**

```bash
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker image prune -a
docker volume prune
```

`docker image prune -a` deleted `my-flask-app` along with everything else. `docker tag` then failed with "no such image." Had to rebuild before tagging.

```bash
docker build -t my-flask-app .
docker login
docker tag my-flask-app zionabyrke/my-flask-app
docker push zionabyrke/my-flask-app
```

Image visible in Docker Desktop under the My Hub tab after push. Docker Hub repo: [zionabyrke/my-flask-app](https://hub.docker.com/r/zionabyrke/my-flask-app).
