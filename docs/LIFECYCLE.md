# 🔄 Cycle de vie lm-cli

Documentation complète pour gérer l'installation, la mise à jour et la désinstallation de lm-cli.

---

## 📋 Table des matières

- [Installation](#-installation)
- [Mise à jour](#-mise-à-jour)
- [Gestion des versions](#-gestion-des-versions)
- [Désinstallation](#-désinstallation)
- [Réinstallation](#-réinstallation)
- [Sauvegarde et restauration](#-sauvegarde-et-restauration)

---

## 📦 Installation

### Installation initiale

#### Installation automatique (Recommandé)

**Linux / macOS / WSL** :
```bash
curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash
```

**Windows PowerShell** :
```powershell
irm https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.ps1 | iex
```

#### Installation d'une version spécifique

```bash
# Installer la version 1.2.5
curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash -s -- -v v1.2.5
```

#### Installation manuelle

Consultez le [guide d'installation complet](INSTALLATION.md#-installation-manuelle).

---

### Vérification post-installation

```bash
# Vérifier la version installée
lm version

# Afficher l'aide
lm --help

# Tester dans un projet Spring Boot
cd /chemin/vers/mon-projet
lm create --help
```

---

## 🔄 Mise à jour

### Mise à jour automatique

```bash
lm update
```

Cette commande :
1. ✅ Détecte la dernière version disponible
2. ✅ Sauvegarde la version actuelle
3. ✅ Télécharge et installe la nouvelle version
4. ✅ Préserve votre configuration

---

### Mise à jour manuelle

#### Méthode 1 : Réinstallation

```bash
curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash
```

#### Méthode 2 : Avec sauvegarde

```bash
# Sauvegarder la version actuelle
cp -r ~/.lm-cli ~/.lm-cli-backup-$(date +%Y%m%d)

# Réinstaller
curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash
```

---

### Vérifier les mises à jour disponibles

```bash
# Afficher la version actuelle
lm version

# Comparer avec GitHub (manuel)
curl -s https://api.github.com/repos/lmlouis/lm-cli/releases/latest | grep '"tag_name"'
```

---

## 🏷️ Gestion des versions

### Installer une version spécifique

```bash
# Installer la version 1.2.5
lm install v1.2.5

# Ou via le script d'installation
curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash -s -- -v v1.2.5
```

---

### Lister les versions disponibles

Consultez la page des [releases GitHub](https://github.com/lmlouis/lm-cli/releases).

Versions récentes :
- `v1.2.5` - Dernière version stable (actuelle)
- `v1.2.4` - Version précédente
- `v1.2.3` - Version stable
- `v1.2.2` - Version legacy

---

### Downgrade (retour à une version antérieure)

```bash
# Revenir à la version 1.2.3
lm install v1.2.3

# Ou manuellement
curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash -s -- -v v1.2.3
```

---

## 🗑️ Désinstallation

### Désinstallation standard

```bash
lm uninstall
```

Cette commande :
1. ✅ Supprime tous les fichiers de `~/.lm-cli`
2. ✅ Supprime le wrapper `~/.local/bin/lm`
3. ✅ Nettoie les configurations shell (`.bashrc`, `.zshrc`, etc.)

---

### Désinstallation avec sauvegarde

```bash
# Via le script d'installation
curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash -s -- -u --backup
```

Sauvegarde dans : `~/.lm-cli-backup/backup-<timestamp>/`

---

### Désinstallation complète (manuelle)

```bash
# 1. Supprimer les fichiers
rm -rf ~/.lm-cli
rm -f ~/.local/bin/lm

# 2. Nettoyer les configurations Bash
sed -i.bak '/# lm-cli/d' ~/.bashrc 2>/dev/null
sed -i.bak '/\.lm-cli/d' ~/.bashrc 2>/dev/null

# 3. Nettoyer les configurations Zsh
sed -i.bak '/# lm-cli/d' ~/.zshrc 2>/dev/null
sed -i.bak '/\.lm-cli/d' ~/.zshrc 2>/dev/null

# 4. Nettoyer PowerShell (Windows)
$content = Get-Content $PROFILE | Where-Object { $_ -notmatch "lm-cli" }
$content | Set-Content $PROFILE

# 5. Recharger le shell
source ~/.bashrc  # ou ~/.zshrc
# ou
. $PROFILE  # PowerShell
```

---

### Vérifier la désinstallation

```bash
# La commande ne devrait plus exister
lm version
# Résultat attendu : "command not found"

# Vérifier que les fichiers sont supprimés
ls ~/.lm-cli
# Résultat attendu : "No such file or directory"
```

---

## 🔄 Réinstallation

### Réinstallation propre

```bash
# 1. Désinstaller
lm uninstall

# 2. Réinstaller
curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash

# 3. Vérifier
lm version
```

---

### Réinstallation sans perdre la configuration

Si vous avez des configurations personnalisées :

```bash
# 1. Sauvegarder les configurations
cp ~/.lm-cli/config/* /tmp/lm-cli-config-backup/

# 2. Désinstaller
lm uninstall

# 3. Réinstaller
curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash

# 4. Restaurer les configurations
cp /tmp/lm-cli-config-backup/* ~/.lm-cli/config/
```

---

## 💾 Sauvegarde et restauration

### Sauvegarder lm-cli

```bash
# Sauvegarde complète
tar -czf ~/lm-cli-backup-$(date +%Y%m%d).tar.gz ~/.lm-cli

# Ou copie simple
cp -r ~/.lm-cli ~/lm-cli-backup-$(date +%Y%m%d)
```

---

### Restaurer depuis une sauvegarde

```bash
# Depuis une archive
tar -xzf ~/lm-cli-backup-20250119.tar.gz -C ~/

# Depuis une copie
cp -r ~/lm-cli-backup-20250119 ~/.lm-cli

# Rendre exécutable
chmod +x ~/.lm-cli/java.sh
chmod +x ~/.local/bin/lm

# Recharger le shell
source ~/.bashrc  # ou ~/.zshrc
```

---

## 📊 Emplacement des fichiers

### Structure d'installation

```
~/.lm-cli/                      # Répertoire principal
├── java.sh                     # Script principal
├── autocomplete.sh             # Autocomplétion Bash/Zsh
├── autocomplete.ps1            # Autocomplétion PowerShell
├── update.sh                   # Script de mise à jour
├── version.txt                 # Version actuelle
├── LICENSE                     # Licence
└── README.md                   # Documentation

~/.local/bin/
└── lm                          # Wrapper exécutable

~/.bashrc ou ~/.zshrc           # Configuration shell
~/.config/powershell/profile.ps1  # Configuration PowerShell
```

---

## 🔍 Vérification de l'intégrité

### Vérifier les fichiers

```bash
# Vérifier que tous les fichiers nécessaires existent
test -f ~/.lm-cli/java.sh && echo "✅ java.sh OK" || echo "❌ java.sh manquant"
test -f ~/.local/bin/lm && echo "✅ wrapper OK" || echo "❌ wrapper manquant"
test -f ~/.lm-cli/version.txt && echo "✅ version.txt OK" || echo "❌ version.txt manquant"
```

---

### Vérifier les permissions

```bash
# Les scripts doivent être exécutables
ls -la ~/.lm-cli/java.sh
ls -la ~/.local/bin/lm

# Si nécessaire, rendre exécutable
chmod +x ~/.lm-cli/java.sh
chmod +x ~/.local/bin/lm
```

---

## 🐛 Dépannage

### La mise à jour échoue

**Problème** : Erreur lors de `lm update`

**Solution 1** : Réinstallation complète
```bash
curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash
```

**Solution 2** : Mise à jour manuelle
```bash
cd /tmp
wget https://github.com/lmlouis/lm-cli/archive/refs/tags/v1.2.5.tar.gz
tar -xzf v1.2.5.tar.gz
cp -r lm-cli-1.2.5/* ~/.lm-cli/
```

---

### La désinstallation ne supprime pas tout

**Solution** : Désinstallation forcée
```bash
# Supprimer tous les fichiers liés à lm-cli
rm -rf ~/.lm-cli
rm -f ~/.local/bin/lm
find ~ -name "*lm-cli*" -type f 2>/dev/null

# Nettoyer les shells
for config in ~/.bashrc ~/.zshrc ~/.config/fish/config.fish; do
    [ -f "$config" ] && sed -i.bak '/lm-cli/d' "$config"
done
```

---

### Version incorrecte après mise à jour

**Problème** : `lm version` affiche l'ancienne version après mise à jour

**Solution** :
```bash
# 1. Vérifier le fichier version.txt
cat ~/.lm-cli/version.txt

# 2. Forcer la mise à jour
rm -rf ~/.lm-cli
curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash

# 3. Recharger le shell
exec $SHELL

# 4. Vérifier à nouveau
lm version
```

---

### Cache shell persistant

**Problème** : Les modifications ne sont pas prises en compte

**Solution** :
```bash
# Vider le cache des commandes
hash -r

# Ou redémarrer le shell
exec $SHELL

# Vérifier le PATH
which lm
```

---

## 📈 Migration entre versions

### De v1.2.x vers v1.2.5

La migration est automatique et transparente :
```bash
lm update
```

Changements notables :
- ✅ Support PowerShell ajouté
- ✅ Autocomplétion améliorée
- ✅ Nouvelles options pour les commandes

---

### De v1.1.x vers v1.2.x

⚠️ **Changements majeurs** :

1. Structure de fichiers modifiée
2. Nouvelles dépendances
3. Configuration mise à jour

**Procédure de migration** :
```bash
# 1. Sauvegarder
cp -r ~/.lm-cli ~/.lm-cli-backup

# 2. Désinstaller l'ancienne version
lm uninstall

# 3. Installer la nouvelle version
curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash

# 4. Vérifier
lm version
```

---

## 🔐 Sécurité

### Vérifier l'intégrité du téléchargement

```bash
# Télécharger et vérifier le checksum
curl -L https://github.com/lmlouis/lm-cli/releases/download/v1.2.5/lm-cli-1.2.5.tar.gz -o /tmp/lm-cli.tar.gz
curl -L https://github.com/lmlouis/lm-cli/releases/download/v1.2.5/checksums.txt -o /tmp/checksums.txt

# Vérifier (Linux/macOS)
cd /tmp && sha256sum -c checksums.txt
```

---

### Installation depuis une source de confiance

```bash
# Vérifier la signature GPG (si disponible)
curl -L https://github.com/lmlouis/lm-cli/releases/download/v1.2.5/lm-cli-1.2.5.tar.gz.asc -o /tmp/lm-cli.tar.gz.asc
gpg --verify /tmp/lm-cli.tar.gz.asc /tmp/lm-cli.tar.gz
```

---

## 📅 Planification des mises à jour

### Vérification automatique (optionnel)

Créer un script de vérification hebdomadaire :

```bash
cat > ~/check-lm-cli-updates.sh << 'EOF'
#!/bin/bash
CURRENT=$(cat ~/.lm-cli/version.txt 2>/dev/null || echo "unknown")
LATEST=$(curl -s https://api.github.com/repos/lmlouis/lm-cli/releases/latest | grep '"tag_name"' | sed -E 's/.*"v?([^"]+)".*/\1/')

if [ "$CURRENT" != "$LATEST" ]; then
    echo "🔔 Nouvelle version de lm-cli disponible : $LATEST (actuelle : $CURRENT)"
    echo "Pour mettre à jour, exécutez : lm update"
fi
EOF

chmod +x ~/check-lm-cli-updates.sh
```

Ajouter à cron :
```bash
# Vérifier tous les lundis à 9h
echo "0 9 * * 1 ~/check-lm-cli-updates.sh" | crontab -
```

---

## 🔄 Rollback automatique

### Script de rollback

```bash
cat > ~/.lm-cli/rollback.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="$HOME/.lm-cli-backup"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Aucune sauvegarde trouvée"
    exit 1
fi

LATEST_BACKUP=$(ls -t "$BACKUP_DIR" | head -1)
echo "📦 Restauration de : $LATEST_BACKUP"

rm -rf ~/.lm-cli
cp -r "$BACKUP_DIR/$LATEST_BACKUP" ~/.lm-cli

echo "✅ Rollback effectué"
lm version
EOF

chmod +x ~/.lm-cli/rollback.sh
```

Utilisation :
```bash
~/.lm-cli/rollback.sh
```

---

## 📊 Historique des versions

### Consulter l'historique local

```bash
# Voir les sauvegardes disponibles
ls -lht ~/.lm-cli-backup/

# Voir le changelog
cat ~/.lm-cli/CHANGELOG.md
```

---

### Consulter l'historique GitHub

```bash
# Dernières releases
curl -s https://api.github.com/repos/lmlouis/lm-cli/releases | jq -r '.[] | "\(.tag_name) - \(.name)"'
```

---

## 🔗 Ressources complémentaires

- [📦 Guide d'installation](INSTALLATION.md)
- [⚡ Configuration autocomplétion](AUTOCOMPLETE.md)
- [📚 Référence des commandes](COMMANDS.md)
- [📋 Changelog complet](https://github.com/lmlouis/lm-cli/releases)

---

## 🆘 Support

### Problèmes courants

| Problème | Solution |
|----------|----------|
| Commande introuvable | Vérifier le PATH et recharger le shell |
| Permission denied | `chmod +x ~/.lm-cli/java.sh ~/.local/bin/lm` |
| Mise à jour échoue | Réinstallation complète |
| Version incorrecte | Vider le cache : `hash -r` |

### Obtenir de l'aide

- 🐛 [Signaler un bug](https://github.com/lmlouis/lm-cli/issues/new?template=bug_report.md)
- 💬 [Forum de discussion](https://github.com/lmlouis/lm-cli/discussions)
- 📖 [Wiki](https://github.com/lmlouis/lm-cli/wiki)
- 📧 Email : support@lmlouis.dev

---

## 📝 Bonnes pratiques

### ✅ À faire

- ✅ Toujours sauvegarder avant une mise à jour majeure
- ✅ Tester les nouvelles versions dans un environnement de dev
- ✅ Lire le changelog avant de mettre à jour
- ✅ Vérifier la compatibilité avec votre version de Java

### ❌ À éviter

- ❌ Ne pas supprimer manuellement les fichiers sans désinstaller
- ❌ Ne pas modifier directement les scripts système
- ❌ Ne pas ignorer les erreurs lors de l'installation
- ❌ Ne pas utiliser des versions obsolètes

---

[⬅️ Retour au README principal](../README.md)