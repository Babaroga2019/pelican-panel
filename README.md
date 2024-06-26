# Pelican Panel Installer

Dieses Skript installiert und konfiguriert das Pelican Panel auf einem Ubuntu-Server. Es beinhaltet die Installation von PHP, MySQL, Composer und NGINX sowie die Konfiguration des Webservers.

## Voraussetzungen

Stellen Sie sicher, dass Sie die folgenden Voraussetzungen erfüllen:
- Ein Ubuntu-Server (getestet mit Ubuntu 24.04/22.04)
- Root-Zugriff auf den Server
- Eine gültige Domain (z.B. `panel.project-zeta.de`)
- SSL-Zertifikate für Ihre Domain (können mit Let's Encrypt erstellt werden)

## Installationsanleitung

[WARNUNG] Wenn sie eine Domain mit https:// verwenden müssen sie vorher sie vorher SSL Certificate erstellen:

1. Klonen Sie dieses Repository oder kopieren Sie das Skript auf Ihren Server.

    ```bash
    wget https://raw.githubusercontent.com/Babaroga2019/pelican-panel/main/ssl_certificate.sh
    ```

2. Machen Sie das Skript ausführbar:

    ```bash
    chmod +x ssl_certificate.sh
    ```

3. Führen Sie das Skript als Root-Benutzer aus:

    ```bash
    sudo ./ssl_certificate.sh
    ```

[Panel Installer]

1. Klonen Sie dieses Repository oder kopieren Sie das Skript auf Ihren Server.

    ```bash
    wget https://raw.githubusercontent.com/Babaroga2019/pelican-panel/main/pelican_panel_installer.sh
    ```

2. Machen Sie das Skript ausführbar:

    ```bash
    chmod +x pelican_panel_installer.sh
    ```

3. Führen Sie das Skript als Root-Benutzer aus:

    ```bash
    sudo ./pelican_panel_installer.sh
    ```

Das Skript führt die folgenden Schritte automatisch aus:

1. Fügt das PHP PPA-Repository hinzu.
2. Aktualisiert die Paketliste.
3. Installiert PHP 8.3 und die erforderlichen PHP-Erweiterungen, MySQL-Server, Curl, Tar und NGINX.
4. Installiert Composer v2.
5. Erstellt das Verzeichnis `/var/www/pelican` und wechselt in dieses Verzeichnis.
6. Lädt die neueste Version des Pelican Panels herunter und entpackt sie.
7. Setzt die richtigen Berechtigungen für die Verzeichnisse `storage` und `bootstrap/cache`.
8. Installiert die PHP-Abhängigkeiten mit Composer.
9. Führt die Pelican-Setup-Befehle aus (`p:environment:setup`, `p:environment:database`, `migrate --seed --force`, `p:user:make`).
10. Richtet einen Cron-Job für den Benutzer `www-data` ein, um geplante Aufgaben auszuführen.
11. Ändert den Besitzer des Verzeichnisses `/var/www/pelican` zu `www-data`.
12. Entfernt die Standard-NGINX-Site-Konfiguration.
13. Erstellt die NGINX-Site-Konfigurationsdatei `/etc/nginx/sites-available/pelican.conf`.
14. Aktiviert die neue NGINX-Site-Konfiguration durch Erstellung eines symbolischen Links.
15. Startet NGINX neu, um die Änderungen zu übernehmen.

## Wings Installation

1. Klonen Sie dieses Repository oder kopieren Sie das Skript auf Ihren Server.

    ```bash
    wget https://raw.githubusercontent.com/Babaroga2019/pelican-panel/main/pelican_wings_installer.sh
    ```

2. Machen Sie das Skript ausführbar:

    ```bash
    chmod +x pelican_wings_installer.sh
    ```

3. Führen Sie das Skript als Root-Benutzer aus:

    ```bash
    sudo ./pelican_wings_installer.sh

[Konfiguration]
Damit die Wings vollständig laufen müssen sie selber noch die Wings Konfigurieren.
Gehen sie dafür auf die Website des Panels und erstellen sie ein neues Node.
In dem Tab des nodes sollte ein weiterer Tab zu finden sein namens Configuration File.
Kopieren sie diese File in das verzeichnis /etc/pelican/config.yml

Das Skript führt die folgenden Schritte automatisch aus:

1. Überprüft den Provider.
2. Installiert Docker.
3. Startet Docker.
4. Aktiviert SWAP.
5. Erstellt das Verzeichnis `/var/run/wings`.
6. Installiert Wings.
7. Setzt die richtigen Berechtigungen
8. Installiert die PHP-Abhängigkeiten mit Composer.
9. Fügt eine System-Routine ein zum Starten von den Wings.
