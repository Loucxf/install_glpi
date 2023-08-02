#!/bin/bash

# Vérification des privilèges d'administration (root)
if [ "$EUID" -ne 0 ]; then
    echo "Ce script doit être exécuté en tant qu'administrateur (root)."
    exit 1
fi

# Installation de MariaDB
apt update
apt install -y mariadb-server apache2
apt install perl -y
apt install php-ldap php-imap php-apcu php-xmlrpc php-cas php-mysqli php-mbstring php-curl php-gd php-simplexml php-xml php-intl php-zip php-bz2 -y

# Vérification de l'état de MariaDB
if ! systemctl is-active --quiet mariadb; then
    echo "Une erreur s'est produite lors de la configuration sécurisée de MariaDB."
    exit 1
fi

# Demande à l'utilisateur de créer un nouvel utilisateur et une nouvelle base de données
read -p "Entrez le nom du nouvel utilisateur : " new_user
read -sp "Entrez le mot de passe du nouvel utilisateur : " new_user_password
echo ""
read -p "Entrez le nom de la nouvelle base de données : " new_database

# Création du nouvel utilisateur et de la nouvelle base de données
mysql -uroot -pChangeMe<<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS $new_database;
CREATE USER '$new_user'@'localhost' IDENTIFIED BY '$new_user_password';
GRANT ALL PRIVILEGES ON $new_database.* TO '$new_user'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "Le nouvel utilisateur '$new_user' et la nouvelle base de données '$new_database' ont été créés avec succès."

systemctl reload apache2

cd /tmp/
wget https://github.com/glpi-project/glpi/releases/download/10.0.0/glpi-10.0.0.tgz

tar xzf glpi-10.0.0.tgz -C /var/www/html

chown -R www-data:www-data /home/var/www/glpi
chmod -R 775 /home/var/www/glpi

server_ip=$(hostname -I | awk '{print $1}')

echo "Adresse IP du GLPI : $server_ip/glpi"

