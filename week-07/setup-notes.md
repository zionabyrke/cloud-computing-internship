# Week 7 Setup Notes - Infrastructure as Code (Terraform)

**Intern:** Renz Kirby Onia
**Date Range:** June 29 – July 3, 2026
**Environment:** Local Arch Linux | Terraform v1.15.1 | Azure CLI (pipx) | Azure for Students

---

## Task 1 - Environment Setup

**July 1, 2026**

Terraform came from pacman. Azure CLI was installed via pipx since it's a Python package and pipx keeps it isolated from the system Python.

```bash
sudo pacman -S terraform
sudo pacman -S python-pipx
pipx ensurepath
pipx install azure-cli

mkdir -p ~/terraform-week7 && cd ~/terraform-week7

az login
az account show
terraform -v
ssh-keygen -t rsa -b 4096 -f ~/.ssh/week7_key
```

`az login` opens a browser for the Azure sign-in flow. `az account show` confirmed the active Azure for Students subscription. Terraform v1.15.1 verified. SSH key pair generated for VM access in later tasks.

---

## Task 2 - First VM Deployment using Terraform

**July 1, 2026**

This is where the AWS-to-Azure translation got tedious. The module just needs a provider block and an EC2 resource. Azure needs a resource group, VNet, subnet, NSG, NIC, and public IP all explicitly defined before the VM block can even reference them. Spread across three files:

- `providers.tf` - azurerm provider with `features {}` block
- `network.tf` - resource group, VNet (`10.0.0.0/16`), subnet1 (`10.0.1.0/24`), NSG with SSH rule, NSG-to-subnet association
- `main.tf` - public IP, NIC (referencing subnet1), VM (referencing NIC), with SSH public key injected via `admin_ssh_key`

```bash
terraform init
terraform plan
terraform apply
```

Plan showed 8 resources to add. Apply created all 8. Verified by SSHing into the VM:

```bash
ssh -i ~/.ssh/week7_key azureuser@$(terraform output -raw public_ip_address)
```

---

## Task 3 - Variables and Outputs

**July 1, 2026**

Pulled hardcoded values out of `main.tf` into `variables.tf` - VM size, image offer, image SKU, and admin username. Added `outputs.tf` for VM ID and public IP.

After updating `main.tf` to reference `var.*`, ran plan to confirm Terraform saw no infrastructure change:

```bash
terraform plan
terraform apply
terraform output
```

Plan showed `0 to add, 0 to change, 0 to destroy` - the refactor didn't touch any deployed resource, only the config structure.

Accidentally overwrote `main.tf` midway and lost three resource blocks. Terraform caught it on the next `plan` with undeclared resource errors before anything was applied. Restored the missing blocks from memory and reran.

---

## Task 4 - Expanding the Virtual Network

**July 1, 2026**

The module called for a new VPC, but since Azure's VNet was already created in Task 2, adding a second subnet was the equivalent step. Added `week7-subnet2` at `10.0.2.0/24` to `network.tf`.

```bash
terraform plan
terraform apply
```

Plan detected exactly 1 resource to add. Applied cleanly.

---

## Task 5 - Combining VM and New Subnet

**July 1, 2026**

Moved the VM's NIC from subnet1 to subnet2 by updating the `subnet_id` reference in the NIC's `ip_configuration` block. Expected this to force a destroy-and-recreate of the NIC since subnet assignment usually is immutable - but the azurerm provider handled it as an in-place update.

```bash
terraform plan
terraform apply
ssh -i ~/.ssh/week7_key azureuser@$(terraform output -raw public_ip_address)
```

Plan showed 1 to change. SSH into the VM after apply confirmed it was up and reachable with the new network config.

---

## Task 6 - Lifecycle Testing and Teardown

**July 1, 2026**

Ran through a full change-detect-revert cycle before destroying:

```bash
terraform plan        # 0 changes - baseline confirmed
# change vm_size in variables.tf
terraform plan        # 1 to change - Terraform flagged it
# revert vm_size
terraform plan        # 0 changes - back to baseline
terraform destroy
```

Destroy removed all 8 resources. Confirmed in the Azure Portal that nothing remained from the week's work.
