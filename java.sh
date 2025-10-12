#!/bin/bash

# fichier java.sh
# Variables globales
export POM_FILE="pom.xml"
export FORCE_GLOBAL=false
export CUSTOM_PACKAGE=""
export BASE_DIR=""
export RESOURCES_DIR="src/main/resources"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Fonction d'affichage d'aide
function show_help() {
    echo "Usage: $0 [OPTIONS] <command> [subcommand] [name]"
    echo ""
    echo "Options globales:"
    echo "  --force           Écraser les fichiers existants"
    echo "  --package=NAME    Spécifier un package personnalisé"
    echo "  --help            Afficher cette aide"
    echo ""
    echo "Commandes disponibles:"
    echo "  create config <name> [--properties]"
    echo "  create exception <name>"
    echo "  create constant <name>"
    echo "  create security <name>"
    echo "  create pagination"
    echo "  create filter"
    echo "  create dto <name> [--record]"
    echo "  create mapper <name> [--init]"
    echo "  create domain <name> [--enum | --entity]"
    echo "  create repository <name>"
    echo "  create service <name> [--mapper | --criteria | --query | --implement | --class]"
    echo "  create rest <name>"
    echo "  create changelog <name> [--init | --data | --sql]"
    echo "  create application <profile> [--yml | --properties]"
    echo ""
    echo "Commandes de gestion:"
    echo "  update            Mettre à jour lm-cli"
    echo "  install [version] Installer une version spécifique"
    echo "  uninstall         Désinstaller lm-cli"
    echo "  version           Afficher la version"
    echo ""
    echo "Exemples:"
    echo "  $0 create service UserService --mapper --implement"
    echo "  $0 --force create domain Product --entity"
    echo "  $0 --package=com.example create rest UserResource"
    echo "  $0 update"
    echo "  $0 install 1.1.2"
    echo "  $0 version"
    echo ""
}

# Fonction pour créer le fichier version.txt si absent
function create_version_file_if_missing() {
    local version_file="$SCRIPT_DIR/version.txt"

    if [ ! -f "$version_file" ]; then
        echo "1.1.3" > "$version_file"
        echo "✅ Fichier version.txt créé avec la version 1.1.3"
    fi
}

# Fonction pour afficher la version
function show_version() {
    local version_file="$SCRIPT_DIR/version.txt"

    if [ -f "$version_file" ]; then
        local version=$(cat "$version_file")
        echo "lm-cli version $version"
    else
        # Essayer de trouver version.txt dans le répertoire d'installation
        local install_version_file="$HOME/.lm-cli/version.txt"
        if [ -f "$install_version_file" ]; then
            local version=$(cat "$install_version_file")
            echo "lm-cli version $version"
        else
            echo "lm-cli version inconnue"
            echo "ℹ️  Le fichier version.txt n'a pas été trouvé"
            echo "📁 Recherché dans:"
            echo "   - $version_file"
            echo "   - $install_version_file"
        fi
    fi
}

# Fonction pour mettre à jour lm-cli
function update_cli() {
    echo "🔍 Recherche de mises à jour..."

    local current_version="unknown"
    local version_file="$SCRIPT_DIR/version.txt"

    if [ -f "$version_file" ]; then
        current_version=$(cat "$version_file")
        echo "Version actuelle: $current_version"
    fi

    # Utiliser le script update.sh s'il existe
    if [ -f "$SCRIPT_DIR/update.sh" ]; then
        echo "📦 Mise à jour via le script de mise à jour..."
        bash "$SCRIPT_DIR/update.sh" --force
    # Sinon utiliser install.sh avec les bonnes options
    elif [ -f "$SCRIPT_DIR/install.sh" ]; then
        echo "📦 Mise à jour via le script d'installation..."
        local latest_version=$(get_latest_release)
        echo "📥 Installation de la version $latest_version..."
        bash "$SCRIPT_DIR/install.sh" -v "$latest_version"
    else
        echo "❌ Aucun script de mise à jour trouvé dans $SCRIPT_DIR"
        echo "ℹ️  Téléchargez la dernière version depuis:"
        echo "   https://github.com/lmlouis/lm-cli/releases"
        echo "   ou exécutez: curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash"
    fi
}

