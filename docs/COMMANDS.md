# 📚 Référence des commandes lm-cli

Documentation complète de toutes les commandes disponibles dans lm-cli.

---

## 📋 Table des matières

- [Syntaxe générale](#-syntaxe-générale)
- [Options globales](#-options-globales)
- [Commandes de gestion](#-commandes-de-gestion)
- [Commandes create](#-commandes-create)
- [Exemples pratiques](#-exemples-pratiques)

---

## 🎯 Syntaxe générale

```bash
lm [OPTIONS] <command> [subcommand] [name] [OPTIONS]
```

### Structure

```
lm [--global-options] command [subcommand] [name] [--command-options]
│   │                   │       │           │      │
│   │                   │       │           │      └─ Options spécifiques
│   │                   │       │           └──────── Nom du composant
│   │                   │       └──────────────────── Sous-commande (pour create)
│   │                   └──────────────────────────── Commande principale
│   └──────────────────────────────────────────────── Options globales
└──────────────────────────────────────────────────── Exécutable
```

---

## 🌐 Options globales

Ces options s'appliquent à toutes les commandes :

| Option | Description | Exemple |
|--------|-------------|---------|
| `--force` | Écraser les fichiers existants sans confirmation | `lm create dto User --force` |
| `--package=NAME` | Spécifier un package personnalisé | `lm create service Product --package=com.custom` |
| `--help` | Afficher l'aide | `lm --help` |

---

## 🔧 Commandes de gestion

### `version`

Affiche la version installée de lm-cli.

```bash
lm version
```

**Sortie** :
```
lm-cli version 1.2.5
```

---

### `update`

Met à jour lm-cli vers la dernière version.

```bash
lm update
```

**Fonctionnement** :
1. Détecte la dernière version sur GitHub
2. Sauvegarde la version actuelle
3. Télécharge et installe la nouvelle version
4. Affiche les changements

---

### `install [version]`

Installe une version spécifique de lm-cli.

```bash
# Installer la dernière version
lm install

# Installer une version spécifique
lm install v1.2.5
```

**Versions disponibles** :
- `latest` : Dernière version stable
- `v1.2.5` : Version 1.2.5
- `v1.2.4` : Version 1.2.4

---

### `uninstall`

Désinstalle lm-cli du système.

```bash
lm uninstall
```

**Actions effectuées** :
- Supprime `~/.lm-cli`
- Supprime `~/.local/bin/lm`
- Nettoie les configurations shell

---

## 🏗️ Commandes create

### `create config <name>`

Crée un fichier de configuration Spring Boot.

```bash
lm create config <name> [--properties] [--force]
```

**Arguments** :
- `<name>` : Type de configuration (requis)

**Options** :
- `--properties` : Génère en `.properties` au lieu de `.yml`
- `--force` : Écrase le fichier s'il existe

**Configurations disponibles** :

| Nom | Description | Fichier généré |
|-----|-------------|----------------|
| `Database` | Configuration JDBC/JPA | `DatabaseConfig.java` |
| `Security` | Configuration Spring Security | `SecurityConfig.java` |
| `Email` | Configuration JavaMail | `EmailConfig.java` |
| `Cache` | Configuration cache (Caffeine) | `CacheConfig.java` |
| `Redis` | Configuration Redis | `RedisConfig.java` |
| `OAuth` | Configuration OAuth2 | `OAuthConfig.java` |
| `Swagger` | Configuration Swagger/OpenAPI | `SwaggerConfig.java` |
| `CORS` | Configuration CORS | `CorsConfig.java` |

**Exemples** :
```bash
# Configuration de base de données
lm create config Database

# Configuration sécurité en .properties
lm create config Security --properties

# Écraser la config existante
lm create config Redis --force
```

---

### `create exception <name>`

Crée une exception personnalisée.

```bash
lm create exception <name> [--force]
```

**Arguments** :
- `<name>` : Nom de l'exception (requis)

**Exceptions prédéfinies** :

| Nom | Code HTTP | Description |
|-----|-----------|-------------|
| `NotFound` | 404 | Ressource non trouvée |
| `BadRequest` | 400 | Requête invalide |
| `Unauthorized` | 401 | Non autorisé |
| `Forbidden` | 403 | Accès interdit |
| `Validation` | 422 | Erreur de validation |
| `ResourceNotFound` | 404 | Ressource spécifique non trouvée |

**Exemples** :
```bash
# Exception NotFound
lm create exception NotFound

# Exception personnalisée
lm create exception PaymentFailedException --force
```

---

### `create constant <name>`

Crée une classe de constantes.

```bash
lm create constant <name> [--force]
```

**Constantes prédéfinies** :

| Nom | Contenu |
|-----|---------|
| `Application` | Constantes générales de l'application |
| `Api` | Constantes d'API (endpoints, versions) |
| `Database` | Constantes de base de données |
| `Status` | Constantes de statut |
| `ErrorCode` | Codes d'erreur |

**Exemples** :
```bash
lm create constant Application
lm create constant ErrorCode --force
```

---

### `create security <name>`

Crée un composant de sécurité.

```bash
lm create security <name> [--force]
```

**Composants disponibles** :

| Nom | Description |
|-----|-------------|
| `JwtUtil` | Utilitaire JWT (génération/validation tokens) |
| `SecurityConfig` | Configuration Spring Security |
| `UserDetailsService` | Service de chargement des utilisateurs |
| `AuthenticationFilter` | Filtre d'authentification JWT |

**Exemples** :
```bash
lm create security JwtUtil
lm create security SecurityConfig
lm create security AuthenticationFilter --force
```

---

### `create pagination`

Crée le système de pagination complet.

```bash
lm create pagination [--force]
```

**Génère** :
- `PageRequest.java` : Objet de requête de pagination
- `PageResponse.java` : Objet de réponse paginée
- `Pageable` : Interface de pagination

**Exemple** :
```bash
lm create pagination
```

---

### `create filter`

Crée le système de filtrage générique.

```bash
lm create filter [--force]
```

**Génère** :
- `FilterCriteria.java` : Critères de filtrage
- `GenericFilter.java` : Filtre générique
- `FilterUtils.java` : Utilitaires de filtrage

**Exemple** :
```bash
lm create filter
```

---

### `create dto <name>`

Crée un Data Transfer Object.

```bash
lm create dto <name> [--record] [--force]
```

**Arguments** :
- `<name>` : Nom du DTO (requis)

**Options** :
- `--record` : Génère un record Java au lieu d'une classe
- `--force` : Écrase le fichier s'il existe

**Exemples** :
```bash
# DTO classique
lm create dto User

# DTO en record Java 17+
lm create dto Product --record

# Avec package personnalisé
lm create dto Order --package=com.myapp.dto --force
```

**Structure générée** :
```java
// Classe traditionnelle
public class UserDTO {
    private Long id;
    private String name;
    // getters, setters, equals, hashCode
}

// Record (avec --record)
public record ProductDTO(Long id, String name, BigDecimal price) {}
```

---

### `create mapper <name>`

Crée un mapper entre entité et DTO.

```bash
lm create mapper <name> [--init] [--force]
```

**Arguments** :
- `<name>` : Nom du mapper (requis)

**Options** :
- `--init` : Configure MapStruct si pas déjà présent
- `--force` : Écrase le fichier s'il existe

**Exemples** :
```bash
# Mapper simple
lm create mapper User

# Avec initialisation MapStruct
lm create mapper Product --init

# Mapper générique
lm create mapper EntityMapper --force
```

---

### `create domain <name>`

Crée une entité JPA ou une énumération.

```bash
lm create domain <name> [--enum | --entity] [--force]
```

**Arguments** :
- `<name>` : Nom de l'entité ou enum (requis)

**Options** :
- `--enum` : Génère une énumération
- `--entity` : Génère une entité JPA (par défaut)
- `--force` : Écrase le fichier s'il existe

**Exemples** :
```bash
# Entité JPA
lm create domain User

# Énumération
lm create domain Status --enum

# Entité avec relations
lm create domain Order --entity --force
```

**Structure générée** :
```java
// Entité
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String name;
    
    // getters, setters
}

// Enum
public enum Status {
    ACTIVE, INACTIVE, PENDING
}
```

---

### `create repository <name>`

Crée un repository Spring Data JPA.

```bash
lm create repository <name> [--force]
```

**Arguments** :
- `<name>` : Nom du repository (requis)

**Exemples** :
```bash
lm create repository User
lm create repository Product --force
```

**Structure générée** :
```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    List<User> findByStatus(Status status);
}
```

---

### `create service <name>`

Crée une couche service.

```bash
lm create service <name> [OPTIONS]
```

**Arguments** :
- `<name>` : Nom du service (requis)

**Options** :
- `--mapper` : Inclut un mapper dans le service
- `--criteria` : Utilise JPA Criteria API
- `--query` : Utilise QueryDSL
- `--implement` : Génère l'implémentation
- `--class` : Génère une classe concrète au lieu d'une interface
- `--force` : Écrase les fichiers s'ils existent

**Exemples** :
```bash
# Service basique
lm create service User

# Service avec mapper
lm create service Product --mapper

# Service avec Criteria API
lm create service Order --criteria --implement

# Service QueryDSL
lm create service Invoice --query

# Classe de service directe
lm create service Email --class
```

**Structure générée** :
```java
// Interface
public interface UserService {
    UserDTO create(UserDTO dto);
    UserDTO findById(Long id);
    List<UserDTO> findAll();
    UserDTO update(Long id, UserDTO dto);
    void delete(Long id);
}

// Implémentation (avec --implement)
@Service
public class UserServiceImpl implements UserService {
    private final UserRepository repository;
    private final UserMapper mapper;
    
    // Implémentation des méthodes
}
```

---

### `create rest <name>`

Crée un contrôleur REST.

```bash
lm create rest <name> [--force]
```

**Arguments** :
- `<name>` : Nom du contrôleur (requis)

**Exemples** :
```bash
lm create rest User
lm create rest Product --force
lm create rest Auth
```

**Structure générée** :
```java
@RestController
@RequestMapping("/api/users")
public class UserResource {
    private final UserService service;
    
    @GetMapping
    public ResponseEntity<List<UserDTO>> findAll() { }
    
    @GetMapping("/{id}")
    public ResponseEntity<UserDTO> findById(@PathVariable Long id) { }
    
    @PostMapping
    public ResponseEntity<UserDTO> create(@RequestBody UserDTO dto) { }
    
    @PutMapping("/{id}")
    public ResponseEntity<UserDTO> update(@PathVariable Long id, @RequestBody UserDTO dto) { }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) { }
}
```

---

### `create changelog <name>`

Crée un changelog Liquibase.

```bash
lm create changelog <name> [OPTIONS]
```

**Arguments** :
- `<name>` : Nom du changelog (requis)

**Options** :
- `--init` : Initialise Liquibase dans le projet
- `--data` : Inclut des données de test
- `--sql` : Génère en SQL pur au lieu de YAML
- `--force` : Écrase le fichier s'il existe

**Exemples** :
```bash
# Changelog initial
lm create changelog initial --init

# Changelog pour créer une table
lm create changelog create_users

# Changelog avec données
lm create changelog seed_data --data

# Changelog SQL
lm create changelog add_indexes --sql
```

---

### `create application <profile>`

Crée un fichier de configuration application.

```bash
lm create application <profile> [OPTIONS]
```

**Arguments** :
- `<profile>` : Profil d'environnement (requis)

**Options** :
- `--yml` : Génère en YAML (par défaut)
- `--properties` : Génère en .properties
- `--force` : Écrase le fichier s'il existe

**Profils disponibles** :

| Profil | Description |
|--------|-------------|
| `dev` | Développement local |
| `prod` | Production |
| `test` | Tests |
| `staging` | Pré-production |
| `local` | Configuration locale |

**Exemples** :
```bash
# Profil de développement
lm create application dev

# Profil de production en .properties
lm create application prod --properties

# Profil de test
lm create application test --yml --force
```

---

## 💡 Exemples pratiques

### Créer un CRUD complet

```bash
# 1. Entité
lm create domain Product --entity

# 2. DTO
lm create dto Product --record

# 3. Mapper
lm create mapper Product --init

# 4. Repository
lm create repository Product

# 5. Service
lm create service Product --mapper --implement

# 6. Contrôleur REST
lm create rest Product
```

---

### Système d'authentification JWT

```bash
# 1. Configuration sécurité
lm create config Security

# 2. Utilitaire JWT
lm create security JwtUtil

# 3. UserDetailsService
lm create security UserDetailsService

# 4. Filtre d'authentification
lm create security AuthenticationFilter

# 5. Contrôleur Auth
lm create rest Auth
```

---

### Gestion des utilisateurs

```bash
# Entité User
lm create domain User --entity

# Enum Role
lm create domain Role --enum

# DTO User
lm create dto User --record

# Mapper
lm create mapper User

# Repository avec méthodes custom
lm create repository User

# Service avec recherche
lm create service User --mapper --criteria --implement

# Contrôleur REST
lm create rest User

# Exceptions
lm create exception UserNotFoundException
```

---

## 🔍 Recherche de commandes

### Par fonctionnalité

**Configuration** :
- `lm create config Database`
- `lm create config Security`
- `lm create application dev`

**Entités & Persistance** :
- `lm create domain User`
- `lm create repository User`
- `lm create changelog initial`

**Logique métier** :
- `lm create service User`
- `lm create exception NotFound`
- `lm create constant ErrorCode`

**API REST** :
- `lm create rest User`
- `lm create dto User`
- `lm create mapper User`

**Sécurité** :
- `lm create security JwtUtil`
- `lm create config Security`

---

## 🔗 Ressources complémentaires

- [📦 Guide d'installation](INSTALLATION.md)
- [⚡ Configuration autocomplétion](AUTOCOMPLETE.md)
- [🔄 Cycle de vie](LIFECYCLE.md)

---

[⬅️ Retour au README principal](../README.md)