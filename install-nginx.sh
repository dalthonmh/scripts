#!/bin/bash
# install-nginx.sh
# Created: 2024-02-26, dalthonmh
# Description:
# This script installs Nginx on a Linux server. It updates the package list,
# installs Nginx, restarts the service, and enables it to start on boot.

# Requirements:
# - The script must be executed with sudo privileges.

# Notes:
# - Ensure the system is updated before running this script.

# Usage:
#   sudo ./install-nginx.sh

# Download this script:
#   wget https://github.com/dalthonmh/scripts/blob/main/install-nginx.sh -O install-nginx.sh


echo "Installing Nginx..."
sudo apt update
sudo apt install nginx -y
sudo systemctl restart nginx
sudo systemctl enable nginx
echo "DONE"