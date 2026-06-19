#!/usr/bin/env bash
# Week 3 - Networking & Security Basics (OpenStack DevStack)
# Cloud Computing Internship | Lamina Studios, LLC.
# Intern: Renz Kirby Onia
#
# Usage: bash commands.sh <AZURE_VM_PUBLIC_IP>

VM_IP="${1}"
if [[ -z "$VM_IP" ]]; then
  echo "Usage: bash commands.sh <AZURE_VM_PUBLIC_IP>"
  exit 1
fi

ssh -i ~/.ssh/OpenStackVM_key.pem azureuser@"$VM_IP"

# --- Task 1 ---
free -h && df -h && nproc && lsb_release -a

# --- Task 2 ---
sudo apt update && sudo apt upgrade -y
sudo useradd -s /bin/bash -d /opt/stack -m stack
sudo chmod +x /opt/stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
sudo -u stack -i
ip addr show | grep inet | grep -v "127.0.0.1"
git clone https://opendev.org/openstack/devstack && cd devstack
nano local.conf
./stack.sh

# --- Task 3 ---
source /opt/stack/devstack/openrc admin admin
openstack network create lab-vpc
openstack subnet create lab-subnet \
  --network lab-vpc \
  --subnet-range 10.0.0.0/24 \
  --gateway 10.0.0.1
openstack router create lab-router
openstack router add subnet lab-router lab-subnet
openstack router set lab-router --external-gateway public
openstack network list && openstack router list && openstack subnet list

# --- Task 4 ---
openstack security group create ssh-secgrp
openstack security group rule create --proto tcp --dst-port 22 ssh-secgrp
openstack security group rule create --proto icmp ssh-secgrp
openstack security group rule list ssh-secgrp

# --- Task 5 ---
openstack user create --password intern123 intern-user
openstack role add --user intern-user --project demo member
export OS_USERNAME=intern-user OS_PASSWORD=intern123 OS_PROJECT_NAME=demo
openstack network list
openstack user list
source /opt/stack/devstack/openrc admin admin
openstack role remove --user intern-user --project demo member
openstack role add --user intern-user --project demo reader
export OS_USERNAME=intern-user OS_PASSWORD=intern123 OS_PROJECT_NAME=demo
openstack network list
openstack network create test-denied-network
source /opt/stack/devstack/openrc admin admin

# --- Task 6 ---
ssh-keygen -t rsa -b 4096 -f ~/cloudkey
openstack keypair create --public-key ~/cloudkey.pub lab-key
openstack server create \
  --flavor m1.small \
  --image cirros-0.6.3-x86_64-disk \
  --network lab-vpc \
  --security-group ssh-secgrp \
  --key-name lab-key \
  cloud-vm
openstack floating ip create public
openstack server add floating ip cloud-vm 172.24.4.103
chmod 600 ~/cloudkey
ssh -i ~/cloudkey cirros@172.24.4.103

# --- Task 7, Ex 1 ---
openstack security group rule list ssh-secgrp
openstack security group rule delete <SSH_RULE_ID>
openstack security group rule create \
  --proto tcp --dst-port 22 \
  --remote-ip 20.255.184.93/32 ssh-secgrp

# --- Task 7, Ex 3 ---
ssh-keygen -t rsa -b 4096 -f ~/cloudkey_new
openstack keypair create --public-key ~/cloudkey_new.pub lab-key-new
openstack keypair delete lab-key
ssh -i ~/cloudkey cirros@172.24.4.103
# inside VM: tee ~/.ssh/authorized_keys << 'EOF' ... EOF
ssh -o BatchMode=yes -o ConnectTimeout=5 -i ~/cloudkey cirros@172.24.4.103
ssh -i ~/cloudkey_new cirros@172.24.4.103

# --- Task 7, Ex 4 ---
~/deploy_vm.sh
