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
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx curl

# Prepare the website directory
mkdir -p /var/www/html
rm -f /var/www/html/index.nginx-debian.html

# S3 bucket URL
S3_BASE_URL="https://praveen-devsecops-portfolio-2026-s3.s3.ap-south-1.amazonaws.com"

# Download the latest website files from S3
curl --retry 3 --retry-delay 5 -fSL \
    "$S3_BASE_URL/index.html" \
    -o /var/www/html/index.html

curl --retry 3 --retry-delay 5 -fSL \
    "$S3_BASE_URL/style.css" \
    -o /var/www/html/style.css

curl --retry 3 --retry-delay 5 -fSL \
    "$S3_BASE_URL/script.js" \
    -o /var/www/html/script.js

# Ensure the profile image loads directly from S3
sed -i \
    's|src="profile.jpg"|src="https://praveen-devsecops-portfolio-2026-s3.s3.ap-south-1.amazonaws.com/profile.jpg"|' \
    /var/www/html/index.html

# Set file ownership
chown -R www-data:www-data /var/www/html

# Enable and start Nginx
systemctl enable nginx
systemctl restart nginx

echo "Portfolio deployment from S3 completed successfully"