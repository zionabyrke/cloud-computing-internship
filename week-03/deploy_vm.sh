#!/bin/bash
# =============================================================================
# deploy_vm.sh - OpenStack VM Deployment Automation Script
# Week 3 Exercise 4 | Cloud Computing Internship | Lamina Studios, LLC.
#
# Creates an isolated VPC, subnet, security group with SSH rule, and launches
# a Cirros VM. Polls until the VM reaches ACTIVE status then prints a summary.
#
# Usage (run as stack user inside the OpenStack host):
#   ~/deploy_vm.sh
# =============================================================================

set -e

# Source admin credentials
source /opt/stack/devstack/openrc admin admin

# [1/6] Create network
echo "[1/6] Creating network..."
openstack network create auto-vpc
echo "Network auto-vpc created."

# [2/6] Create subnet
echo "[2/6] Creating subnet..."
openstack subnet create auto-subnet \
  --network auto-vpc \
  --subnet-range 10.1.0.0/24 \
  --gateway 10.1.0.1
echo "Subnet auto-subnet created."

# [3/6] Create security group
echo "[3/6] Creating security group..."
openstack security group create auto-secgrp
echo "Security group auto-secgrp created."

# [4/6] Add SSH rule to security group
echo "[4/6] Adding SSH rule to security group..."
openstack security group rule create \
  --proto tcp \
  --dst-port 22 \
  --remote-ip 0.0.0.0/0 \
  auto-secgrp
echo "SSH rule added."

# [5/6] Launch VM
echo "[5/6] Launching VM..."
openstack server create \
  --flavor m1.tiny \
  --image cirros-0.6.3-x86_64-disk \
  --network auto-vpc \
  --security-group auto-secgrp \
  --key-name lab-key-new \
  auto-vm
echo "VM auto-vm launched."

# [6/6] Wait for VM to become ACTIVE
echo "[6/6] Waiting for VM to become ACTIVE..."
for i in 1 2 12; do
  STATUS=$(openstack server show auto-vm -f value -c status)
  echo "Status: $STATUS"
  if [ "$STATUS" = "ACTIVE" ]; then
    echo "auto-vm is ACTIVE."
    break
  fi
  sleep 5
done

# Summary
echo ""
echo "=== Deployment Complete ==="
openstack server list
openstack network list
