# Week 1 Setup Notes - Cloud Fundamentals & VM Setup

**Intern:** Renz Kirby Onia   
**Date Range:** June 8–12, 2026   
**VM:** HelloCloudVM | Ubuntu 22.04 LTS | East Asia | Standard_B2ats_v2


## Using commands.sh

`commands.sh` accepts the VM's public IP as an argument so the same script works for any VM you deploy - not just this week's `HelloCloudVM`. Run it with `bash` since you're on Arch and not using `./`:

```bash
bash commands.sh <VM_PUBLIC_IP>

# Example
bash commands.sh 20.239.122.200
```

What it does when run:
- Moves and permission-locks the `.pem` key
- Runs the SSH command to connect to the VM
- Prints the in-VM commands for Task 3 (package update, HTML file creation, Python server) so you can paste them after logging in

> **Why bash and not ./:** Running `./commands.sh` requires the execute bit to be set (`chmod +x`). Using `bash commands.sh` runs it directly through the shell interpreter regardless of the file's execute permission - no `chmod +x` needed.


## Task 1 - Azure Account Setup & VM Deployment

**Date Completed:** June 9–10, 2026   
**Tools:** Azure Portal, Azure Virtual Machines, Network Security Groups (NSG)

### 1.1 Azure for Students Sign-up

1. Go to [https://azure.microsoft.com/en-us/free/students](https://azure.microsoft.com/en-us/free/students)
2. Sign up using your Bicol University school email (`@bicol-u.edu.ph`)
3. Verify student status - no credit card required
4. Receive **$100 free credit** valid for 12 months

### 1.2 VM Deployment

1. In the Azure Portal, go to **Virtual Machines --> Create --> Virtual Machine**
2. Fill in the configuration:

   | Field | Value |
   |-------|-------|
   | VM Name | `HelloCloudVM` |
   | Region | `(Asia Pacific) East Asia` |
   | Image | `Ubuntu Server 22.04 LTS` |
   | Size | `Standard_B2ats_v2` (2 vCPU, 2 GB RAM) |
   | Authentication | SSH public key |
   | Public IP | **None** (leave empty - see note below) |

3. Under **Generate new key pair**, name it `hellocloud_key` and download the `.pem` file when prompted
4. Click **Review + Create --> Create** and wait for deployment to complete

> **Why leave Public IP empty during creation?**
> Azure forces the **Standard SKU** on new VMs, which only supports Static assignment. Trying to configure it inline causes a SKU conflict. The fix is to leave it empty, then create a **Standard Static Public IP** as a separate resource and attach it to the VM's NIC after deployment.

### 1.3 Attach a Static Public IP (post-deployment)

1. In the Portal, go to **Public IP Addresses --> Create**
   - SKU: `Standard`
   - Assignment: `Static`
2. After creation, go to your VM's **Network Interface --> IP Configurations**
3. Select the IP config and associate the newly created Public IP

### 1.4 Configure NSG Inbound Rules

Navigate to your VM's **Network Security Group** and add:

| Rule | Protocol | Port | Source | Action |
|------|----------|------|--------|--------|
| SSH | TCP | 22 | Any | Allow |
| HTTP | TCP | 8080 | Any | Allow |

> Azure NSG denies all inbound traffic by default. Both ports must be explicitly opened.

### 1.5 Fix: Register Microsoft.Compute Resource Provider

If the VM creation fails with a provider registration error:

1. Go to **Portal --> Subscriptions --> [Your Subscription] --> Resource Providers**
2. Search for `Microsoft.Compute`
3. Click **Register** and wait for the status to show `Registered`

### Expected Result

VM status shows **Running** in the Azure Portal. Public IP is visible in the VM's overview page (e.g., `20.239.122.200`).


## Task 2 - SSH Connection from Arch Linux

**Date Completed:** June 10, 2026   
**Tools:** OpenSSH (pre-installed on Arch), Konsole

### Steps

1. Move the downloaded key to `~/.ssh/`:

   ```bash
   mv ~/Downloads/hellocloud_key.pem ~/.ssh/hellocloud_key.pem
   ```

2. Restrict permissions - SSH will refuse keys that are too permissive:

   ```bash
   chmod 400 ~/.ssh/hellocloud_key.pem
   ```

3. Connect to the VM (replace IP with your VM's public IP):

   ```bash
   ssh -i ~/.ssh/hellocloud_key.pem azureuser@20.239.122.200
   ```

4. Accept the host fingerprint prompt on first connection by typing `yes`

### Expected Result

Terminal prompt changes to:

```
azureuser@HelloCloudVM:~$
```


## Task 3 - Hello Cloud HTML Page

**Date Completed:** June 10, 2026   
**Tools:** Python3 (pre-installed on Ubuntu), Azure NSG, Google Chrome

Run these commands **inside the VM** after SSH-ing in.

### Steps

1. Update and upgrade system packages:

   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. Create a minimal HTML file:

   ```bash
   echo "Hello Cloud!" > ~/index.html
   ```

3. Start Python's built-in HTTP server on port 8080:

   ```bash
   python3 -m http.server 8080
   ```

4. On your **local machine**, open Chrome and navigate to:

   ```
   http://20.239.122.200:8080
   ```

### Expected Result

Chrome displays:

```
Hello Cloud!
```

The Konsole terminal inside the VM logs the incoming GET request confirming the connection came from your local machine.

> Port 8080 was already open in the NSG from Task 1, so no additional configuration was needed here.


## Cost Notes & Cleanup

| Action | Effect on Billing |
|--------|-------------------|
| **Stop VM** (Portal stop button) | VM is stopped but still allocated - **compute fees continue** |
| **Deallocate VM** | VM is fully released - **compute fees stop** |
| Delete unused Public IPs | Standard Static IPs have a small hourly charge even when unattached |

Always **deallocate** (not just stop) the VM when done with a session:

```bash
az vm deallocate --resource-group internship-rg --name HelloCloudVM
```

Or do it via Portal: VM --> **Stop** (Azure's Portal "Stop" button actually deallocates).