# Fonction pour récupérer la dernière release depuis GitHub
function get_latest_release() {
    local repo_owner="lmlouis"
    local repo_name="lm-cli"
    local api_url="https://api.github.com/repos/$repo_owner/$repo_name/releases/latest"

    if command -v curl &> /dev/null; then
        curl -s $api_url | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
    elif command -v wget &> /dev/null; then
        wget -q -O - $api_url | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
    else
        echo "latest"
    fi
}

# Fonction pour installer une version spécifique
function install_version() {
    local version=$1
    echo "📦 Installation de la version $version..."

    if [ -f "$SCRIPT_DIR/install.sh" ]; then
        if [ -n "$version" ] && [ "$version" != "latest" ]; then
            bash "$SCRIPT_DIR/install.sh" --version "$version"
        else
            bash "$SCRIPT_DIR/install.sh"
        fi
    else
        echo "❌ Script d'installation non trouvé dans $SCRIPT_DIR"
        echo "ℹ️  Téléchargez manuellement depuis:"
        echo "   https://github.com/lmlouis/lm-cli/releases"
        echo "   ou exécutez: curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash"
    fi
}

# Fonction pour désinstaller
function uninstall_cli() {
    echo "🗑️  Désinstallation de lm-cli..."

    local install_dir="$HOME/.lm-cli"
    local bin_dir="$HOME/.local/bin"

    if [ -f "$SCRIPT_DIR/uninstall.sh" ]; then
        bash "$SCRIPT_DIR/uninstall.sh"
    elif [ -f "$SCRIPT_DIR/install.sh" ]; then
        bash "$SCRIPT_DIR/install.sh" --uninstall
    else
        echo "❌ Script de désinstallation non trouvé"
        echo "ℹ️  Supprimez manuellement les fichiers:"
        echo "   - $install_dir"
        echo "   - $bin_dir/lm"
        echo "   - Nettoyez votre .bashrc ou .zshrc (section lm-cli)"

        # Option de suppression manuelle
        read -p "Voulez-vous supprimer manuellement? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$install_dir"
            rm -f "$bin_dir/lm"
            echo "✅ Fichiers supprimés"
        fi
    fi
}

# Fonction de capitalisation
function capitalize() {
    local name=$1
    echo "$name" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' | tr -d ' '
}

# Fonction pour récupérer le package name de base
function get_base_package_name() {
    # Essayer de trouver le pom.xml dans le répertoire courant ou les parents
    local current_dir="$PWD"
    local pom_file=""

    # Rechercher le pom.xml dans le répertoire courant et les parents
    while [[ "$current_dir" != "" && ! -e "$current_dir/pom.xml" ]]; do
        current_dir="${current_dir%/*}"
    done

    if [[ -n "$current_dir" && -f "$current_dir/pom.xml" ]]; then
        pom_file="$current_dir/pom.xml"
        echo "DEBUG: Found pom.xml at: $pom_file" >&2
    else
        echo "✘ Fichier pom.xml introuvable dans le dossier courant ou les répertoires parents." >&2
        echo "✘ Assurez-vous d'être dans un projet Spring Boot avec un fichier pom.xml" >&2
        exit 1
    fi

    # Essayer d'abord avec Maven
    local group_id=""
    local artifact_id=""

    # Changer temporairement vers le répertoire du pom.xml pour exécuter Maven
    local original_dir="$PWD"
    cd "$(dirname "$pom_file")"

    group_id=$(mvn help:evaluate -Dexpression=project.groupId -q -DforceStdout 2>/dev/null)
    artifact_id=$(mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout 2>/dev/null)

    # Revenir au répertoire original
    cd "$original_dir"

    # Fallback sur xmllint si Maven échoue
    if [ -z "$group_id" ]; then
        group_id=$(xmllint --xpath "/*[local-name()='project']/*[local-name()='groupId']/text()" "$pom_file" 2>/dev/null || xmllint --xpath "/*[local-name()='project']/*[local-name()='parent']/*[local-name()='groupId']/text()" "$pom_file" 2>/dev/null)
    fi

    if [ -z "$artifact_id" ]; then
        artifact_id=$(xmllint --xpath "/*[local-name()='project']/*[local-name()='artifactId']/text()" "$pom_file" 2>/dev/null)
    fi

    if [ -z "$group_id" ] || [ -z "$artifact_id" ]; then
        echo "✘ Impossible de lire groupId ou artifactId depuis pom.xml" >&2
        echo "✘ Vérifiez que votre pom.xml est valide" >&2
        exit 1
    fi

    # Nettoyer l'artifact_id (remplacer les tirets par des points)
    local clean_artifact_id="${artifact_id//-/.}"
    echo "$group_id.$clean_artifact_id"
}

