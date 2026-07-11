#!/usr/bin/env bash
# Week 11 - Multi-Cloud & Hybrid Architectures
# Cloud Computing Internship | Lamina Studios, LLC.
# Intern: Renz Kirby Onia
#
# Runs on OpenStackVM (Azure) - reused from Week 3
# Terraform runs as azureuser from /home/azureuser/terraform-week11.
# OpenStack commands require: source /opt/stack/devstack/openrc admin admin

# Task 1: Environment setup
ssh -i ~/.ssh/OpenStackVM_key.pem azureuser@20.255.184.93

source /opt/stack/devstack/openrc admin admin
openstack network list

sudo apt install git curl python3-pip -y
sudo snap install terraform --classic
sudo apt install rclone -y
sudo apt install docker.io -y
sudo systemctl enable --now docker
sudo usermod -aG docker azureuser

terraform -v && rclone --version && docker --version

# Task 2: OpenStack network, VM, and floating IP
openstack keypair create --public-key ~/.ssh/week11_key.pub week11-key
openstack security group create week11-secgrp
openstack security group rule create --proto tcp --dst-port 22 week11-secgrp
openstack security group rule create --proto icmp week11-secgrp

openstack network create week11-net
openstack subnet create week11-subnet \
  --network week11-net \
  --subnet-range 10.2.0.0/24 \
  --gateway 10.2.0.1
openstack router create week11-router
openstack router add subnet week11-router week11-subnet
openstack router set week11-router --external-gateway public

openstack server create \
  --flavor m1.small \
  --image cirros-0.6.3-x86_64-disk \
  --network week11-net \
  --security-group week11-secgrp \
  --key-name week11-key \
  week11-vm

openstack floating ip create public
openstack server add floating ip week11-vm 172.24.4.90

# br-ex fix if bridge goes down after restart:
sudo ip link set br-ex up
sudo ip addr add 172.24.4.1/24 dev br-ex

ssh -i ~/.ssh/week11_key cirros@172.24.4.90

# Task 3: Terraform OpenStack deployment
mkdir -p ~/terraform-week11 && cd ~/terraform-week11
# write versions.tf, provider.tf, main.tf - see terraform/ in this repo
terraform init
terraform plan
terraform apply
openstack server list

# Task 4: Multi-cloud - add AWS S3
# install AWS CLI v2 (not in apt on Ubuntu 24.04)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws configure
terraform plan
terraform apply
aws s3 ls

# Task 5: rclone storage sync
rclone config
# configure aws-s3 remote (s3 provider, existing bucket)
# configure gdrive remote (drive provider, OAuth via local machine relay)

mkdir -p ~/rclone-test-data
echo "multicloud test file" > ~/rclone-test-data/test.txt

rclone copy ~/rclone-test-data aws-s3:intern-multicloud-demo-renzkirby/backup
rclone sync aws-s3:intern-multicloud-demo-renzkirby/backup gdrive:week11-backup
rclone check aws-s3:intern-multicloud-demo-renzkirby/backup gdrive:week11-backup

# Task 7: Full cleanup
terraform destroy

openstack server delete week11-vm
openstack floating ip delete 172.24.4.90
openstack router remove subnet week11-router week11-subnet
openstack router unset week11-router --external-gateway
openstack router delete week11-router
openstack subnet delete week11-subnet
openstack network delete week11-net
openstack security group delete week11-secgrp
openstack keypair delete week11-key
