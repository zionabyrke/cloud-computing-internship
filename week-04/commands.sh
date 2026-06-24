#!/usr/bin/env bash
# Week 4 - Storage & Database Services
# Cloud Computing Internship | Lamina Studios, LLC.
# Intern: Renz Kirby Onia
#
# Usage: bash commands.sh <VM_PUBLIC_IP>

VM_IP="${1}"
if [[ -z "$VM_IP" ]]; then
  echo "Usage: bash commands.sh <VM_PUBLIC_IP>"
  exit 1
fi

ssh -i ~/.ssh/hellocloud_key.pem azureuser@"$VM_IP"

# --- Task 1 ---
uname -a
df -h
free -m

# --- Task 2 ---
sudo ufw allow ssh
sudo ufw allow 3306
sudo ufw allow 5000
sudo ufw enable

# --- Task 3 ---
sudo apt update && sudo apt install mysql-server -y
sudo mysql_secure_installation
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql
sudo systemctl status mysql | head -5

# --- Task 4 ---
sudo mysql
# Inside MySQL:
# CREATE DATABASE cloud_db;
# CREATE USER 'cloud_user'@'%' IDENTIFIED BY 'StrongPassword123';
# GRANT ALL PRIVILEGES ON cloud_db.* TO 'cloud_user'@'%';
# FLUSH PRIVILEGES;
# EXIT;

mysql -u cloud_user -p -h 127.0.0.1 cloud_db
# Inside MySQL:
# CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100), email VARCHAR(100));
# INSERT INTO users (name, email) VALUES ('Alice', 'alice@email.com');
# SELECT * FROM users;

# --- Task 5 ---
sudo apt install python3 python3-pip -y
pip3 install flask mysql-connector-python --break-system-packages
python3 -c "import flask, mysql.connector; print('OK')"
mkdir ~/cloud-app && cd ~/cloud-app
nano app.py
export DB_HOST=localhost
export DB_USER=cloud_user
export DB_PASS=StrongPassword123
export DB_NAME=cloud_db
python3 app.py
curl http://127.0.0.1:5000/
curl http://127.0.0.1:5000/users

# --- Task 6 ---
# On local Arch machine:
# curl http://20.24.220.135:5000/
# curl http://20.24.220.135:5000/users

nohup python3 app.py > ~/cloud-app/app.log 2>&1 &
curl http://127.0.0.1:5000/users
cat ~/cloud-app/app.log
kill 3098
