#!/bin/bash

#                  _                __        __      
#   /\  /\__ _ _ __| |__   ___  _ __/ _\ __ _ / _| ___ 
#  / /_/ / _` | '__| '_ \ / _ \| '__\ \ / _` | |_ / _ \
# / __  / (_| | |  | |_) | (_) | |  _\ \ (_| |  _|  __/
# \/ /_/ \__,_|_|  |_.__/ \___/|_|  \__/\__,_|_|  \___|
#                                                     
# ==============================================
#   🚢 HarborSafe – Secure Docker Rootless Stack
#   🔐 TLS + Portainer BE + UFW + userns-remap
#   🛠️  Script : vsphere_install_projet_HarborSafe.sh
#   📅  Date   : 2025-03-28
#   🧑‍💻 Author : LLE
# ==============================================

# Script d'installation sécurisée de Docker avec TLS + userns + journald + client cert (Ubuntu 24.04)

set -e

echo "🔧 Mise à jour des paquets"
sudo apt update && sudo apt install -y \
  ca-certificates curl gnupg lsb-release \
  uidmap apparmor-utils jq openssl

echo "🐳 Installation de Docker CE"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "📁 Création du dossier de certificats"
mkdir -p ~/docker-certs && cd ~/docker-certs

echo "🔐 Génération CA + Certificat serveur"
openssl genrsa -out ca-key.pem 4096
openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem -subj "/CN=MyDockerCA"

openssl genrsa -out server-key.pem 4096
openssl req -subj "/CN=$(hostname)" -new -key server-key.pem -out server.csr

echo subjectAltName = IP:127.0.0.1,IP:$(hostname -I | awk '{print $1}'),DNS:localhost > extfile.cnf
echo extendedKeyUsage = serverAuth >> extfile.cnf

openssl x509 -req -days 365 -sha256 -in server.csr \
  -CA ca.pem -CAkey ca-key.pem -CAcreateserial \
  -out server-cert.pem -extfile extfile.cnf


echo "🔐 Génération certificat client"
CERT_DIR=~/docker-certs
OUTPUT_DIR=/tmp/certs_client

echo "📁 Création du dossier de sortie"
mkdir -p $OUTPUT_DIR

echo "🔐 Génération de la clé privée du client"
openssl genrsa -out $OUTPUT_DIR/key.pem 4096

echo "🔐 Création du certificat signing request (CSR)"
openssl req -new -key $OUTPUT_DIR/key.pem -out $OUTPUT_DIR/client.csr -subj "/CN=client"

echo "🔐 Signature du certificat avec la CA locale"
echo extendedKeyUsage = clientAuth > $OUTPUT_DIR/extfile-client.cnf

openssl x509 -req -days 365 -sha256 -in $OUTPUT_DIR/client.csr \
  -CA $CERT_DIR/ca.pem -CAkey $CERT_DIR/ca-key.pem -CAcreateserial \
  -out $OUTPUT_DIR/cert.pem -extfile $OUTPUT_DIR/extfile-client.cnf

echo "🔒 Application des permissions"
chmod 600 $OUTPUT_DIR/key.pem $OUTPUT_DIR/cert.pem
cp $CERT_DIR/ca.pem $OUTPUT_DIR/
chown -R uadm:uadm $OUTPUT_DIR

echo "✅ Certificats client TLS générés dans : $OUTPUT_DIR"
echo "➡️  Fichiers : cert.pem, key.pem, ca.pem"

echo "📦 Déplacement des certifs serveur"
sudo mkdir -p /etc/docker/certs
sudo cp ca.pem server-cert.pem server-key.pem /etc/docker/certs/
sudo chmod 600 /etc/docker/certs/*.pem

echo "⚙️ Création de daemon.json sécurisé"
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "tls": true,
  "tlsverify": true,
  "tlscacert": "/etc/docker/certs/ca.pem",
  "tlscert": "/etc/docker/certs/server-cert.pem",
  "tlskey": "/etc/docker/certs/server-key.pem",
  "log-driver": "journald",
  "icc": false,
  "live-restore": true,
  "no-new-privileges": true
}
EOF

echo "🛠 Configuration systemd pour TCP 2376"
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/override.conf > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2376
EOF

echo "🔄 Redémarrage de Docker"
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl restart docker

echo "🧱 Configuration UFW"
sudo apt install -y ufw
sudo ufw allow OpenSSH
sudo ufw allow 9443/tcp comment "Portainer HTTPS"
# A remplacer par le range ou l'adresse IP source
sudo ufw allow from 192.168.68.0/24 to any port 2376 proto tcp comment "Docker API TLS"
sudo ufw limit OpenSSH
yes | sudo ufw enable
sudo ufw status numbered

echo "✅ Docker TLS + certificats client prêts. Utilisez cert.pem / key.pem / ca.pem pour la connexion sécurisée."

# Installation de Portainer BE pour Docker rootless avec connexion TLS locale

set -e

CERT_SRC=~/docker-certs
CERT_DST=/opt/portainer/certs
LICENSE_PATH=/opt/portainer/license

echo "📁 Préparation des dossiers Portainer"
sudo mkdir -p $CERT_DST $LICENSE_PATH
sudo cp $CERT_SRC/server-cert.pem $CERT_DST/portainer.crt
sudo cp $CERT_SRC/server-key.pem $CERT_DST/portainer.key
sudo chmod 644 $CERT_DST/*

if [ -f "$LICENSE_PATH/license" ]; then
  echo "✅ Licence Portainer BE détectée"
else
  echo "⚠️  Licence absente. Placez-la dans /opt/portainer/license/license si nécessaire."
fi

echo "🧼 Nettoyage ancien conteneur Portainer (si présent)"
docker rm -f portainer 2>/dev/null || true
docker volume rm portainer_data 2>/dev/null || true
docker volume create portainer_data

echo "🔐 Déploiement Portainer BE (Docker rootless, accès via TLS)"
docker run -d \
  --name portainer \
  --restart always \
  --net host \
  -v portainer_data:/data \
  -v $CERT_DST:/certs \
  -v $LICENSE_PATH:/license \
  portainer/portainer-ee:latest \
  --ssl \
  --sslcert /certs/portainer.crt \
  --sslkey /certs/portainer.key

echo "✅ Portainer BE lancé sur https://$(hostname -I | awk '{print $1}'):9443"
echo "➡️ Connectez-vous, puis ajoutez un environnement Docker en mode 'TLS'"
echo "   URL : tcp://127.0.0.1:2376"
echo "   Certificats : cert.pem / key.pem / ca.pem"



echo "📤 Préparation des certificats client pour Portainer"
mkdir -p /tmp/certs
cp /tmp/certs_client/{cert.pem,key.pem,ca.pem} /tmp/certs/
# A remplacer par le compte utilisateur en vigueur
chown -R uadm:uadm /tmp/certs
chmod -R u=rwX,go=rX /tmp/certs

echo "📦 Certificats client disponibles dans /tmp/certs pour import Portainer (via WinSCP ou navigateur)"

echo "📦 Certificats client disponibles dans /tmp/certs pour import Portainer (via WinSCP ou navigateur)"
