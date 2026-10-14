#!/bin/bash
set -euxo pipefail

# Log all script output for troubleshooting
exec > >(tee -a /var/log/user-data-deployment.log) 2>&1

# Update package indexes, retrying temporary failures
for attempt in 1 2 3; do
    if apt-get update -y; then
        break
    fi

    if [ "$attempt" -eq 3 ]; then
        echo "ERROR: apt-get update failed after 3 attempts"
        exit 1
    fi

    sleep 10
done

# Install required packages
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx git

# Prepare the website directory
mkdir -p /var/www/html
rm -f /var/www/html/index.nginx-debian.html

# Clone the portfolio repository
if [ ! -d /opt/portfolio/.git ]; then
    git clone https://github.com/praveen520310/Paul-Praveen-devsecops-portfolio.git /opt/portfolio
fi

# Copy website files to Nginx's document root
cp -a /opt/portfolio/. /var/www/html/

# Set file ownership
chown -R www-data:www-data /var/www/html

# Enable and start Nginx
systemctl enable nginx
systemctl restart nginx

echo "Portfolio deployment completed successfully"