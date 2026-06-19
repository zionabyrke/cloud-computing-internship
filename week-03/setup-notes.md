# Week 3 Setup Notes

**Intern:** Renz Kirby Onia
**Date Range:** June 15-19, 2026
**Host:** OpenStackVM | Ubuntu 24.04 LTS | Standard_D2s_v3 | East Asia

---

## Task 1 - Azure VM Deployment

**June 18, 2026**

VM: Standard_D2s_v3, Ubuntu 24.04 LTS, Standard HDD 64GB, Static public IP, NSG TCP 22 + 80.

```bash
chmod 400 ~/.ssh/OpenStackVM_key.pem
ssh -i ~/.ssh/OpenStackVM_key.pem azureuser@20.255.184.93
free -h && df -h && nproc && lsb_release -a
```

Result: 7.8GB RAM, 60GB disk, 2 cores, Ubuntu 24.04.4 LTS.

---

## Task 2 - DevStack Installation

**June 18, 2026**

```bash
sudo apt update && sudo apt upgrade -y
sudo useradd -s /bin/bash -d /opt/stack -m stack
sudo chmod +x /opt/stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
sudo -u stack -i
ip addr show | grep inet | grep -v "127.0.0.1"
git clone https://opendev.org/openstack/devstack && cd devstack
nano local.conf
./stack.sh

HOST_IP must be the VM private IP (10.1.0.4), not 127.0.0.1 - Neutron fails to bind on a cloud VM with loopback. Completed in 2273 seconds. Horizon at http://10.1.0.4/dashboard.

---

## Task 3 - VPC and Subnet Configuration

**June 18, 2026**

```bash
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
```

DevStack's default private network is 10.0.0.0/26 - lab-vpc at /24 is a different subnet, no conflict.

---

## Task 4 - Security Groups Configuration

**June 18, 2026**

```bash
openstack security group create ssh-secgrp
openstack security group rule create --proto tcp --dst-port 22 ssh-secgrp
openstack security group rule create --proto icmp ssh-secgrp
openstack security group rule list ssh-secgrp
```

---

## Task 5 - IAM Users and RBAC

**June 18, 2026**

```bash
openstack user create --password intern123 intern-user
openstack role add --user intern-user --project demo member

export OS_USERNAME=intern-user
export OS_PASSWORD=intern123
export OS_PROJECT_NAME=demo
openstack network list   # succeeds
openstack user list      # 403: list_users disallowed

source /opt/stack/devstack/openrc admin admin
openstack role remove --user intern-user --project demo member
openstack role add --user intern-user --project demo reader

export OS_USERNAME=intern-user && export OS_PASSWORD=intern123 && export OS_PROJECT_NAME=demo
openstack network list                        # succeeds
openstack network create test-denied-network  # 403: create_network disallowed

source /opt/stack/devstack/openrc admin admin
```

| Role | Read | Write | List users |
|------|:----:|:-----:|:----------:|
| member | yes | yes | no |
| reader | yes | no | no |

---

## Task 6 - SSH Key Pairs and Secure VM Launch

**June 18-19, 2026**

```bash
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
```

SSH hung despite ping working - the /32 rule from Exercise 1 was blocking it since Neutron traffic source != Azure public IP. Opened 0.0.0.0/0 to confirm, then restored /32.

---

## Task 7 - Lab Exercises

**June 19, 2026**

### Exercise 1 - Restrict SSH to Specific IP

```bash
openstack security group rule list ssh-secgrp
openstack security group rule delete <SSH_RULE_ID>
openstack security group rule create \
  --proto tcp --dst-port 22 \
  --remote-ip 20.255.184.93/32 ssh-secgrp
```

### Exercise 2 - Read-only IAM User

Covered in Task 5.

### Exercise 3 - SSH Key Rotation

```bash
ssh-keygen -t rsa -b 4096 -f ~/cloudkey_new
openstack keypair create --public-key ~/cloudkey_new.pub lab-key-new
openstack keypair delete lab-key
ssh -i ~/cloudkey cirros@172.24.4.103
```

Inside cloud-vm (echo fails on long keys in Cirros shell, use tee):

```bash
tee ~/.ssh/authorized_keys << 'EOF'
<content of cloudkey_new.pub>
EOF
cat ~/.ssh/authorized_keys && exit
```

```bash
ssh -o BatchMode=yes -o ConnectTimeout=5 -i ~/cloudkey cirros@172.24.4.103
ssh -i ~/cloudkey_new cirros@172.24.4.103
```

### Exercise 4 - Bash Automation Script

```bash
~/deploy_vm.sh
```

Failed on second run with "More than one SecurityGroup exists with the name auto-secgrp" from a partial earlier run. Deleted duplicates by UUID:

```bash
openstack security group list
openstack security group delete <UUID_1>
openstack security group delete <UUID_2>
```

See scripts/deploy_vm.sh.
