# 🚀 lm-cli

[![Version](https://img.shields.io/badge/version-1.2.6-blue.svg)](https://github.com/lmlouis/lm-cli/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash%20%7C%20zsh%20%7C%20powershell-orange.svg)]()

**lm-cli** est un outil en ligne de commande puissant pour générer automatiquement des composants Spring Boot suivant les meilleures pratiques et l'architecture en couches.

> 🎯 **Gagnez du temps** : Générez des entités, services, repositories, DTOs, mappers et contrôleurs REST en une seule commande !

---

## ✨ Fonctionnalités principales

- 🏗️ **Génération de code** : Entités, repositories, services, contrôleurs REST
- 📦 **Architecture en couches** : Respecte les principes SOLID et Clean Architecture
- 🔄 **Mappers automatiques** : Conversion entité ↔ DTO avec MapStruct
- 🔒 **Sécurité** : Configuration JWT, Spring Security, authentification
- 📝 **Documentation** : Swagger/OpenAPI intégré
- 🗃️ **Base de données** : Support Liquibase pour les migrations
- ⚡ **Autocomplétion** : Support Bash, Zsh et PowerShell
- 🌐 **Multi-plateforme** : Linux, macOS, Windows (WSL/PowerShell)

---

## 📦 Installation rapide

### Linux / macOS / WSL

```bash
curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash
```

### Windows PowerShell

```powershell
irm https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.ps1 | iex
```

Après l'installation, redémarrez votre terminal ou exécutez :

```bash
source ~/.bashrc  # Bash
source ~/.zshrc   # Zsh
. $PROFILE        # PowerShell
```

**📖 [Guide d'installation complet](docs/INSTALLATION.md)**

---

## 🎯 Démarrage rapide

### 1. Créer un DTO

```bash
lm create dto User --record
```

### 2. Créer une entité JPA

```bash
lm create domain Product --entity
```

### 3. Créer un service complet

```bash
lm create service Order --mapper --implement
```

### 4. Créer un contrôleur REST

```bash
lm create rest Customer
```

**📚 [Référence complète des commandes](docs/COMMANDS.md)**

---

## 📋 Prérequis

- **Java** 17 ou supérieur
- **Maven** ou **Gradle**
- Un projet **Spring Boot** existant (avec `pom.xml` ou `build.gradle`)
- **Bash** 4.0+, **Zsh** 5.0+ ou **PowerShell** 5.1+

---

## 📚 Documentation

| Documentation | Description |
|---------------|-------------|
| [📖 Installation](docs/INSTALLATION.md) | Guide d'installation détaillé pour tous les OS |
| [⚡ Autocomplétion](docs/AUTOCOMPLETE.md) | Configuration de l'autocomplétion intelligente |
| [📚 Commandes](docs/COMMANDS.md) | Référence complète de toutes les commandes |
| [🔄 Cycle de vie](docs/LIFECYCLE.md) | Installation, mise à jour et désinstallation |

---

## 🚀 Commandes disponibles

### Génération de composants

```bash
lm create config <name>           # Configuration (Database, Security, etc.)
lm create exception <name>        # Exception personnalisée
lm create constant <name>         # Classe de constantes
lm create security <name>         # Configuration de sécurité
lm create dto <name>              # Data Transfer Object
lm create mapper <name>           # Mapper entité ↔ DTO
lm create domain <name>           # Entité JPA ou Enum
lm create repository <name>       # Repository Spring Data JPA
lm create service <name>          # Service métier
lm create rest <name>             # Contrôleur REST
lm create changelog <name>        # Changelog Liquibase
lm create application <profile>   # Fichier application.yml
lm create pagination              # Système de pagination
lm create filter                  # Système de filtrage
```

### Gestion de l'outil

```bash
lm version                        # Afficher la version
lm update                         # Mettre à jour lm-cli
lm install <version>              # Installer une version spécifique
lm uninstall                      # Désinstaller lm-cli
lm --help                         # Afficher l'aide
```

---

## 💡 Exemples d'utilisation

### Créer un CRUD complet pour "Product"

```bash
# 1. Créer l'entité
lm create domain Product --entity

# 2. Créer le DTO
lm create dto Product --record

# 3. Créer le mapper
lm create mapper Product --init

# 4. Créer le repository
lm create repository Product

# 5. Créer le service
lm create service Product --mapper --implement

# 6. Créer le contrôleur REST
lm create rest Product
```

### Configurer la sécurité JWT

```bash
# 1. Configuration de sécurité
lm create security JwtUtil

# 2. Contrôleur d'authentification
lm create rest Auth
```

### Initialiser Liquibase

```bash
# Changelog initial
lm create changelog initial --init

# Ajouter des données de test
lm create changelog seed_data --data
```

---

## 🎨 Structure générée

```
src/main/java/com/example/demo/
├── config/                  # Configurations
│   ├── DatabaseConfig.java
│   ├── SecurityConfig.java
│   └── SwaggerConfig.java
├── domain/                  # Entités JPA
│   ├── Product.java
│   └── User.java
├── dto/                     # Data Transfer Objects
│   ├── ProductDTO.java
│   └── UserDTO.java
├── mapper/                  # Mappers
│   ├── ProductMapper.java
│   └── UserMapper.java
├── repository/              # Repositories
│   ├── ProductRepository.java
│   └── UserRepository.java
├── service/                 # Services
│   ├── ProductService.java
│   └── UserService.java
├── web/rest/               # Contrôleurs REST
│   ├── ProductResource.java
│   └── UserResource.java
└── exception/              # Exceptions personnalisées
    ├── NotFoundException.java
    └── BadRequestException.java
```

---

## 🔧 Configuration

lm-cli détecte automatiquement :
- ✅ Le package principal de votre application
- ✅ La structure de votre projet (Maven/Gradle)
- ✅ Les dépendances existantes
- ✅ La version de Java utilisée

Pour spécifier un package personnalisé :

```bash
lm create service Product --package com.mycompany.custom
```

---

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Fork le projet
2. Créez une branche (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Committez vos changements (`git commit -m 'Ajout nouvelle fonctionnalité'`)
4. Poussez vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Ouvrez une Pull Request

---

## 🐛 Signaler un bug

Vous avez trouvé un bug ? [Créez une issue](https://github.com/lmlouis/lm-cli/issues/new?template=bug_report.md)

---

## 📝 Changelog

Consultez le [CHANGELOG.md](CHANGELOG.md) pour voir l'historique des versions.

### Version actuelle : 1.2.6

**Nouveautés** :
- ✨ Support PowerShell pour Windows
- ⚡ Autocomplétion intelligente améliorée
- 🐛 Corrections de bugs divers
- 📚 Documentation enrichie

[Voir toutes les versions](https://github.com/lmlouis/lm-cli/releases)

---

## 📄 Licence

Ce projet est sous licence **MIT**. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 👤 Auteur

**Louis LM**

- GitHub: [@lmlouis](https://github.com/lmlouis)
- Email: louis-martin.wora@aninf.ga

---

## ⭐ Support

Si ce projet vous est utile, n'hésitez pas à lui donner une ⭐ sur GitHub !

---

## 🔗 Liens utiles

- [📖 Documentation complète](https://github.com/lmlouis/lm-cli/wiki)
- [🐛 Signaler un bug](https://github.com/lmlouis/lm-cli/issues)
- [💬 Discussions](https://github.com/lmlouis/lm-cli/discussions)
- [📦 Releases](https://github.com/lmlouis/lm-cli/releases)

---