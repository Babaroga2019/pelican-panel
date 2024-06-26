if [ "$EUID" -ne 0 ]; then
  echo "Bitte führe das Skript als Root-Benutzer aus"
  exit 1
fi

sudo dmidecode -s system-manufacturer

curl -sSL https://get.docker.com/ | CHANNEL=stable sh

sudo systemctl enable --now docker

GRUB_CMDLINE_LINUX_DEFAULT="swapaccount=1"

sudo mkdir -p /etc/pelican /var/run/wings

curl -L -o /usr/local/bin/wings "https://github.com/pelican-dev/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"

sudo chmod u+x /usr/local/bin/wings

cat <<EOL > /etc/systemd/system/wings.service
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

systemctl enable --now wings
