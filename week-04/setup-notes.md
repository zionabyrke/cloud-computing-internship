# Week 4 Setup Notes - Storage & Database Services

**Intern:** Renz Kirby Onia
**Date Range:** June 22–26, 2026
**VM:** HelloCloudVM | Ubuntu 24.04 LTS | 20.24.220.135

---

## Task 1 - VM Access and System Verification

**June 23, 2026**

The public IP from Week 2 was already deleted, so I created a new Standard Static IP in the Portal and attached it before starting. Started the VM from `Stopped (Deallocated)` and waited for `Running`.

```bash
ssh -i ~/.ssh/hellocloud_key.pem azureuser@20.24.220.135
uname -a && df -h && free -m
```

Ubuntu 24.04 LTS, 26GB disk available, 829MB RAM with 494MB free.

---

## Task 2 - UFW Firewall Configuration

**June 23, 2026**

SSH goes first - enabling UFW before allowing SSH locks out the active session.

```bash
sudo ufw allow ssh
sudo ufw allow 3306
sudo ufw allow 5000
sudo ufw enable
```

---

## Task 3 - MySQL Deployment and Configuration

**June 23, 2026**

```bash
sudo apt update && sudo apt install mysql-server -y
sudo mysql_secure_installation
```

`mysql_secure_installation` skipped the root password prompt entirely. Turns out Ubuntu 24.04 uses `auth_socket` by default, so root auth goes through `sudo` rather than a password. Answered `n` to VALIDATE PASSWORD, `y` to the rest.

Changed `bind-address` to `0.0.0.0` in the MySQL config so the database accepts connections from outside loopback:

```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
# bind-address = 0.0.0.0
sudo systemctl restart mysql
sudo systemctl status mysql | head -5
```

---

## Task 4 - Database, User, Schema, and Test Data

**June 23, 2026**

```bash
sudo mysql
```

```sql
CREATE DATABASE cloud_db;
CREATE USER 'cloud_user'@'%' IDENTIFIED BY 'StrongPassword123';
GRANT ALL PRIVILEGES ON cloud_db.* TO 'cloud_user'@'%';
FLUSH PRIVILEGES;
EXIT;
```

Connected as `cloud_user` using `-h 127.0.0.1` instead of `localhost`. `localhost` resolves to the Unix socket; `127.0.0.1` forces TCP, which is what the Flask app uses later.

```bash
mysql -u cloud_user -p -h 127.0.0.1 cloud_db
```

```sql
CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100), email VARCHAR(100));
INSERT INTO users (name, email) VALUES ('Alice', 'alice@email.com');
SELECT * FROM users;
```

---

## Task 5 - Flask Web Application

**June 23, 2026**

```bash
sudo apt install python3 python3-pip -y
pip3 install flask mysql-connector-python --break-system-packages
python3 -c "import flask, mysql.connector; print('OK')"
mkdir ~/cloud-app && cd ~/cloud-app && nano app.py
```

`--break-system-packages` is needed on Ubuntu 24.04 because of PEP 668, which marks the base Python environment as externally managed and rejects pip installs without it.

App reads DB credentials from environment variables - nothing hardcoded in the source. See `app/app.py`.

```bash
export DB_HOST=localhost
export DB_USER=cloud_user
export DB_PASS=StrongPassword123
export DB_NAME=cloud_db
python3 app.py
```

These env vars don't persist across SSH sessions. A new terminal tab needs them re-exported before the app will start.

Tested from a second SSH tab:

```bash
curl http://127.0.0.1:5000/
# Cloud App Connected to Database!
curl http://127.0.0.1:5000/users
# [{"email": "alice@email.com", "id": 1, "name": "Alice"}]
```

---

## Task 6 - External Access and Background Process

**June 23, 2026**

Port 5000 was open in UFW but the endpoint was still dead from outside. UFW runs inside the OS; Azure NSG sits in front of the VM at the network level. They're independent - both need to allow the port. Added `Allow-5000` (TCP 5000, Any source, priority 320) in the Azure Portal NSG settings.

Tested from local Arch machine after the NSG rule was added:

```bash
curl http://20.24.220.135:5000/
curl http://20.24.220.135:5000/users
# [{"email": "alice@email.com", "id": 1, "name": "Alice"}]
```

Relaunched as a background process so it survives closing the terminal:

```bash
nohup python3 app.py > ~/cloud-app/app.log 2>&1 &
curl http://127.0.0.1:5000/users
cat ~/cloud-app/app.log
kill 3098
```
