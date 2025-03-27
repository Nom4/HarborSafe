#!/bin/bash

# Script de nettoyage post-installation Docker rootless + TLS

set -e

echo "🧼 Nettoyage des conteneurs, images, volumes non utilisés"
docker container prune -f
docker image prune -a -f
docker volume prune -f
docker network prune -f
docker system prune -a --volumes -f

echo "🧽 Suppression des conteneurs Portainer (si présents)"
docker rm -f portainer portainer_agent 2>/dev/null || true
docker volume rm portainer_data 2>/dev/null || true

echo "🧻 Nettoyage des fichiers intermédiaires de certificats"
rm -f ~/docker-certs/*.csr ~/docker-certs/*.srl ~/docker-certs/*.cnf

echo "📦 Archivage des certificats client"
mkdir -p ~/certs-client
cp ~/docker-certs/{cert.pem,key.pem,ca.pem} ~/certs-client/
cd ~/certs-client && zip -r docker-client-certs.zip cert.pem key.pem ca.pem

echo "🧨 Suppression des paquets utilisés uniquement à l’installation"
sudo apt purge -y ca-certificates curl gnupg lsb-release uidmap apparmor-utils jq openssl
sudo apt autoremove -y

echo "✅ Nettoyage terminé. Fichiers client TLS disponibles dans ~/certs-client/docker-client-certs.zip"
