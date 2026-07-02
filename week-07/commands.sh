#!/usr/bin/env bash
# Week 7 - Infrastructure as Code (Terraform on Azure)
# Cloud Computing Internship | Lamina Studios, LLC.
# Intern: Renz Kirby Onia
#
# Runs on local Arch Linux. All terraform commands run from ~/terraform-week7.

# Task 1: Environment Setup
sudo pacman -S terraform
sudo pacman -S python-pipx
pipx ensurepath
pipx install azure-cli

mkdir -p ~/terraform-week7 && cd ~/terraform-week7

az login
az account show
terraform -v
ssh-keygen -t rsa -b 4096 -f ~/.ssh/week7_key

# Task 2: First VM Deployment
terraform init
terraform plan
terraform apply

# verify via SSH
ssh -i ~/.ssh/week7_key azureuser@$(terraform output -raw public_ip_address)

# Task 3: Variables and Outputs
# edit variables.tf, outputs.tf, and update main.tf to use var.*
terraform plan
terraform apply
terraform output

# Task 4: Expanding the Virtual Network
# add week7-subnet2 block to network.tf
terraform plan
terraform apply

# Task 5: Combining VM and New Subnet
# change subnet_id in NIC ip_configuration block from subnet1 to subnet2
terraform plan
terraform apply
ssh -i ~/.ssh/week7_key azureuser@$(terraform output -raw public_ip_address)

# Task 6: Lifecycle Testing and Teardown
terraform plan
# change vm_size in variables.tf, then:
terraform plan
# revert vm_size, then:
terraform plan
terraform destroy
