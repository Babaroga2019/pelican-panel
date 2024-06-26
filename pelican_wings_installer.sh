#!/bin/bash

# Prüfen, ob das Skript als Root-Benutzer ausgeführt wird
if [ "$EUID" -ne 0 ]; then
  echo "Bitte führe das Skript als Root-Benutzer aus"
  exit 1
fi

# System-Hersteller anzeigen
sudo dmidecode -s system-manufacturer

# Docker installieren
curl -sSL https://get.docker.com/ | CHANNEL=stable sh

# Docker-Dienst aktivieren und starten
sudo systemctl enable --now docker

# Swap Accounting aktivieren
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="swapaccount=1 /' /etc/default/grub
sudo update-grub

# Verzeichnisse erstellen
sudo mkdir -p /etc/pelican /var/run/wings

# Wings herunterladen
curl -L -o /usr/local/bin/wings "https://github.com/pelican-dev/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"

# Berechtigungen setzen
sudo chmod u+x /usr/local/bin/wings

# Systemd-Dienst für Wings erstellen
cat <<EOL | sudo tee /etc/systemd/system/wings.service
[Unit]
Description=Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service

[Service]
User=root
WorkingDirectory=/etc/pelican
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOL

# Wings-Dienst aktivieren und starten
sudo systemctl enable --now wings
