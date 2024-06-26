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
sudo apt install -y curl tar

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

echo "Pelican Panel Installation abgeschlossen"
