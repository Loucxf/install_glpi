#!/bin/bash

# Vérification des privilèges d'administration (root)
if [ "$EUID" -ne 0 ]; then
    echo "Ce script doit être exécuté en tant qu'administrateur (root)."
    exit 1
fi

# Mise à jour des paquets
apt update

# Installation d'Apache
apt install -y apache2 mariadb-server php