# Fonction de création de fichier
function create_file() {
    local dir=$1
    local filename=$2
    local content=$3
    local force=${4:-false}

    mkdir -p "$dir"

    if [ -f "$dir/$filename" ] && [ "$force" != true ]; then
        echo "⚠ Fichier existant : $dir/$filename (utilisez --force pour écraser)"
        return 1
    else
        echo "$content" > "$dir/$filename"
        echo "✔ Fichier créé : $dir/$filename"
        return 0
    fi
}

# Fonction pour traiter les options globales
function parse_global_options() {
    local args=("$@")
    local remaining_args=()

    # shellcheck disable=SC2145
    echo "DEBUG: Parsing args: ${args[@]}" >&2

    for arg in "${args[@]}"; do
        case "$arg" in
            --force)
                FORCE_GLOBAL=true
                echo "DEBUG: Set FORCE_GLOBAL=true" >&2
                ;;
            --package=*)
                CUSTOM_PACKAGE="${arg#--package=}"
                echo "DEBUG: Set CUSTOM_PACKAGE='$CUSTOM_PACKAGE'" >&2
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                remaining_args+=("$arg")
                ;;
        esac
    done

    # shellcheck disable=SC2145
    echo "DEBUG: Remaining args: ${remaining_args[@]}" >&2

    # Retourner les valeurs via des variables globales
    export FORCE_GLOBAL
    export CUSTOM_PACKAGE

    echo "${remaining_args[@]}"
}

# Initialisation du package et des répertoires
function initialize_package() {
    local base_package=""

    # Essayer de récupérer le package de base depuis pom.xml
    if base_package=$(get_base_package_name); then
        # Si un package personnalisé est spécifié, on l'ajoute au package de base
        if [ -n "$CUSTOM_PACKAGE" ]; then
            PACKAGE_NAME="${base_package}.${CUSTOM_PACKAGE}"
        else
            PACKAGE_NAME="$base_package"
        fi
    else
        # Fallback si pas de pom.xml trouvé
        if [ -n "$CUSTOM_PACKAGE" ]; then
            PACKAGE_NAME="com.example.${CUSTOM_PACKAGE}"
        else
            PACKAGE_NAME="com.example.application"
        fi
        echo "⚠ Utilisation du package par défaut: $PACKAGE_NAME" >&2
    fi

    # Nettoyer le package name (supprimer les tirets)
    PACKAGE_NAME=$(echo "$PACKAGE_NAME" | sed 's/-//g')
    PACKAGE_PATH="${PACKAGE_NAME//.//}"
    BASE_DIR="src/main/java/$PACKAGE_PATH"

    echo "Package: $PACKAGE_NAME"
    echo "Base directory: $BASE_DIR"
}

