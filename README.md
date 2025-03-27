
![HarborSafe_badge](https://github.com/user-attachments/assets/ce9820d2-bbec-4fdf-a08c-449256b926bc)

**HarborSafe** est un projet d’installation automatisée d’un environnement Docker rootless sécurisé avec TLS, géré via Portainer Business Edition.

## 📦 Contenu

- `scripts/install_projet_HarborSafe.sh` – Script principal d’installation
- `scripts/cleanup_HarborSafe.sh` – Script de nettoyage post-déploiement
- `docs/checklist_HarborSafe.md` – Documentation complète en Markdown
- `docs/HarborSafe_Checklist.pdf` – Version PDF de la checklist

## 🚀 Fonctionnalités

- Docker CE en mode rootless
- Sécurisation via TLS avec certificats auto-signés
- Configuration `daemon.json` renforcée
- Portainer BE déployé en HTTPS
- API Docker exposée sur port `2376` en TLS
- UFW configuré automatiquement
- Export des certificats client pour Portainer

## 📥 Utilisation

```bash
cd scripts
chmod +x install_projet_HarborSafe.sh cleanup_HarborSafe.sh
sudo ./install_projet_HarborSafe.sh
# Après installation
./cleanup_HarborSafe.sh
```

## 📄 License

MIT – Utilisation libre et partage encouragé.

## 💡 Mot de l'auteur

Aucune prétention, uniquement un petit projet perso afin de bien comprendre comment automatiser le déploiement d'un stack Docker x Portainer sur Ubuntu Server 24.04 avec les fonctionnalité rootless, apparmor et sécurisation.
En cours de vulscan avec Nessus.
