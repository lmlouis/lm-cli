# LM CLI - Générateur de Code Spring Boot

## 📋 Description

**LM CLI** est un outil en ligne de commande pour générer rapidement la structure de code d'une application Spring Boot. Il permet de créer des classes, configurations, DTOs, mappers, et autres composants courants avec une structure cohérente.

## 🚀 Fonctionnalités

### Commandes disponibles

| Commande | Description | Options |
|----------|-------------|---------|
| `create config <name>` | Créer une classe de configuration | `--properties` |
| `create exception <name>` | Créer une exception personnalisée | |
| `create constant <name>` | Créer une classe de constantes | |
| `create security <name>` | Créer un composant de sécurité | |
| `create pagination` | Créer une classe de pagination | |
| `create filter` | Créer un filter HTTP | |
| `create dto <name>` | Créer un DTO | `--record` |
| `create mapper <name>` | Créer un mapper | `--init` |
| `create domain <name>` | Créer une entité/enum | `--enum`, `--entity` |
| `create repository <name>` | Créer un repository JPA | |
| `create service <name>` | Créer un service | `--mapper`, `--criteria`, `--query`, `--implement`, `--class` |
| `create rest <name>` | Créer un contrôleur REST | |
| `create changelog <name>` | Créer un changelog Liquibase | `--init`, `--data`, `--sql` |
| `create application <profile>` | Créer un fichier de configuration | `--yml`, `--properties` |

### Options globales

- `--force` : Écraser les fichiers existants
- `--package=NAME` : Spécifier un package personnalisé
- `--help` : Afficher l'aide

## 📦 Installation

1. **Télécharger le script** :
```bash
wget https://raw.githubusercontent.com/votre-repo/lm-cli/main/lm
chmod +x lm
```

2. **Activer l'auto-complétion** (optionnel) :
```bash
echo "source $(pwd)/lm" >> ~/.bashrc
# ou pour Zsh
echo "source $(pwd)/lm" >> ~/.zshrc
```

## 🛠 Utilisation

### Exemples de base

```bash
# Créer un service avec implémentation
./lm create service UserService --implement

# Créer une entité JPA
./lm create domain User --entity

# Créer un repository
./lm create repository UserRepository

# Créer un contrôleur REST
./lm create rest UserResource
```

### Utilisation avec packages personnalisés

```bash
# Créer des composants dans un sous-package
./lm --package=statistics create dto Operation --record
./lm --package=security create service AuthService --implement
./lm --package=common create constant AppConstants
```

### Forcer l'écriture

```bash
# Écraser un fichier existant
./lm --force create domain Product --entity
```

## 🏗 Structure générée

Le script détecte automatiquement la structure du projet Maven et génère les fichiers dans :

```
src/main/java/
└── com.example.application/
    ├── config/
    ├── constant/
    ├── domain/
    │   ├── entity/
    │   └── enumeration/
    ├── dto/
    │   └── record/
    ├── exception/
    ├── mapper/
    ├── repository/
    ├── service/
    │   ├── criteria/
    │   ├── impl/
    │   └── mapper/
    ├── web/
    │   └── rest/
    └── security/
```

## 🔧 Configuration

### Prérequis

- **Java** 17 ou supérieur
- **Maven** 3.6 ou supérieur
- **Spring Boot** 3.x
- Projet Maven avec un `pom.xml` valide

### Détection automatique

Le script lit automatiquement :
- `groupId` et `artifactId` depuis `pom.xml`
- Structure des packages
- Configuration du projet

## 🎯 Exemples complets

### Création d'un module complet

```bash
# Module utilisateur
./lm --package=user create domain User --entity
./lm --package=user create repository UserRepository
./lm --package=user create service UserService --implement --mapper --criteria
./lm --package=user create dto UserDTO --record
./lm --package=user create rest UserResource

# Résultat dans : src/main/java/com.example.application.user/
```

### Configuration avancée

```bash
# Configuration avec propriétés
./lm create config Database --properties

# Mapper générique
./lm create mapper Entity --init

# Changelog Liquibase
./lm create changelog initial --init
./lm create changelog user-table --sql
```

## 🤝 Contribution

Les contributions sont bienvenues ! Pour contribuer :

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/ma-fonctionnalite`)
3. Commit les changements (`git commit -am 'Ajouter une fonctionnalité'`)
4. Push la branche (`git push origin feature/ma-fonctionnalite`)
5. Ouvrir une Pull Request

## 📝 Journal des modifications

### Version 1.0.7
- ✅ Ajout de l'auto-complétion Bash
- ✅ Support des packages personnalisés
- ✅ Option `--force` globale
- ✅ Meilleure gestion des erreurs
- ✅ Templates de code améliorés

### Version 1.0.0
- ✅ Version initiale avec les commandes de base

## 🐛 Dépannage

### Problèmes courants

**Fichier pom.xml introuvable**
```bash
✘ Fichier pom.xml introuvable.
```
→ Assurez-vous d'exécuter le script depuis la racine du projet Maven.

**Auto-complétion ne fonctionne pas**
```bash
# Recharger la configuration
source ~/.bashrc
# ou
exec bash
```

**Permission denied**
```bash
chmod +x lm
```

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👨‍💻 Auteur

Développé par WORA SOUAMY Louis Martin - louis-martin.wora@aninf.ga

---