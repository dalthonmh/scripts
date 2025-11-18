#!/bin/bash
# install-docker.sh
# Created: 2025-04-11, dalthonmh
# Description:
# This script installs Docker on an Ubuntu server. It adds the Docker repository,
# installs the required dependencies, and sets up Docker to start on boot.

# Requirements:
# - The script must be executed with sudo privileges.

# Notes:
# - This script installs the Docker Community Edition (CE).
# - Ensure the system is updated before running this script.

# Usage:
#   sudo ./install-docker.sh

# Download this script:
#   wget https://github.com/dalthonmh/scripts/blob/main/install-docker.sh -O install-docker.sh


echo "👉 Installing Docker"
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -y update
sudo apt-get -y install docker-ce
sudo systemctl start docker
sudo systemctl enable docker