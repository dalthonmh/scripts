#!/bin/bash
# install-https.sh
# Created: 2025-04-21, dalthonmh
# Description:
# This script installs HTTPS on an Ubuntu server using Certbot and Nginx.
# It verifies the installation of Nginx, installs Certbot, and generates an SSL certificate.

# Requirements:
# - Nginx must be installed on the server.
# - The script must be executed with sudo privileges.

# Notes:
# - Ensure the domain name is correctly configured and points to the server's IP address.
# - Certbot will automatically configure Nginx for HTTPS.

# Usage:
#   sudo ./install-https.sh <domain> <email>
# Example:
#   sudo ./install-https.sh example.com admin@example.com

# Download this script:
#   wget https://github.com/dalthonmh/scripts/blob/main/install-https.sh -O install-https.sh

# Parameters
DOMAIN=${1:-'domain'}
EMAIL=${2:-'email'}

# Validate domain and email parameters
if [ "$DOMAIN" = "domain" ] || [ "$EMAIL" = "email" ]; then
    echo "Missing parameters."
    echo "Usage: ./install-https.sh <domain> <email>"
    echo "Example: ./install-https.sh example.com admin@example.com"
    exit 1
fi

# Verify Nginx installation
if ! command -v nginx &> /dev/null; then
    echo "Nginx is not installed. Install it with: sudo apt install nginx"
    exit 1
fi

# Update and install Certbot
sudo apt update
sudo apt install -y snapd
sudo snap install core; sudo snap refresh core
sudo apt-get remove certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Run Certbot to generate SSL certificate
if sudo certbot --nginx -d "$DOMAIN" -d "www.$DOMAIN" \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    --non-interactive; then
    echo "SSL certificate successfully installed for $DOMAIN"
else
    echo "Failed to install SSL certificate"
    exit 1
fi