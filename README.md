# Checklist – Installation d’un environnement Docker sécurisé avec Portainer BE
#                  _                __        __      
  /\  /\__ _ _ __| |__   ___  _ __/ _\ __ _ / _| ___ 
 / /_/ / _` | '__| '_ \ / _ \| '__\ \ / _` | |_ / _ \
/ __  / (_| | |  | |_) | (_) | |  _\ \ (_| |  _|  __/
\/ /_/ \__,_|_|  |_.__/ \___/|_|  \__/\__,_|_|  \___|
                                                     
# ==============================================
#   🚢 HarborSafe – Secure Docker Rootless Stack
#   🔐 TLS + Portainer BE + UFW + userns-remap
#   🛠️  Script : install_projet_HarborSafe.sh
#   📅  Date   : 2025-03-27
#   🧑‍💻 Author : LLE
# ==============================================


---

## 🔎 Objectif

Déployer une stack Docker rootless, sécurisée via TLS, et managée par Portainer Business Edition, avec un accès sécurisé à l’API Docker (TCP 2376).

---

## ⚙️ Étapes de déploiement

### 1. Créer / éditer le script principal

```bash
sudo nano install_HarborSafe.sh
```

### 2. Rendre le script exécutable

```bash
sudo chmod +x install_HarborSafe.sh
```

### 3. Exécuter le script

```bash
sudo ./install_HarborSafe.sh
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
- 📤 Préparation des certificats client pour Portainer

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

## 🧹 Nettoyage post-déploiement

Une fois l'environnement HarborSafe fonctionnel et les certificats exportés, il est recommandé d'exécuter un script de nettoyage pour :

- Supprimer les conteneurs et volumes non utilisés
- Archiver les certificats client
- Supprimer les fichiers temporaires de génération de certificats
- Supprimer les paquets utilisés uniquement pour l'installation

### ✅ Script de nettoyage : `cleanup_HarborSafe.sh`

### 1. Créer / éditer le script principal

```bash
sudo nano cleanup_HarborSafe.sh
```

### 2. Rendre le script exécutable

```bash
sudo chmod +x cleanup_HarborSafe.sh
```

### 3. Exécuter le script

```bash
sudo ./cleanup_HarborSafe.sh
```

Ce script :
- Supprime conteneurs/images/volumes inutilisés
- Nettoie les CSR/SRL/temps
- Crée une archive `~/certs-client/docker-client-certs.zip`
- Purge les paquets : `ca-certificates`, `curl`, `gnupg`, etc.

📍 *Pensez à récupérer vos certificats client avant de les supprimer définitivement.*