# Traitement des commandes principales
function process_command() {
    local command_args=("$@")
    local COMMAND=${command_args[0]}
    local SUBCOMMAND=${command_args[1]}
    local NAME=${command_args[2]}
    local OPTIONS=("${command_args[@]:3}")

    # Commandes qui ne nécessitent pas de projet Spring Boot
    case "$COMMAND" in
        update)
            update_cli
            return 0
            ;;
        install)
            install_version "$SUBCOMMAND"
            return 0
            ;;
        uninstall)
            uninstall_cli
            return 0
            ;;
        version)
            show_version
            return 0
            ;;
        --help|-h)
            show_help
            return 0
            ;;
    esac

    # Les commandes create nécessitent un projet Spring Boot
    if [ "$COMMAND" != "create" ]; then
        echo "✘ Commande invalide : $COMMAND"
        show_help
        exit 1
    fi

    # Validation des arguments minimum pour create
    if [ -z "$SUBCOMMAND" ]; then
        echo "✘ Sous-commande manquante"
        show_help
        exit 1
    fi

    # Pour les commandes create, initialiser le package
    initialize_package

    case "$SUBCOMMAND" in
        config|exception|constant|security|dto|domain|repository|service|rest|changelog|application)
            if [ -z "$NAME" ] && [ "$SUBCOMMAND" != "pagination" ] && [ "$SUBCOMMAND" != "filter" ] && [ "$SUBCOMMAND" != "changelog" ]; then
                echo "✘ Nom manquant pour la sous-commande $SUBCOMMAND"
                show_help
                exit 1
            fi
            ;;
    esac

    local CLASS_NAME=$(capitalize "$NAME")
    local JAVA_PACKAGE="$PACKAGE_NAME"

    case "$SUBCOMMAND" in
        config)
            process_config "$CLASS_NAME" "$NAME" "${OPTIONS[@]}"
            ;;
        exception)
            process_exception "$CLASS_NAME" "$JAVA_PACKAGE"
            ;;
        constant)
            process_constant "$CLASS_NAME" "$JAVA_PACKAGE"
            ;;
        security)
            process_security "$CLASS_NAME" "$JAVA_PACKAGE"
            ;;
        pagination)
            process_pagination "$JAVA_PACKAGE"
            ;;
        filter)
            process_filter "$JAVA_PACKAGE"
            ;;
        dto)
            process_dto "$CLASS_NAME" "$JAVA_PACKAGE" "${OPTIONS[@]}"
            ;;
        mapper)
            process_mapper "$CLASS_NAME" "$JAVA_PACKAGE" "${OPTIONS[@]}"
            ;;
        domain)
            process_domain "$CLASS_NAME" "$JAVA_PACKAGE" "${OPTIONS[@]}"
            ;;
        repository)
            process_repository "$CLASS_NAME" "$JAVA_PACKAGE"
            ;;
        service)
            process_service "$CLASS_NAME" "$JAVA_PACKAGE" "${OPTIONS[@]}"
            ;;
        rest)
            process_rest "$CLASS_NAME" "$JAVA_PACKAGE" "$NAME"
            ;;
        changelog)
            process_changelog "$NAME" "${OPTIONS[@]}"
            ;;
        application)
            process_application "$NAME" "${OPTIONS[@]}"
            ;;
        *)
            echo "✘ Sous-commande invalide : $SUBCOMMAND"
            show_help
            exit 1
            ;;
    esac
}

# Fonctions de traitement par type
function process_config() {
    local CLASS_NAME=$1
    local NAME=$2
    shift 2
    local OPTIONS=("$@")

    local option=""
    for opt in "${OPTIONS[@]}"; do
        case "$opt" in
            --properties) option="properties" ;;
            --force) ;; # déjà géré globalement
            *) echo "⚠ Option inconnue pour config: $opt" ;;
        esac
    done

    if [ "$option" == "properties" ]; then
        create_file "$BASE_DIR/config" "${CLASS_NAME}Properties.java" "package $JAVA_PACKAGE.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = \"${NAME//-/.}\")
public class ${CLASS_NAME}Properties {
    // Ajoute tes propriétés ici
}" "$FORCE_GLOBAL"
    else
        create_file "$BASE_DIR/config" "${CLASS_NAME}Config.java" "package $JAVA_PACKAGE.config;

import org.springframework.context.annotation.Configuration;

@Configuration
public class ${CLASS_NAME}Config {
    // Configuration ici
}" "$FORCE_GLOBAL"
    fi
}

function process_exception() {
    local CLASS_NAME=$1
    local JAVA_PACKAGE=$2

    create_file "$BASE_DIR/exception" "${CLASS_NAME}Exception.java" "package $JAVA_PACKAGE.exception;

public class ${CLASS_NAME}Exception extends RuntimeException {
    public ${CLASS_NAME}Exception(String message) {
        super(message);
    }

    public ${CLASS_NAME}Exception(String message, Throwable cause) {
        super(message, cause);
    }
}" "$FORCE_GLOBAL"
}

