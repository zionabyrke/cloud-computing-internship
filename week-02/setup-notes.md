# Week 2 Setup Notes - Linux Administration for Cloud

**Intern:** Renz Kirby Onia
**Date Range:** June 8–11, 2026
**VM:** HelloCloudVM | Ubuntu 22.04 LTS | East Asia | Standard_B2ats_v2
**Session:** Single SSH session on June 10 (same VM and IP from Week 1)


## Using commands.sh

`commands.sh` takes the VM's public IP as an argument. Run it with `bash`:

```bash
bash commands.sh <VM_PUBLIC_IP>

# Example
bash commands.sh 20.239.122.200
```

The script connects you to the VM via SSH, then prints all in-VM commands section by section so you can paste them into the session. The actual Bash scripts written during Week 2 live in the `scripts/` subfolder - you can `scp` them to the VM or recreate them with `nano` as documented below.

> **`bash` vs `~/`:** In Week 1, `commands.sh` was the entry point. By Week 2, scripts were being created and run directly on the VM. The PDF documents this: `~/hello.sh` was used instead of `./hello.sh` because `~/` always resolves to the home directory regardless of your current working directory, while `./` is relative. Same logic applies here on your local Arch machine - `bash commands.sh` needs no execute bit, `~/hello.sh` on the VM works from any directory.


## Task 1 - System Information Check

**Date Completed:** June 10, 2026   
**Tools:** Ubuntu Server 22.04 LTS terminal

### Steps

1. SSH back into `HelloCloudVM` (same key and IP from Week 1):

   ```bash
   ssh -i ~/.ssh/hellocloud_key.pem azureuser@20.239.122.200
   ```

2. Check kernel version and OS details:

   ```bash
   uname -a
   ```

   Expected output: `Linux HelloCloudVM 6.17.0-1018-azure ... x86_64 GNU/Linux`

3. Check disk space usage across all mounted filesystems:

   ```bash
   df -h
   ```

   Key line to note: `/dev/root` - total size, used, and available on the root partition.

4. View real-time process and CPU/memory activity:

   ```bash
   top
   ```

   Press `q` to exit. Functions like a terminal-based Task Manager.

### Expected Result

`uname -a` confirms Ubuntu 22.04 LTS. `df -h` shows ~26G used of 29G on root. `top` displays running processes with CPU and memory percentages.


## Task 2 - File and Directory Management

**Date Completed:** June 10, 2026   
**Tools:** Ubuntu terminal, nano

### Steps

1. Create a `projects` working directory and enter it:

   ```bash
   mkdir ~/projects
   cd ~/projects
   ```

2. Create a text file and read it back:

   ```bash
   echo "Hello Lamina!" > hello.txt
   cat hello.txt
   ```

3. Install development tools:

   ```bash
   sudo apt install git curl wget -y
   ```

   All three were already at latest version on this VM - `apt` reports this and exits cleanly.

4. Check current file permissions:

   ```bash
   ls -l
   ```

5. Set `hello.txt` to standard read-only permissions (owner read/write, group and others read-only):

   ```bash
   chmod 644 ~/projects/hello.txt
   ```

6. Create an empty script placeholder and make it executable:

   ```bash
   touch ~/projects/script.sh
   chmod +x ~/projects/script.sh
   ```

7. Confirm permissions are correct:

   ```bash
   ls -l ~/projects
   ```

   Expected output:
   ```
   -rw-r--r-- 1 azureuser azureuser   14 Jun 10 06:49 hello.txt
   -rwxr-xr-x 1 azureuser azureuser    0 Jun 10 06:52 script.sh
   ```

### Permission Reference

| chmod value | Meaning |
|-------------|---------|
| `644` | Owner: read+write / Group: read / Others: read - readable, not runnable |
| `+x` | Adds execute bit for owner, group, others - makes file runnable as a program |
| `400` | Owner read-only - used for SSH private keys (Week 1) |


## Task 3 - User Creation and Management

**Date Completed:** June 10, 2026   
**Tools:** Ubuntu terminal

### Steps

1. Create user `intern1` interactively:

   ```bash
   sudo adduser intern1
   ```

   Set a password when prompted. Press `Enter` through the optional Full Name, Room Number, etc. fields. Confirm with `y`.

2. Grant `intern1` sudo privileges:

   ```bash
   sudo usermod -aG sudo intern1
   ```

   `-aG` means *append to group* - it adds `intern1` to `sudo` without removing them from any existing groups.

### Expected Result

`intern1` is created with a home directory at `/home/intern1` and added to the `sudo` supplemental group. In a real team environment, this is the pattern used to give a new team member elevated access without sharing the primary `azureuser` credentials.


