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

# Usage:
#   sudo ./backup-etcd.sh

# usr/local/bin
# Download this script:
# 



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