function process_constant() {
    local CLASS_NAME=$1
    local JAVA_PACKAGE=$2

    create_file "$BASE_DIR/constant" "${CLASS_NAME}Constant.java" "package $JAVA_PACKAGE.constant;

public final class ${CLASS_NAME}Constant {
    private ${CLASS_NAME}Constant() {}

    // Définir vos constantes ici
}" "$FORCE_GLOBAL"
}

function process_security() {
    local CLASS_NAME=$1
    local JAVA_PACKAGE=$2

    create_file "$BASE_DIR/security" "${CLASS_NAME}.java" "package $JAVA_PACKAGE.security;

import org.springframework.stereotype.Component;

@Component
public class ${CLASS_NAME} {
    // Configuration de sécurité ici
}" "$FORCE_GLOBAL"
}

function process_pagination() {
    local JAVA_PACKAGE=$1

    create_file "$BASE_DIR/model" "Pagination.java" "package $JAVA_PACKAGE.model;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

public class Pagination {
    public static Pageable createPageable(Integer page, Integer size) {
        if (page == null || size == null) {
            return Pageable.unpaged();
        }
        return PageRequest.of(page, size);
    }
}" "$FORCE_GLOBAL"
}

function process_filter() {
    local JAVA_PACKAGE=$1

    create_file "$BASE_DIR/filter" "RequestFilter.java" "package $JAVA_PACKAGE.filter;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;

public class RequestFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialisation du filtre
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        // Logique du filtre
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Nettoyage du filtre
    }
}" "$FORCE_GLOBAL"
}

function process_dto() {
    local CLASS_NAME=$1
    local JAVA_PACKAGE=$2
    shift 2
    local OPTIONS=("$@")

    local is_record=false
    for opt in "${OPTIONS[@]}"; do
        case "$opt" in
            --record) is_record=true ;;
            --force) ;; # déjà géré globalement
            *) echo "⚠ Option inconnue pour dto: $opt" ;;
        esac
    done

    if [ "$is_record" = true ]; then
        create_file "$BASE_DIR/dto/record" "${CLASS_NAME}Record.java" "package $JAVA_PACKAGE.dto.record;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = \"Enregistrement de ${CLASS_NAME}\")
public record ${CLASS_NAME}Record(
    // Définir les champs du record ici
) {}" "$FORCE_GLOBAL"
    else
        create_file "$BASE_DIR/dto" "${CLASS_NAME}DTO.java" "package $JAVA_PACKAGE.dto;

public class ${CLASS_NAME}DTO {
    // Propriétés du DTO
}" "$FORCE_GLOBAL"
    fi
}

function process_mapper() {
    local CLASS_NAME=$1
    local JAVA_PACKAGE=$2
    shift 2
    local OPTIONS=("$@")

    local is_init=false
    for opt in "${OPTIONS[@]}"; do
        case "$opt" in
            --init) is_init=true ;;
            --force) ;; # déjà géré globalement
            *) echo "⚠ Option inconnue pour mapper: $opt" ;;
        esac
    done

    if [ "$is_init" = true ]; then
        create_file "$BASE_DIR/mapper" "EntityMapper.java" "package $JAVA_PACKAGE.mapper;

import java.util.List;
import org.mapstruct.BeanMapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.Named;
import org.mapstruct.NullValuePropertyMappingStrategy;

/**
 * Contract for a generic dto to entity mapper.
 *
 * @param <D> - DTO type parameter.
 * @param <E> - Entity type parameter.
 */
public interface EntityMapper<D, E> {
    E toEntity(D dto);

    D toDto(E entity);

    List<E> toEntity(List<D> dtoList);

    List<D> toDto(List<E> entityList);

