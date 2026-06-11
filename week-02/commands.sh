#!/usr/bin/env bash
# Week 2 - Linux Administration for Cloud
# Cloud Computing Internship | Lamina Studios, LLC.
# Intern: Renz Kirby Onia
#
# Usage:
#   bash commands.sh <VM_PUBLIC_IP>
#   bash commands.sh 20.239.122.200
#
# This script documents all commands used during Week 2 Linux admin tasks
# Tasks 1–6 are run INSIDE the VM over SSH. This script handles the SSH
# connection, then prints each task's commands for you to paste in-session
#
# All Bash scripts created during the week live in the scripts/ folder

VM_IP="${1}"

if [[ -z "$VM_IP" ]]; then
  echo "Usage: bash commands.sh <VM_PUBLIC_IP>"
  echo "Example: bash commands.sh 20.239.122.200"
  exit 1
fi

echo "==> Using VM Public IP: $VM_IP"
echo ""

# SSH INTO VM
echo "--- Connecting to HelloCloudVM ---"
ssh -i ~/.ssh/hellocloud_key.pem azureuser@"$VM_IP"

# Note: 
# Copy and paste commands per task section as needed

echo ""
echo "--- Task 1: System Information ---"
echo ""
echo "  # Full kernel and OS info"
echo "  uname -a"
echo ""
echo "  # Disk space usage (human-readable)"
echo "  df -h"
echo ""
echo "  # Real-time process and CPU/memory monitor (press q to exit)"
echo "  top"


echo ""
echo "--- Task 2: File and Directory Management ---"
echo ""
echo "  # Create a projects directory and navigate into it"
echo "  mkdir ~/projects"
echo "  cd ~/projects"
echo ""
echo "  # Create hello.txt and read it back"
echo "  echo 'Hello Lamina!' > hello.txt"
echo "  cat hello.txt"
echo ""
echo "  # Install git, curl, and wget"
echo "  sudo apt install git curl wget -y"
echo ""
echo "  # Check current file permissions"
echo "  ls -l"
echo ""
echo "  # Set hello.txt to readable (owner rw, group r, other r)"
echo "  chmod 644 ~/projects/hello.txt"
echo ""
echo "  # Create an empty script placeholder and make it executable"
echo "  touch ~/projects/script.sh"
echo "  chmod +x ~/projects/script.sh"
echo ""
echo "  # Confirm permissions updated"
echo "  ls -l ~/projects"


echo ""
echo "--- Task 3: User Creation and Management ---"
echo ""
echo "  # Create intern1 interactively (set password, press Enter through optional fields)"
echo "  sudo adduser intern1"
echo ""
echo "  # Add intern1 to the sudo group"
echo "  sudo usermod -aG sudo intern1"


echo ""
echo "--- Task 4: Bash Script Automation ---"
echo ""
echo "  # Open nano and write hello.sh (see scripts/hello.sh for content)"
echo "  nano ~/hello.sh"
echo ""
echo "  # Make it executable"
echo "  chmod +x ~/hello.sh"
echo ""
echo "  # Run it from home directory (NOT from ~/projects - see setup-notes.md)"
echo "  ~/hello.sh"
echo ""
echo "  # Write and run setup.sh (see scripts/setup.sh for content)"
echo "  nano ~/setup.sh"
echo "  chmod +x ~/setup.sh"
echo "  ~/setup.sh"
echo ""
echo "  # Write user_setup.sh and run it with intern2 as the argument"
echo "  nano ~/user_setup.sh"
echo "  chmod +x ~/user_setup.sh"
echo "  ~/user_setup.sh intern2"


echo ""
echo "--- Task 5: Cron Job Scheduling ---"
echo ""
echo "  # Write backup_script.sh (see scripts/backup_script.sh for content)"
echo "  nano ~/backup_script.sh"
echo "  chmod +x ~/backup_script.sh"
echo ""
echo "  # Open crontab editor (select nano = option 1 when prompted)"
echo "  crontab -e"
echo ""
echo "  # Add this line inside crontab to run backup daily at 9 PM UTC:"
echo "  # 0 21 * * * /home/azureuser/backup_script.sh"
echo ""
echo "  # Verify the cron entry was saved"
echo "  crontab -l"
echo ""
echo "  # NOTE: VM time is UTC. 9 PM UTC = 5 AM PHT (UTC+8)."
echo "  # The job will not fire at 9 PM local time."


echo ""
echo "--- Task 6: Resource Monitoring ---"
echo ""
echo "  # Real-time CPU and process activity (press q to exit)"
echo "  top"
echo ""
echo "  # Disk space report for all mounted filesystems"
echo "  df -h"
echo ""
echo "  # Memory usage in megabytes"
echo "  free -m"



echo ""
echo "--- Cleanup: Stopping the VM ---"
echo ""
echo "  # Do NOT run 'sudo shutdown now' inside SSH."
echo "  # That only stops the OS - Azure keeps charging compute fees."
echo "  # Instead, stop from the Portal or use Azure CLI:"
echo ""
echo "  az vm deallocate --resource-group internship-rg --name HelloCloudVM"
echo ""
echo "  # Confirm status shows: Stopped (deallocated)"
echo ""
echo "Done."
