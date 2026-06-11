#!/bin/bash
# Backup script - copies ~/projects to a timestamped folder inside ~/backups
# Scheduled via cron: 0 21 * * * /home/azureuser/backup_script.sh
# Fires at 9 PM UTC = 5 AM PHT (UTC+8)

DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p ~/backups
cp -r ~/projects ~/backups/projects_$DATE
echo "Backup completed: projects_$DATE"