    @Named(\"partialUpdate\")
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void partialUpdate(@MappingTarget E entity, D dto);
}" "$FORCE_GLOBAL"
    else
        create_file "$BASE_DIR/mapper" "${CLASS_NAME}Mapper.java" "package $JAVA_PACKAGE.mapper;

import org.mapstruct.Mapper;
import $JAVA_PACKAGE.dto.${CLASS_NAME}DTO;
import $JAVA_PACKAGE.domain.entity.${CLASS_NAME};

@Mapper(componentModel = \"spring\")
public interface ${CLASS_NAME}Mapper extends EntityMapper<${CLASS_NAME}DTO, ${CLASS_NAME}> {
    // Mappings spécifiques ici
}" "$FORCE_GLOBAL"
    fi
}

function process_domain() {
    local CLASS_NAME=$1
    local JAVA_PACKAGE=$2
    shift 2
    local OPTIONS=("$@")

    local option="entity"
    for opt in "${OPTIONS[@]}"; do
        case "$opt" in
            --enum) option="enum" ;;
            --entity) option="entity" ;;
            --force) ;; # déjà géré globalement
            *) echo "⚠ Option inconnue pour domain: $opt" ;;
        esac
    done

    if [ "$option" == "enum" ]; then
        create_file "$BASE_DIR/domain/enumeration" "${CLASS_NAME}.java" "package $JAVA_PACKAGE.domain.enumeration;

public enum ${CLASS_NAME} {
    // Valeurs de l'énumération
}" "$FORCE_GLOBAL"
    else
        create_file "$BASE_DIR/domain/entity" "${CLASS_NAME}.java" "package $JAVA_PACKAGE.domain.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = \"${NAME,,}\")
public class ${CLASS_NAME} {

    @Id
    @GeneratedValue
    @Column(name = \"id\")
    private UUID id;

    @Column(name = \"created_date\")
    private LocalDateTime createdDate = LocalDateTime.now();

    // Ajouter d'autres colonnes ici

    // Getters et setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public LocalDateTime getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(LocalDateTime createdDate) {
        this.createdDate = createdDate;
    }
}" "$FORCE_GLOBAL"
    fi
}

function process_repository() {
    local CLASS_NAME=$1
    local JAVA_PACKAGE=$2

    create_file "$BASE_DIR/repository" "${CLASS_NAME}Repository.java" "package $JAVA_PACKAGE.repository;

import org.springframework.data.jpa.repository.*;
import org.springframework.stereotype.Repository;
import $JAVA_PACKAGE.domain.entity.${CLASS_NAME};
import java.util.UUID;

@Repository
public interface ${CLASS_NAME}Repository extends JpaRepository<${CLASS_NAME}, UUID>, JpaSpecificationExecutor<${CLASS_NAME}> {
    // Méthodes de requête personnalisées ici
}" "$FORCE_GLOBAL"
}

function process_service() {
    local CLASS_NAME=$1
    local JAVA_PACKAGE=$2
    shift 2
    local OPTIONS=("$@")

    if [ ${#OPTIONS[@]} -eq 0 ]; then
        create_file "$BASE_DIR/service" "${CLASS_NAME}Service.java" "package $JAVA_PACKAGE.service;

public interface ${CLASS_NAME}Service {
    // Méthodes du service
}" "$FORCE_GLOBAL"
    else
        for opt in "${OPTIONS[@]}"; do
            case "$opt" in
                --mapper)
                    create_file "$BASE_DIR/service/mapper" "${CLASS_NAME}Mapper.java" "package $JAVA_PACKAGE.service.mapper;

import org.mapstruct.Mapper;
import $JAVA_PACKAGE.dto.${CLASS_NAME}DTO;
import $JAVA_PACKAGE.domain.entity.${CLASS_NAME};

@Mapper(componentModel = \"spring\")
public interface ${CLASS_NAME}Mapper {
    ${CLASS_NAME}DTO toDto(${CLASS_NAME} entity);
    ${CLASS_NAME} toEntity(${CLASS_NAME}DTO dto);
}" "$FORCE_GLOBAL"
                    ;;
                --criteria)
                    create_file "$BASE_DIR/service/criteria" "${CLASS_NAME}Criteria.java" "package $JAVA_PACKAGE.service.criteria;

public class ${CLASS_NAME}Criteria {
    // Critères de recherche
}" "$FORCE_GLOBAL"
                    ;;
                --query)
                    create_file "$BASE_DIR/service" "${CLASS_NAME}QueryService.java" "package $JAVA_PACKAGE.service;

import org.springframework.stereotype.Service;

@Service
public class ${CLASS_NAME}QueryService {
    // Service de requête
}" "$FORCE_GLOBAL"
                    ;;
                --implement)
                    create_file "$BASE_DIR/service/impl" "${CLASS_NAME}ServiceImpl.java" "package $JAVA_PACKAGE.service.impl;

