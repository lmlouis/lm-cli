# 🚀 Autocomplétion lm-cli

Documentation complète pour l'installation et l'utilisation de l'autocomplétion intelligente de **lm-cli**.

## 📋 Table des matières

- [Compatibilité](#-compatibilité)
- [Installation automatique](#-installation-automatique)
- [Installation manuelle](#-installation-manuelle)
- [Vérification](#-vérification)
- [Utilisation](#-utilisation)
- [Dépannage](#-dépannage)
- [Désinstallation](#-désinstallation)

---

## 🖥️ Compatibilité

| Fichier | Shell | Systèmes d'exploitation | Commande de chargement |
|---------|-------|------------------------|------------------------|
| **autocomplete.sh** | Bash + Zsh | Linux, macOS, WSL | `source ~/.lm-cli/autocomplete.sh` |
| **autocomplete.ps1** | PowerShell | Windows, Linux, macOS | `. ~/.lm-cli/autocomplete.ps1` |

### Versions supportées

- **Bash** : 4.0+
- **Zsh** : 5.0+
- **PowerShell** : 5.1+ et PowerShell Core 7+

---

## ⚡ Installation automatique

L'autocomplétion est automatiquement configurée lors de l'installation de lm-cli :

```bash
curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash
```

Après l'installation, **redémarrez votre terminal** ou rechargez votre configuration :

### Bash
```bash
source ~/.bashrc
```

### Zsh
```bash
source ~/.zshrc
```

### PowerShell
```powershell
. $PROFILE
```

---

## 🔧 Installation manuelle

Si l'installation automatique n'a pas configuré l'autocomplétion, suivez ces étapes :

### Pour Bash

1. **Ajouter au fichier de configuration** :
   ```bash
   echo '# lm-cli autocomplete' >> ~/.bashrc
   echo '[ -f "$HOME/.lm-cli/autocomplete.sh" ] && source "$HOME/.lm-cli/autocomplete.sh"' >> ~/.bashrc
   ```

2. **Recharger la configuration** :
   ```bash
   source ~/.bashrc
   ```

### Pour Zsh

1. **Ajouter au fichier de configuration** :
   ```bash
   echo '# lm-cli autocomplete' >> ~/.zshrc
   echo '[ -f "$HOME/.lm-cli/autocomplete.sh" ] && source "$HOME/.lm-cli/autocomplete.sh"' >> ~/.zshrc
   ```

2. **Recharger la configuration** :
   ```bash
   source ~/.zshrc
   ```

### Pour PowerShell (Windows)

1. **Vérifier l'emplacement du profil** :
   ```powershell
   echo $PROFILE
   ```

2. **Créer le profil s'il n'existe pas** :
   ```powershell
   if (!(Test-Path $PROFILE)) { New-Item -Path $PROFILE -ItemType File -Force }
   ```

3. **Ajouter l'autocomplétion** :
   ```powershell
   Add-Content $PROFILE "`n# lm-cli autocomplete"
   Add-Content $PROFILE ". `$env:USERPROFILE\.lm-cli\autocomplete.ps1"
   ```

4. **Recharger le profil** :
   ```powershell
   . $PROFILE
   ```

### Pour PowerShell (Linux/macOS)

```powershell
Add-Content $PROFILE "`n# lm-cli autocomplete"
Add-Content $PROFILE ". `$HOME/.lm-cli/autocomplete.ps1"
. $PROFILE
```

---

## ✅ Vérification

Après l'installation, vérifiez que l'autocomplétion fonctionne :

### Test rapide
```bash
lm <TAB>
```

Vous devriez voir :
```
create     install    uninstall    update    version    --help    --force    --package
```

### Dans un projet Spring Boot

Naviguez vers un répertoire contenant un fichier `pom.xml`, puis testez :

```bash
lm create <TAB>
```

Vous devriez voir :
```
config        dto           mapper        repository    changelog
exception     domain        service       application
constant      pagination    rest          
security      filter
```

---

## 🎯 Utilisation

### Complétion des commandes principales

```bash
lm <TAB>
```
**Suggestions** : `create`, `update`, `install`, `uninstall`, `version`, `--help`, `--force`

---

### Complétion des sous-commandes

```bash
lm create <TAB>
```
**Suggestions** : `config`, `exception`, `constant`, `security`, `dto`, `service`, `rest`, etc.

---

### Complétion des noms suggérés

#### Pour un DTO
```bash
lm create dto <TAB>
```
**Suggestions** : `User`, `Product`, `Order`, `Customer`, `Invoice`, `--record`, `--force`

#### Pour un service
```bash
lm create service <TAB>
```
**Suggestions** : `User`, `Product`, `Order`, `Email`, `Notification`, `--mapper`, `--criteria`

---

### Complétion des options

```bash
lm create service User <TAB>
```
**Suggestions** : `--mapper`, `--criteria`, `--query`, `--implement`, `--class`, `--force`

---

### Complétion contextuelle

L'autocomplétion est **intelligente** et s'adapte au contexte :

- ✅ **Avec pom.xml** : La commande `create` est disponible
- ⚠️ **Sans pom.xml** : Seules les commandes de gestion sont proposées

```bash
# Dans un projet Spring Boot (avec pom.xml)
lm <TAB>
# → create, update, install, uninstall, version

# Hors projet Spring Boot
lm <TAB>
# → update, install, uninstall, version (pas de 'create')
```

---

## 🔍 Exemples d'utilisation

### Créer un DTO User en mode record
```bash
lm create dto User --record
```
**Autocomplétion** :
1. `lm <TAB>` → `create`
2. `lm create <TAB>` → `dto`
3. `lm create dto <TAB>` → `User`
4. `lm create dto User <TAB>` → `--record`

---

### Créer un service avec mapper
```bash
lm create service Product --mapper
```
**Autocomplétion** :
1. `lm <TAB>` → `create`
2. `lm create <TAB>` → `service`
3. `lm create service <TAB>` → `Product`
4. `lm create service Product <TAB>` → `--mapper`

---

### Créer une configuration de base de données
```bash
lm create config Database --properties
```
**Autocomplétion** :
1. `lm <TAB>` → `create`
2. `lm create <TAB>` → `config`
3. `lm create config <TAB>` → `Database`
4. `lm create config Database <TAB>` → `--properties`

---

## 🐛 Dépannage

### L'autocomplétion ne fonctionne pas

#### 1. Vérifier que le fichier existe
```bash
ls -la ~/.lm-cli/autocomplete.sh
```

#### 2. Vérifier le shell utilisé
```bash
echo $SHELL
```

#### 3. Vérifier que le fichier est chargé

**Pour Bash/Zsh** :
```bash
grep "lm-cli" ~/.bashrc
# ou
grep "lm-cli" ~/.zshrc
```

**Pour PowerShell** :
```powershell
Get-Content $PROFILE | Select-String "lm-cli"
```

#### 4. Charger manuellement
```bash
source ~/.lm-cli/autocomplete.sh
```

#### 5. Vérifier les permissions
```bash
chmod +x ~/.lm-cli/autocomplete.sh
```

---

### L'autocomplétion suggère des fichiers au lieu de commandes

**Problème** : Zsh suggère les fichiers du répertoire `~/.lm-cli/` au lieu des commandes.

**Solution** : Assurez-vous d'utiliser la version correcte du fichier `autocomplete.sh` qui contient `compdef _lm lm` pour Zsh.

```bash
# Vérifier
tail -5 ~/.lm-cli/autocomplete.sh
```

Doit contenir :
```bash
compdef _lm lm
```

---

### L'autocomplétion ne détecte pas le pom.xml

**Problème** : La commande `create` n'apparaît pas même dans un projet Spring Boot.

**Solution** : Vérifiez que vous êtes dans le bon répertoire :
```bash
ls pom.xml
```

Ou naviguez vers le répertoire racine du projet :
```bash
cd /chemin/vers/mon-projet-spring
lm create <TAB>
```

---

### PowerShell : Erreur "Impossible d'exécuter des scripts"

**Problème** :
```
. : Impossible de charger le fichier autocomplete.ps1, car l'exécution de scripts est désactivée sur ce système.
```

**Solution** : Autoriser l'exécution de scripts locaux :
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

### Bash : Commande `_init_completion` introuvable

**Problème** : Erreur lors du chargement de l'autocomplétion.

**Solution** : Installer `bash-completion` :

**Ubuntu/Debian** :
```bash
sudo apt install bash-completion
```

**macOS (Homebrew)** :
```bash
brew install bash-completion@2
```

Puis ajouter à `~/.bashrc` :
```bash
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"
```

---

## 🗑️ Désinstallation

### Supprimer l'autocomplétion de la configuration

**Bash** :
```bash
sed -i.bak '/# lm-cli autocomplete/,+1d' ~/.bashrc
source ~/.bashrc
```

**Zsh** :
```bash
sed -i.bak '/# lm-cli autocomplete/,+1d' ~/.zshrc
source ~/.zshrc
```

**PowerShell** :
```powershell
$content = Get-Content $PROFILE | Where-Object { $_ -notmatch "lm-cli" }
$content | Set-Content $PROFILE
. $PROFILE
```

---

## 📚 Commandes supportées

### Commandes principales

| Commande | Description |
|----------|-------------|
| `create` | Créer des composants Spring Boot |
| `update` | Mettre à jour lm-cli |
| `install` | Installer une version spécifique |
| `uninstall` | Désinstaller lm-cli |
| `version` | Afficher la version |

### Sous-commandes `create`

| Sous-commande | Description | Options |
|---------------|-------------|---------|
| `config` | Créer une configuration | `--properties`, `--force` |
| `exception` | Créer une exception | `--force` |
| `constant` | Créer une classe de constantes | `--force` |
| `security` | Créer une config de sécurité | `--force` |
| `pagination` | Créer le système de pagination | `--force` |
| `filter` | Créer le système de filtrage | `--force` |
| `dto` | Créer un DTO | `--record`, `--force` |
| `mapper` | Créer un mapper | `--init`, `--force` |
| `domain` | Créer une entité | `--enum`, `--entity`, `--force` |
| `repository` | Créer un repository | `--force` |
| `service` | Créer un service | `--mapper`, `--criteria`, `--query`, `--implement`, `--class`, `--force` |
| `rest` | Créer un contrôleur REST | `--force` |
| `changelog` | Créer un changelog Liquibase | `--init`, `--data`, `--sql`, `--force` |
| `application` | Créer application.yml | `--yml`, `--properties`, `--force` |

### Options globales

| Option | Description |
|--------|-------------|
| `--force` | Écraser les fichiers existants |
| `--package` | Spécifier un package personnalisé |
| `--help` | Afficher l'aide |

---

## 🤝 Contribution

Pour améliorer l'autocomplétion, consultez le [guide de contribution](CONTRIBUTING.md).

---

## 📝 License

Ce projet est sous licence MIT. Voir le fichier [LICENSE](../LICENSE) pour plus de détails.

---

## 🔗 Liens utiles

- [Documentation complète](https://github.com/lmlouis/lm-cli/wiki)
- [Signaler un bug](https://github.com/lmlouis/lm-cli/issues)
- [Changelog](https://github.com/lmlouis/lm-cli/releases)

---

**Fait avec ❤️ par l'équipe lm-cli**