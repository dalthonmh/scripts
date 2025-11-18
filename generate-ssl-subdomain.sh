#!/bin/bash
# generate-ssl-subdomain.sh
# Created: 2025-08-10, dalthonmh
# Description:
# This script generates an SSL certificate for a subdomain using Certbot and configures Nginx.
# It creates the necessary Nginx configuration file, enables the site, and reloads Nginx.

# Requirements:
# - Nginx must be installed and properly configured.
# - Certbot must be installed on the system.

# Notes:
# - Ensure you have sudo privileges to execute this script.
# - The script assumes the SSL certificates will be stored in the default Certbot directory.

# Usage:
#  sudo ./generate-ssl-subdomain.sh <subdomain> <domain> <port>
# Example:
#  sudo ./generate-ssl-subdomain.sh backend.espg beledev.com 83

# Download this script:
#  wget https://github.com/dalthonmh/scripts/blob/main/generate-ssl-subdomain.sh -O generate-ssl-subdomain.sh


# Variables
SUBDOMAIN="$1"
DOMAIN="$2"
PORT="$3"
FULL_DOMAIN="$SUBDOMAIN.$DOMAIN"

# Validate parameters
if [ -z "$SUBDOMAIN" ] || [ -z "$DOMAIN" ] || [ -z "$PORT" ]; then
    echo "Missing parameters."
    echo "Usage: $0 <subdomain> <domain> <port>"
    echo "Example: $0 backend.espg beledev.com 83"
    exit 1
fi

# Generate Nginx configuration file
echo "👉 Generating configuration file in /etc/nginx/sites-available"

cat << 'EOF' > /etc/nginx/sites-available/$FULL_DOMAIN
server {
    listen 80;
    server_name __FULL_DOMAIN__;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name __FULL_DOMAIN__;

    location / {
        proxy_pass http://localhost:__PORT__;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    ssl_certificate /etc/letsencrypt/live/__DOMAIN__/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/__DOMAIN__/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}
EOF

# Replace placeholders in the configuration file
sed -i "s|__PORT__|$PORT|g" /etc/nginx/sites-available/$FULL_DOMAIN
sed -i "s|__FULL_DOMAIN__|$FULL_DOMAIN|g" /etc/nginx/sites-available/$FULL_DOMAIN
sed -i "s|__DOMAIN__|$DOMAIN|g" /etc/nginx/sites-available/$FULL_DOMAIN

# Enable symbolic links
echo "👉 Enabling symbolic links"
sudo ln -sf /etc/nginx/sites-available/$FULL_DOMAIN /etc/nginx/sites-enabled/

# Verify Nginx configuration
echo "👉 Verifying Nginx configuration"
sudo nginx -t
if [ $? -eq 0 ]; then
    echo "[OK] Nginx configuration is correct, reloading..."
    sudo systemctl reload nginx
else
    echo "[ERROR] Nginx configuration error"
    exit 1
fi

# Request SSL certificate
echo "👉 Requesting SSL certificate for $FULL_DOMAIN"
sudo certbot --nginx -d $FULL_DOMAIN

# Restart Nginx
echo "👉 Restarting Nginx"
sudo systemctl restart nginx