import org.springframework.stereotype.Service;
import $JAVA_PACKAGE.service.${CLASS_NAME}Service;

@Service
public class ${CLASS_NAME}ServiceImpl implements ${CLASS_NAME}Service {
    // Implémentation du service
}" "$FORCE_GLOBAL"
                    ;;
                --class)
                    create_file "$BASE_DIR/service" "${CLASS_NAME}Service.java" "package $JAVA_PACKAGE.service;

import org.springframework.stereotype.Service;

@Service
public class ${CLASS_NAME}Service {
    // Service sous forme de classe
}" "$FORCE_GLOBAL"
                    ;;
                --force) ;; # déjà géré globalement
                *)
                    echo "⚠ Option inconnue pour service: $opt"
                    ;;
            esac
        done
    fi
}

function process_rest() {
    local CLASS_NAME=$1
    local JAVA_PACKAGE=$2
    local NAME=$3

    create_file "$BASE_DIR/web/rest" "${CLASS_NAME}Resource.java" "package $JAVA_PACKAGE.web.rest;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

@RestController
@RequestMapping(\"/api/${NAME,,}\")
public class ${CLASS_NAME}Resource {

    @GetMapping
    public ResponseEntity<String> getAll() {
        return ResponseEntity.ok(\"Get all ${NAME}\");
    }

    // Ajouter d'autres endpoints ici
}" "$FORCE_GLOBAL"
}

function process_changelog() {
    local NAME=$1
    shift 1
    local OPTIONS=("$@")

    local option="changelog"
    for opt in "${OPTIONS[@]}"; do
        case "$opt" in
            --init) option="init" ;;
            --data) option="data" ;;
            --sql) option="sql" ;;
            --force) ;; # déjà géré globalement
            *) echo "⚠ Option inconnue pour changelog: $opt" ;;
        esac
    done

    case "$option" in
        init)
            create_file "$RESOURCES_DIR/db/changelog" "master.xml" "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<databaseChangeLog
    xmlns=\"http://www.liquibase.org/xml/ns/dbchangelog\"
    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
    xsi:schemaLocation=\"http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-latest.xsd\">

    <!-- Changelog Liquibase initial -->
    <property name=\"now\" value=\"current_timestamp\" dbms=\"postgresql\"/>
    <property name=\"floatType\" value=\"float4\" dbms=\"postgresql\"/>
    <property name=\"clobType\" value=\"clob\" dbms=\"postgresql\"/>
    <property name=\"blobType\" value=\"blob\" dbms=\"postgresql\"/>
    <property name=\"uuidType\" value=\"uuid\" dbms=\"postgresql\"/>
    <property name=\"datetimeType\" value=\"datetime\" dbms=\"postgresql\"/>
    <property name=\"timeType\" value=\"time(6)\" dbms=\"postgresql\"/>

    <!-- Inclure les changelogs ici -->
    <!-- <include file=\"db/changelog/changes/*.xml\" relativeToChangelogFile=\"true\"/> -->

</databaseChangeLog>" "$FORCE_GLOBAL"
            ;;
        data)
            timestamp=$(date +"%Y%m%d%H%M%S")
            create_file "$RESOURCES_DIR/db/data" "${timestamp}_${NAME}.csv" "# Données pour ${NAME}
# ID,NAME,CREATED_DATE
1,${NAME},$(date +"%Y-%m-%d %H:%M:%S")" "$FORCE_GLOBAL"
            ;;
        sql)
            timestamp=$(date +"%Y%m%d%H%M%S")
            create_file "$RESOURCES_DIR/db/sql" "${timestamp}_${NAME}.sql" "-- Script SQL pour ${NAME}
