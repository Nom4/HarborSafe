# HarborSafe

<p align="center"><img src="https://github.com/Nom4/HarborSafe/blob/main/HarborSafe_logo.png?raw=true" width="250" height="250" alt="HarborSafe Logo"></p>

**HarborSafe** est un projet d’installation automatisée d’un environnement Docker rootless sécurisé avec TLS, géré via Portainer Business Edition.

## 📦 Contenu

- `scripts/proxmox_install_projet_HarborSafe.sh` – Script principal d’installation sur environnement ProxMox
- `scripts/vsphere_install_projet_HarborSafe.sh` – Script principal d’installation sur environnement vSphere
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
```

## 🔍 Scan Nessus
Le but de se projet est de simplifier le déploiement et la mise en service d'un stack Docker sécurisé et le plus safe possible.
Dans ce cadre, le fait de scanner le déploiement avec un outil comme Nessus me paraissait important.
Le résultat du dernier scan sur les ports 22, 2376, 9443 ressort un résultat de :

- 0 Critical
- 0 High
- 2 Medium
- 0 Low
- 56 Info

Les 2 mediums correspondent à : 51192 - SSL Certificate Cannot Be Trusted sur les ports exposé 2376 (Docker API TLS) et 9443 (Portainer HTTPS).

## 🔐 Utilisation de certificats autosignés dans HarborSafe
Dans le cadre d’un déploiement HarborSafe en environnement sécurisé, les services critiques comme Docker TLS (2376) et Portainer BE (9443) sont protégés par des certificats TLS autosignés.

Ce choix est pleinement justifié par les caractéristiques suivantes :

- L’environnement fonctionne sur un réseau interne non exposé à Internet ;
- L’accès aux ports sensibles est filtré par UFW, par VLAN ou firewall centralisé ;
- Les certificats TLS garantissent le chiffrement des communications, même s’ils ne sont pas émis par une autorité publique ;
- Les clients autorisés (ex. : administrateurs, Portainer Manager) sont maîtrisés et configurés avec la bonne autorité (ca.pem) ;
- Des outils de vulnérabilité comme Nessus sont régulièrement utilisés pour détecter toute dérive ou faille résiduelle.

## ✅ Recommandations complémentaires
Pour maintenir un bon niveau de sécurité opérationnelle :

- Documenter l’usage de certificats autosignés et le processus d’import de la ca.pem sur les clients autorisés ;
- Conserver les certificats TLS dans un répertoire sécurisé (/etc/docker/certs/ et /opt/portainer/certs/) avec des droits restreints ;
- Limiter la durée de validité des certificats à 180 ou 365 jours, et intégrer leur rotation dans le plan de maintenance ;
- Contrôler que seul un sous-réseau spécifique (ex. : 10.0.0.0/24) voir qu'un seul range d'IP ait accès aux ports 2376 et 9443 ;
- Ne jamais exposer ces ports directement à Internet sans reverse proxy ou tunnel chiffré en amont.

## 🧼 Suppression ou clean du host
En cas d'installation infructueuse, de problèmes de package ou autre, le script "cleanup_HarborSafe.sh" permet de revenir à un état post-install.
A noter qu'un snapshot sera toujours plus prudent.

```bash
cd scripts
chmod +x cleanup_HarborSafe.sh
sudo ./cleanup_HarborSafe.sh
```

## 📄 License

MIT – Utilisation libre et partage encouragé.