## Task 4 - Bash Script Automation

**Date Completed:** June 10, 2026   
**Tools:** nano, Bash

Three scripts were written directly on the VM using `nano`. Their content is preserved in the `scripts/` folder of this repository.


### hello.sh - Welcome message with UTC timestamp

```bash
nano ~/hello.sh
```

Content (see `scripts/hello.sh`):

```bash
#!/bin/bash
# Simple automation script

echo "Welcome to Lamina Studios Cloud Training"
DATE=$(date)
echo "Today's date is: $DATE"

# List files in the home directory
ls ~
```

Make executable and run:

```bash
chmod +x ~/hello.sh
~/hello.sh
```

> **Why `~/hello.sh` and not `./hello.sh`?**
> The script was saved to `~` (home directory). Running `./hello.sh` from inside `~/projects` looks for the file in `~/projects/` - it's not there, so bash throws `No such file or directory`. Using `~/hello.sh` always resolves to home regardless of where you currently are. This applies identically on your Arch machine: `bash commands.sh` works from any directory, `./commands.sh` only works if you're already in the folder containing the file.


### setup.sh - VM auto-setup script

```bash
nano ~/setup.sh
```

Content (see `scripts/setup.sh`):

```bash
#!/bin/bash
# Auto-setup script for a new Linux instance

echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing essential tools..."
sudo apt install git curl wget build-essential -y

echo "Setup complete!"
```

Make executable and run:

```bash
chmod +x ~/setup.sh
~/setup.sh
```


### user_setup.sh - Parameterized user creation

```bash
nano ~/user_setup.sh
```

Content (see `scripts/user_setup.sh`):

```bash
#!/bin/bash
# User creation script
USERNAME=$1
sudo adduser $USERNAME
sudo usermod -aG sudo $USERNAME
echo "User $USERNAME created and added to sudo group."
```

Make executable and run with `intern2` as the argument:

```bash
chmod +x ~/user_setup.sh
~/user_setup.sh intern2
```

`$1` captures the first argument passed to the script (`intern2`), so the same script can create any user without editing the file.


## Task 5 - Cron Job Scheduling

**Date Completed:** June 10, 2026   
**Tools:** crontab, Bash

### backup_script.sh - Timestamped project backup

```bash
nano ~/backup_script.sh
```

Content (see `scripts/backup_script.sh`):

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p ~/backups
cp -r ~/projects ~/backups/projects_$DATE
echo "Backup completed: projects_$DATE"
```

Make executable:

```bash
chmod +x ~/backup_script.sh
```

### Scheduling with cron

Open the crontab editor (select `nano` = option 1 when prompted):

```bash
crontab -e
```

Add the following line at the bottom:

```
0 21 * * * /home/azureuser/backup_script.sh
```

Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X` in nano).

Verify the entry was saved:

```bash
crontab -l
```

### Cron Syntax Reference

```
0  21  *  *  *   /home/azureuser/backup_script.sh
│  │   │  │  │
│  │   │  │  └── Day of week (0–7, 0/7 = Sunday)
│  │   │  └───── Month (1–12)
│  │   └──────── Day of month (1–31)
│  └──────────── Hour (0–23)
└─────────────── Minute (0–59)
```

> **UTC vs PHT:** The VM clock runs on UTC. `0 21 * * *` fires at 9:00 PM UTC, which is 5:00 AM Philippine Standard Time (UTC+8). The job will not execute at 9 PM local time. To schedule at 9 PM PHT, use `0 13 * * *` instead (`21 - 8 = 13`).


## Task 6 - Resource Monitoring

**Date Completed:** June 10, 2026   
**Tools:** Ubuntu terminal

### Commands

```bash
# Real-time CPU and process activity (press q to exit)
top

# Disk space across all mounted filesystems
df -h

# RAM and swap usage in megabytes
free -m
```

### Sample Output (from session)

```
# free -m
              total   used   free  shared  buff/cache  available
Mem:            892    424    181       3         181        467
Swap:             0      0      0
```

892 MB total RAM, 424 MB in use, 467 MB available. No swap configured on this VM size.


## ⚠️ VM Shutdown - Critical Azure Note

**Do NOT run `sudo shutdown now` inside the SSH session to stop the VM.**

That command shuts down the Ubuntu OS but Azure keeps the VM in a `Stopped` (not deallocated) state, and **compute billing continues**.

To actually stop billing, either:

- **Portal:** Go to the VM --> click **Stop** --> confirm the status changes to `Stopped (deallocated)`
- **Azure CLI:**
  ```bash
  az vm deallocate --resource-group internship-rg --name HelloCloudVM
  ```

Always verify the status shows **Stopped (deallocated)**, not just **Stopped**.