-- ${timestamp}

-- CREATE TABLE IF NOT EXISTS ${NAME} (
--     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--     name VARCHAR(255) NOT NULL,
--     created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- INSERT INTO ${NAME} (name) VALUES ('exemple');" "$FORCE_GLOBAL"
            ;;
        *)
            timestamp=$(date +"%Y%m%d%H%M%S")
            create_file "$RESOURCES_DIR/db/changelog/changes" "${timestamp}_${NAME}.xml" "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<databaseChangeLog
    xmlns=\"http://www.liquibase.org/xml/ns/dbchangelog\"
    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
    xsi:schemaLocation=\"http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-latest.xsd\">

    <!-- Changelog pour ${NAME} -->
    <changeSet id=\"${timestamp}-1\" author=\"${USER:-system}\">
        <comment>Création de la table ${NAME}</comment>
        <!--
        <createTable tableName=\"${NAME}\">
            <column name=\"id\" type=\"UUID\">
                <constraints primaryKey=\"true\" nullable=\"false\"/>
            </column>
            <column name=\"created_date\" type=\"TIMESTAMP\" defaultValueComputed=\"CURRENT_TIMESTAMP\"/>
        </createTable>
        -->
    </changeSet>
</databaseChangeLog>" "$FORCE_GLOBAL"
            ;;
    esac
}

function process_application() {
    local PROFILE=$1
    shift 1
    local OPTIONS=("$@")

    local extension="yml"
    for opt in "${OPTIONS[@]}"; do
        case "$opt" in
            --properties) extension="properties" ;;
            --yml) extension="yml" ;;
            --force) ;; # déjà géré globalement
            *) echo "⚠ Option inconnue pour application: $opt" ;;
        esac
    done

    if [ "$extension" == "properties" ]; then
        create_file "$RESOURCES_DIR" "application-${PROFILE}.properties" "# Configuration Spring Boot - Profile: ${PROFILE}
server.port=8080
spring.application.name=${PROFILE}
# Configuration datasource
# spring.datasource.url=jdbc:postgresql://localhost:5432/${PROFILE}
# spring.datasource.username=username
# spring.datasource.password=password" "$FORCE_GLOBAL"
    else
        create_file "$RESOURCES_DIR" "application-${PROFILE}.yml" "# Configuration Spring Boot - Profile: ${PROFILE}
server:
  port: 8080

spring:
  application:
    name: ${PROFILE}
  datasource:
    url: jdbc:postgresql://localhost:5432/${PROFILE}
    username: username
    password: password

logging:
  level:
    com.example: DEBUG" "$FORCE_GLOBAL"
    fi
}

# Point d'entrée principal
main() {
     # Créer le fichier version.txt si absent
    create_version_file_if_missing

    # Vérifier si aucun argument n'est fourni
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    echo "=== DEBUG START ===" >&2
    # shellcheck disable=SC2145
    echo "Original args: $@" >&2

    # Traiter les options globales directement dans main
    local remaining_args=()
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                FORCE_GLOBAL=true
                echo "DEBUG: Set FORCE_GLOBAL=true" >&2
                shift
                ;;
            --package=*)
                CUSTOM_PACKAGE="${1#--package=}"
                echo "DEBUG: Set CUSTOM_PACKAGE='$CUSTOM_PACKAGE'" >&2
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                remaining_args+=("$1")
                shift
                ;;
        esac
    done

    echo "DEBUG: CUSTOM_PACKAGE='$CUSTOM_PACKAGE'" >&2
    echo "DEBUG: FORCE_GLOBAL='$FORCE_GLOBAL'" >&2
    # shellcheck disable=SC2145
    echo "DEBUG: Remaining args: ${remaining_args[@]}" >&2
    echo "=== DEBUG END ===" >&2

    # Réinitialiser les arguments avec les arguments restants
    set -- "${remaining_args[@]}"

    # NE PAS initialiser le package ici - cela sera fait dans process_command si nécessaire
    # Traiter la commande
    process_command "$@"
}

# Lancer le script
main "$@"