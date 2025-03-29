# Checklist – Installation d’un environnement Docker sécurisé avec Portainer BE
#                  _                __        __      
  /\  /\__ _ _ __| |__   ___  _ __/ _\ __ _ / _| ___ 
 / /_/ / _` | '__| '_ \ / _ \| '__\ \ / _` | |_ / _ \
/ __  / (_| | |  | |_) | (_) | |  _\ \ (_| |  _|  __/
\/ /_/ \__,_|_|  |_.__/ \___/|_|  \__/\__,_|_|  \___|
                                                     
# ==============================================
#   🚢 HarborSafe – Secure Docker Rootless Stack
#   🔐 TLS + Portainer BE + UFW + userns-remap
#   ✅ Checklist MarkDown
#   🛠️  Script : install_projet_HarborSafe.sh
#   📅  Date   : 2025-03-27
#   🧑‍💻 Author : LLE
# ==============================================


---

## 🔎 Objectif

Déployer une stack Docker rootless, sécurisée via TLS, et managée par Portainer Business Edition, avec un accès sécurisé à l’API Docker (TCP 2376).

---

## ⚙️ Prérequis
```bash
sudo apt update && apt upgrade -y

hostnamectl hostname SERVERNAME
hostname

sudo nano /etc/netplan/00-installer-config.yaml
```
Y entrer :
```bash
network:
  version: 2
  ethernets:
    ens18:
      dhcp4: false
      addresses:
        - 192.168.68.54/24
      routes:
        - to: default
          via: 192.168.68.1
      nameservers:
        addresses: [192.168.68.110, 8.8.8.8]
```
Puis
```bash
sudo chmod 600 /etc/netplan/00-installer-config.yaml
sudo chown root:root /etc/netplan/00-installer-config.yaml
sudo netplan apply
```
```bash
sudo passwd root

sudo apt update
sudo apt install -y git nano iputils-ping netcat-openbsd

cd /
cd /tmp/
git clone https://github.com/Nom4/HarborSafe.git
```

## ⚙️ Étapes de déploiement

### 1. Créer / éditer le script principal

```bash
nano install_docker_tls_secure_with_client_cert.sh
```

### 2. Rendre le script exécutable

```bash
chmod +x install_docker_tls_secure_with_client_cert.sh
```

### 3. Exécuter le script

```bash
sudo ./install_docker_tls_secure_with_client_cert.sh
```

---

## 🛠 Étapes réalisées par le script

- 🔧 Mise à jour des paquets
- 🐳 Installation de Docker CE
- 📁 Création du dossier de certificats
- 🔐 Génération de la CA + certificat serveur
- 🔐 Génération du certificat client
- 📦 Déplacement des certificats serveur dans `/etc/docker/certs/`
- ⚙️ Configuration sécurisée du `daemon.json`
- 🛠 Configuration systemd pour activer l’écoute TCP (`2376`)
- 🔄 Redémarrage propre de Docker
- 🧱 Configuration UFW : SSH, Portainer, Docker TLS
- ⚙️ Préparation des variables et chemins pour Portainer
- 📁 Création des dossiers `/opt/portainer/certs` et `/opt/portainer/license`
- 🧼 Suppression de l'ancien conteneur Portainer (s'il existe)
- 🔐 Déploiement de Portainer BE avec SSL (port 9443)

---

## 📤 Étapes post-script

### 4. Export automatique des certificats client

À la fin du script, les certificats `cert.pem`, `key.pem`, et `ca.pem` sont automatiquement copiés vers `/tmp/certs` avec les bons droits pour être téléchargés via **WinSCP**.

📥 Tu peux maintenant récupérer ces fichiers (`ca.pem`, `cert.pem`, `key.pem`) via **WinSCP**  
et les utiliser pour connecter l’instance Docker via TLS sécurisé.

---

## ✅ Prochaines étapes recommandées

- 🔐 Se connecter à Portainer BE : `https://<IP>:9443`
- ➕ Ajouter un environnement Docker via :
  - Type : *Docker Standalone*
  - URL : `tcp://127.0.0.1:2376`
  - Mode : *TLS*
  - Certificats : `ca.pem`, `cert.pem`, `key.pem`

---

💡 *Penser à supprimer le dossier `/tmp/certs` une fois les fichiers transférés.*
