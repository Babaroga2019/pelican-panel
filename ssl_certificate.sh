#!/bin/bash

# Prüfen, ob das Skript als Root-Benutzer ausgeführt wird
if [ "$EUID" -ne 0 ]; then
  echo "Bitte führe das Skript als Root-Benutzer aus"
  exit 1
fi

# Domain für Panel abfragen
read -p "Bitte gib die Domain für das Panel an (z.B. panel.project-zeta.de): " PANEL_DOMAIN

# Domain für Wings abfragen
read -p "Bitte gib die Domain für Wings an (z.B. wings.project-zeta.de): " WINGS_DOMAIN

# Certbot und Nginx installieren
sudo apt install -y python3-certbot-nginx

# Zertifikate für die angegebenen Domains erstellen
sudo certbot certonly --nginx -d "$PANEL_DOMAIN"
sudo certbot certonly --nginx -d "$WINGS_DOMAIN"
