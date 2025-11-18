#!/bin/bash
# backup-etcd.sh
# Created: 2025-11-12, dalthonmh
# Description:
# This script creates a backup of the etcd database and manages backup retention.
# It saves the etcd snapshot to a specified directory and removes backups older than
# the defined retention period.

# Requirements:
# - The script must be executed with sudo privileges or as a user with access to etcd.
# - Ensure etcdctl is installed and properly configured.
# - The etcd certificates must be accessible at the specified paths.

# Notes:
# - The backup directory will be created if it does not exist.
# - Retention is managed by deleting backups older than the specified number of days.
# - Recomended path for this script: /usr/local/bin
# - Cronjob example for daily backup at 2 AM:
#   (crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-etcd.sh >> /var/log/etcd-backup.log 2>&1") | crontab -

# Usage:
#   sudo ./backup-etcd.sh

# Download this script:
# wget https://raw.githubusercontent.com/dalthonmh/scripts/refs/heads/main/backup-etcd.sh


BACKUP_DIR="/backup"
RETENTION_DAYS=7

# Create backup directory if it does not exist
mkdir -p ${BACKUP_DIR}

# Create etcd backup
ETCDCTL_API=3 etcdctl snapshot save ${BACKUP_DIR}/etcd-snapshot-$(date +%Y%m%d-%H%M%S).db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Clean up old backups
find ${BACKUP_DIR} -name "etcd-snapshot-*.db" -mtime +${RETENTION_DAYS} -delete

echo "Backup completed: $(date)"