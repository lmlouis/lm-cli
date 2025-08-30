## 📁 Architecture du projet Spring Boot
 ```
 .
 ├── docker/                            # Fichiers Docker & CI/CD
 │   ├── app.yml
 │   ├── postgres.yml
 │   └── service/
 ├── src/
 │   ├── main/
 │   │   ├── java/
 │   │   │   └── plateforme/
 │   │   │       └── ewawa/
 │   │   │           └── ewawa_api/
 │   │   │               ├── EwawaApiApplication.java
 │   │   │               ├── config/            # Configurations globales (CORS, Beans, etc.)
 │   │   │               ├── common/            # Exceptions, constantes, helpers, etc.
 │   │   │               ├── security/          # JWT, 2FA, gestion des tokens
 │   │   │               ├── pagination/        # Pagination personnalisée
 │   │   │               ├── filter/            # Filtres HTTP (ex: logs, auth)
 │   │   │               ├── dto/               # Objets d’entrée/sortie (Input/Output)
 │   │   │               ├── domain/
 │   │   │               │   ├── model/         # Entités JPA
 │   │   │               │   └── enumeration/   # Enums du domaine
 │   │   │               ├── repository/        # Interfaces JPA, Mongo, etc.
 │   │   │               ├── service/           # Services applicatifs (logique métier)
 │   │   │               └── web/
 │   │   │                   └── rest/          # Contrôleurs REST API
 │   │   └── resources/
 │   │       ├── application.yml
 │   │       ├── application-dev.yml
 │   │       ├── application-prod.yml
 │   │       ├── db/
 │   │       │   └── changelog/                # Scripts Liquibase
 │   │       ├── tls/                          # Certificats TLS/SSL
 │   │       ├── i18n/                         # Traductions
 │   │       └── static/                       # Fichiers statiques (si besoin)
 └── pom.xml
 ```
## Script de Création Automatique de Fichiers pour Spring Boot

Ce script bash permet de générer automatiquement différents types de fichiers pour un projet Spring Boot, afin de structurer rapidement les différentes parties de l'application. Vous pouvez l'utiliser pour créer des configurations, des exceptions, des constantes, des services, des contrôleurs REST, des repositories, et bien plus.

### Prérequis

- Un environnement Linux ou macOS avec un terminal bash.
- Un projet Spring Boot préexistant ou une structure de projet similaire.
- Basé sur le pom.xml

### Utilisation du Script

#### Commande générale
Afficher l'aide de la commande lm
```bash
 ./lm help     
```
Commandes disponibles:
```bash
    create config <name> [ --properties ]
    create exception <name>
    create constant <name>
    create security <name>
    create pagination
    create filter
    create dto <name> 
    create mapper <name> [ --init ]
    create domain <name> [ --enum | --entity ]
    create repository <name>
    create service <name> [ --mapper | --criteria | --query | --implement | --class ]
    create rest <name>
    create changelog <name> [ --init | --data | --sql ]
    create application <profile> [ --yml | --properties ]
```