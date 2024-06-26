#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Bitte führe das Skript als Root-Benutzer aus"
  exit 1
fi

# Add PHP repository
sudo add-apt-repository -y ppa:ondrej/php

# Update package list
sudo apt update

# Install PHP and necessary extensions
sudo apt install -y php8.3 php8.3-gd php8.3-mysql php8.3-mbstring php8.3-bcmath php8.3-xml php8.3-curl php8.3-zip php8.3-intl php8.3-sqlite3 php8.3-fpm

# Install MySQL server
sudo apt install -y mysql-server

# Install other required packages
sudo apt install -y curl tar nginx

# Install Composer v2
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# Create directory for Pelican
mkdir -p /var/www/pelican

# Change to the Pelican directory
cd /var/www/pelican

# Download the latest release of the panel
curl -Lo panel.tar.gz https://github.com/pelican-dev/panel/releases/latest/download/panel.tar.gz

# Extract the downloaded tar.gz file
tar -xzvf panel.tar.gz

# Set the correct permissions
chmod -R 755 storage/* bootstrap/cache/

# Install PHP dependencies using Composer
sudo composer install --no-dev --optimize-autoloader

# Run the Pelican setup commands
php artisan p:environment:setup
php artisan p:environment:database
php artisan migrate --seed --force
php artisan p:user:make

# Set up the cron job for www-data user
(crontab -u www-data -l 2>/dev/null; echo "* * * * * php /var/www/pelican/artisan schedule:run >> /dev/null 2>&1") | crontab -u www-data -

# Change ownership of the Pelican directory to www-data
chown -R www-data:www-data /var/www/pelican

# Remove the default NGINX site configuration
rm /etc/nginx/sites-enabled/default

# Create the Pelican NGINX configuration
cat <<EOL > /etc/nginx/sites-available/pelican.conf
server_tokens off;

server {
    listen 80;
    server_name panel.project-zeta.de;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name panel.project-zeta.de;

    root /var/www/pelican/public;
    index index.php;

    access_log /var/log/nginx/pelican.app-access.log;
    error_log  /var/log/nginx/pelican.app-error.log error;

    # allow larger file uploads and longer script runtimes
    client_max_body_size 100m;
    client_body_timeout 120s;

    sendfile off;

    ssl_certificate /etc/letsencrypt/live/panel.project-zeta.de/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/panel.project-zeta.de/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
    ssl_prefer_server_ciphers on;

    # See https://hstspreload.org/ before uncommenting the line below.
    # add_header Strict-Transport-Security "max-age=15768000; preload;";
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header Content-Security-Policy "frame-ancestors 'self'";
    add_header X-Frame-Options DENY;
    add_header Referrer-Policy same-origin;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        include /etc/nginx/fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL

# Enable the Pelican NGINX site configuration
sudo ln -s /etc/nginx/sites-available/pelican.conf /etc/nginx/sites-enabled/pelican.conf

# Restart NGINX to apply the changes
sudo systemctl restart nginx

echo "Pelican Panel Installation abgeschlossen"
