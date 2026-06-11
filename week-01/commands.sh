#!/usr/bin/env bash

# Week 1 - Cloud Fundamentals & VM Setup
# Cloud Computing Internship | Lamina Studios, LLC.
# Intern: Renz Kirby Onia
#
# Usage:
#   bash commands.sh <VM_PUBLIC_IP>
#   bash commands.sh 20.239.122.200
#
# All commands are organized by task. The VM_PUBLIC_IP argument lets you
# re-run or adapt these commands against any Azure VM you deploy.


VM_IP="${1}"

if [[ -z "$VM_IP" ]]; then
  echo "Usage: bash commands.sh <VM_PUBLIC_IP>"
  echo "Example: bash commands.sh 20.239.122.200"
  exit 1
fi

echo "==> Using VM Public IP: $VM_IP"
echo ""


echo "--- Task 1: Post-deployment SSH key setup ---"
mv ~/Downloads/hellocloud_key.pem ~/.ssh/hellocloud_key.pem
chmod 400 ~/.ssh/hellocloud_key.pem
ls -la ~/.ssh/hellocloud_key.pem


echo ""
echo "--- Task 2: SSH into VM ---"
ssh -i ~/.ssh/hellocloud_key.pem azureuser@"$VM_IP"


echo ""
echo "--- Task 3: Commands to run INSIDE the VM ---"
echo "Copy and paste these after you SSH in:"
echo ""
echo "  # Update and upgrade system packages"
echo "  sudo apt update && sudo apt upgrade -y"
echo ""
echo "  # Create a minimal HTML file in the home directory"
echo "  echo 'Hello Cloud!' > ~/index.html"
echo ""
echo "  # Open on port 8080 using built-in Python HTTP server"
echo "  python3 -m http.server 8080"
echo ""
echo "  # Then open on your local machine:"
echo "  # http://$VM_IP:8080"
echo ""

