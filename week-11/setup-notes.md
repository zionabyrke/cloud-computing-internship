# Week 11 Setup Notes - Multi-Cloud & Hybrid Architectures

**Intern:** Renz Kirby Onia
**Date Range:** July 6–10, 2026
**Environment:** OpenStackVM (Azure, reused from Week 3) | Terraform 1.15.7 | rclone | AWS CLI v2

---

## Task 1 - Environment Setup

**July 9, 2026**

Started the Week 3 `OpenStackVM` from the Azure Portal and SSH'd in. DevStack 2026.2 was already installed - no reinstall needed. Checked existing networks to confirm DevStack was still running cleanly before installing anything new.

```bash
source /opt/stack/devstack/openrc admin admin
openstack network list

sudo apt install git curl python3-pip -y
sudo snap install terraform --classic
sudo apt install rclone -y
sudo apt install docker.io -y
sudo systemctl enable --now docker
sudo usermod -aG docker azureuser
```

Verified versions for Terraform, rclone, and Docker before moving on.

---

## Task 2 - OpenStack Network, VM, and Floating IP

**July 9, 2026**

Created a fresh set of Week 11 resources separate from the Week 3 ones still sitting in DevStack.

```bash
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
```

`week11-vm` came up `ACTIVE` but SSH hung. The `br-ex` bridge, same issue from Week 3, came back down after the VM was restarted and lost its IPv4 address. Fixed manually:

```bash
sudo ip link set br-ex up
sudo ip addr add 172.24.4.1/24 dev br-ex
```

SSH into `week11-vm` worked after that.

---

## Task 3 - Deploy OpenStack Instances via Terraform

**July 8, 2026**

Created `~/terraform-week11/` with three files: `versions.tf`, `provider.tf`, and `main.tf`. See `terraform/` in this repo for the full content.

`terraform init` failed when run from the `stack` user's home directory. Ran as `azureuser` from `/home/azureuser/terraform-week11` instead. Credentials were hardcoded in `provider.tf` as a result - not ideal but the provider block requires them when not using environment variables and the stack user path wasn't cooperating.

```bash
terraform init
terraform plan
terraform apply
openstack server list
```

Apply completed with 2 resources added - both Cirros instances showed `ACTIVE` in `openstack server list`.

---

## Task 4 - Multi-cloud Deployment

**July 9, 2026**

Added an `aws` provider block and an `aws_s3_bucket` resource to `main.tf` so one `terraform apply` deploys to both OpenStack and AWS.

LocalStack was the module's suggested simulator but now requires an auth token to function. Used real AWS instead - same classmate account from Week 9.

Ubuntu 24.04 doesn't have `awscli` in apt. Installed from the AWS official installer:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws configure
```

```bash
terraform plan
terraform apply
aws s3 ls
```

`aws s3 ls` showed `intern-multicloud-demo-renzkirby` created alongside the unchanged OpenStack instances.

---

## Task 5 - Cloud Storage Synchronization with rclone

**July 9, 2026**

Configured two rclone remotes: `aws-s3` (pointing to the S3 bucket) and `gdrive` (Google Drive).

Google Drive OAuth needs a browser. The VM doesn't have one. The fix: run `rclone authorize "drive"` on the local Arch machine, complete the browser flow there, then paste the resulting JSON token back into the rclone config prompt on the VM.

```bash
rclone config
# aws-s3: S3 provider, existing bucket intern-multicloud-demo-renzkirby
# gdrive: Google Drive, token pasted from local machine
```

Created a test file and ran the sync chain:

```bash
mkdir -p ~/rclone-test-data
echo "multicloud test file" > ~/rclone-test-data/test.txt

rclone copy ~/rclone-test-data aws-s3:intern-multicloud-demo-renzkirby/backup
rclone sync aws-s3:intern-multicloud-demo-renzkirby/backup gdrive:week11-backup
rclone check aws-s3:intern-multicloud-demo-renzkirby/backup gdrive:week11-backup
```

`rclone check` returned `0 differences found, 1 matching files` - the file was present and identical on both remotes.

---

## Task 6 - Architecture Documentation

**July 9, 2026**

Created an architecture diagram in Draw.io covering the full hybrid path: local machine → OpenStackVM (Azure) → OpenStack Neutron/Nova → Terraform → AWS S3 → rclone → Google Drive. Committed all Terraform configs, sync logs, and the report to the GitHub repository.

---

## Task 7 - Full Resource Cleanup

**July 9, 2026**

`terraform destroy` only removes what `main.tf` manages - the two Cirros instances and the S3 bucket. Everything created manually in Task 2 had to be removed separately, in dependency order.

```bash
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
```

`openstack network list` returned to DevStack defaults. `aws s3 ls` came back empty.
