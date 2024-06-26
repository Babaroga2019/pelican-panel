if [ "$EUID" -ne 0 ]; then
  echo "Bitte führe das Skript als Root-Benutzer aus"
  exit 1
fi

sudo apt install -y python3-certbot-nginx

certbot certonly --nginx -d panel.project-zeta.de

certbot certonly --nginx -d wings.project-zeta.de
