# 📦 Guide d'installation lm-cli

Documentation complète pour installer lm-cli sur tous les systèmes d'exploitation.

---

## 📋 Table des matières

- [Prérequis](#-prérequis)
- [Installation automatique](#-installation-automatique)
- [Installation manuelle](#-installation-manuelle)
- [Vérification](#-vérification)
- [Configuration PATH](#-configuration-path)
- [Désinstallation](#-désinstallation)

---

## ✅ Prérequis

### Obligatoires

- **Java** : Version 17 ou supérieure
  ```bash
  java -version
  ```

- **Maven** ou **Gradle** : Outil de build
  ```bash
  mvn -version
  # ou
  gradle -version
  ```

- **Projet Spring Boot** : Un projet existant avec `pom.xml` ou `build.gradle`

### Recommandés

- **Git** : Pour cloner le dépôt
- **curl** ou **wget** : Pour l'installation automatique
- **Bash** 4.0+, **Zsh** 5.0+ ou **PowerShell** 5.1+

---

## ⚡ Installation automatique

### Linux / macOS / WSL

#### Méthode 1 : Avec curl
```bash
curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash
```

#### Méthode 2 : Avec wget
```bash
wget -qO- https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash
```

#### Installer une version spécifique
```bash
curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash -s -- -v v1.2.5
```

---

### Windows PowerShell

#### PowerShell 7+ (Recommandé)
```powershell
irm https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.ps1 | iex
```

#### PowerShell 5.1
```powershell
Invoke-RestMethod https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.ps1 | Invoke-Expression
```

---

## 🔧 Installation manuelle

### Étape 1 : Télécharger

```bash
# Créer le répertoire d'installation
mkdir -p ~/.lm-cli

# Télécharger la dernière version
VERSION="1.2.5"
curl -L https://github.com/lmlouis/lm-cli/archive/refs/tags/v${VERSION}.tar.gz -o /tmp/lm-cli.tar.gz

# Extraire
tar -xzf /tmp/lm-cli.tar.gz -C /tmp/
cp -r /tmp/lm-cli-${VERSION}/* ~/.lm-cli/

# Nettoyer
rm -rf /tmp/lm-cli* /tmp/lm-cli.tar.gz
```

### Étape 2 : Créer le wrapper

```bash
# Créer le répertoire bin
mkdir -p ~/.local/bin

# Créer le script wrapper
cat > ~/.local/bin/lm << 'EOF'
#!/bin/bash
SCRIPT_DIR="$HOME/.lm-cli"
exec "$SCRIPT_DIR/java.sh" "$@"
EOF

# Rendre exécutable
chmod +x ~/.local/bin/lm
chmod +x ~/.lm-cli/java.sh
```

### Étape 3 : Configurer PATH

#### Bash
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### Zsh
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

#### PowerShell
```powershell
$env:Path = "$env:USERPROFILE\.local\bin;$env:Path"
[Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::User)
```

---

## ✅ Vérification

### Vérifier l'installation

```bash
# Afficher la version
lm version

# Afficher l'aide
lm --help
```

### Tester dans un projet Spring Boot

```bash
# Naviguer vers un projet
cd /chemin/vers/mon-projet-spring

# Vérifier la détection du projet
lm create --help
```

---

## 🔄 Configuration PATH

### Vérifier le PATH

```bash
echo $PATH | grep ".local/bin"
```

Si `.local/bin` n'apparaît pas, ajoutez-le manuellement :

#### Bash
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### Zsh
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

#### Fish
```bash
set -Ua fish_user_paths ~/.local/bin
```

---

## 🗑️ Désinstallation

### Désinstallation simple

```bash
lm uninstall
```

### Désinstallation avec sauvegarde

```bash
curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash -s -- -u --backup
```

### Désinstallation manuelle

```bash
# Supprimer les fichiers
rm -rf ~/.lm-cli
rm -f ~/.local/bin/lm

# Nettoyer les configurations
sed -i.bak '/# lm-cli/d' ~/.bashrc 2>/dev/null
sed -i.bak '/\.lm-cli/d' ~/.bashrc 2>/dev/null

# Ou pour Zsh
sed -i.bak '/# lm-cli/d' ~/.zshrc 2>/dev/null
sed -i.bak '/\.lm-cli/d' ~/.zshrc 2>/dev/null

# Recharger
source ~/.bashrc  # ou ~/.zshrc
```

---

## 🐛 Dépannage

### Erreur : "lm : commande introuvable"

**Cause** : Le PATH n'est pas configuré correctement.

**Solution** :
```bash
# Vérifier si le fichier existe
ls -la ~/.local/bin/lm

# Ajouter au PATH
export PATH="$HOME/.local/bin:$PATH"

# Rendre permanent
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

### Erreur : "Permission denied"

**Cause** : Le script n'est pas exécutable.

**Solution** :
```bash
chmod +x ~/.local/bin/lm
chmod +x ~/.lm-cli/java.sh
```

---

### Erreur : "java: command not found"

**Cause** : Java n'est pas installé ou pas dans le PATH.

**Solution** :

**Ubuntu/Debian** :
```bash
sudo apt update
sudo apt install openjdk-17-jdk
```

**macOS** :
```bash
brew install openjdk@17
```

**Windows** :
Téléchargez Java depuis [Oracle](https://www.oracle.com/java/technologies/downloads/) ou [Adoptium](https://adoptium.net/)

---

### Erreur PowerShell : "Execution Policy"

**Cause** : L'exécution de scripts est désactivée.

**Solution** :
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 🔗 Prochaines étapes

Après l'installation :

1. 📚 Consultez la [référence des commandes](COMMANDS.md)
2. ⚡ Configurez l'[autocomplétion](AUTOCOMPLETE.md)
3. 🔄 Apprenez le [cycle de vie](LIFECYCLE.md)

---

## 🆘 Besoin d'aide ?

- [🐛 Signaler un bug](https://github.com/lmlouis/lm-cli/issues)
- [💬 Discussions](https://github.com/lmlouis/lm-cli/discussions)
- [📖 Wiki](https://github.com/lmlouis/lm-cli/wiki)

---

[⬅️ Retour au README principal](../README.md)