#!/bin/bash

POM_FILE="pom.xml"

if [ ! -f "$POM_FILE" ]; then
    echo "✘ Fichier pom.xml introuvable." >&2
    exit 1
fi

group_id=$(mvn help:evaluate -Dexpression=project.groupId -q -DforceStdout)
artifact_id=$(mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout)

if [ -z "$group_id" ] || [ -z "$artifact_id" ]; then
    echo "✘ Impossible de lire groupId ou artifactId depuis pom.xml" >&2
    exit 1
fi

if [ -z "$group_id" ] || [ -z "$artifact_id" ]; then
    echo "✘ Impossible de lire groupId ou artifactId depuis pom.xml" >&2
    exit 1
fi

PACKAGE_NAME="$group_id.${artifact_id//-/_}"  # Supprime les tirets
PACKAGE_PATH="${PACKAGE_NAME//.//}"         # Convertit les points en chemin
BASE_DIR="src/main/java/$PACKAGE_PATH"
RESOURCES_DIR="src/main/resources"


function show_help() {
    echo "Usage: $0 <command> <subcommand> <name> [option | --force]"
    echo ""
    echo "Commandes disponibles:"
    echo "  create config <name> [ --properties ]"
    echo "  create exception <name>"
    echo "  create constant <name>"
    echo "  create security <name>"
    echo "  create pagination"
    echo "  create filter"
    echo "  create dto <name> "
    echo "  create mapper <name> [ --init ]"
    echo "  create domain <name> [ --enum | --entity ]"
    echo "  create repository <name>"
    echo "  create service <name> [ --mapper | --criteria | --query | --implement | --class ]"
    echo "  create rest <name>"
    echo "  create changelog <name> [ --init | --data | --sql ]"
    echo "  create application <profile> [ --yml | --properties ]"
    echo ""
}
function capitalize() {
    # Remplacer les tirets par des majuscules, sans ajouter de lettres inutiles
    local name=$1
    # Remplacer les tirets par des espaces, puis convertir chaque mot en majuscule
    echo "$name" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' | tr -d ' '
}

function get_package_name() {
    if [ ! -f "$POM_FILE" ]; then
        echo "✘ Fichier pom.xml introuvable dans le dossier courant." >&2
        exit 1
    fi

    # Priorité : project > parent
    group_id=$(xmllint --xpath "/*[local-name()='project']/*[local-name()='groupId']/text()" "$POM_FILE" 2>/dev/null)
    if [ -z "$group_id" ]; then
        group_id=$(xmllint --xpath "/*[local-name()='project']/*[local-name()='parent']/*[local-name()='groupId']/text()" "$POM_FILE" 2>/dev/null)
    fi

    artifact_id=$(xmllint --xpath "/*[local-name()='project']/*[local-name()='artifactId']/text()" "$POM_FILE" 2>/dev/null)

    if [ -z "$group_id" ] || [ -z "$artifact_id" ]; then
        echo "✘ Impossible de lire groupId ou artifactId depuis pom.xml" >&2
        exit 1
    fi

    echo "$group_id.${artifact_id//-/_}"
}



function create_file() {
    local dir=$1
    local filename=$2
    local content=$3

    mkdir -p "$dir"

    FORCE=false
    if [ "$OPTION" == "--force" ]; then
        FORCE=true
    fi

    if [ -f "$dir/$filename" ] && [ "$FORCE" != true ]; then
        echo "⚠ Fichier existant : $dir/$filename"
    else
        echo "$content" > "$dir/$filename"
        echo "✔ Fichier créé : $dir/$filename"
    fi
}



# Vérification des arguments
if [ $# -lt 3 ]; then
    show_help
    exit 1
fi

COMMAND=$1
SUBCOMMAND=$2
NAME=$3
OPTION=$4
CLASS_NAME=$(capitalize "$NAME")
JAVA_PACKAGE="$PACKAGE_NAME"
PACKAGE_PATH=$(echo "$PACKAGE_NAME" | sed 's/\./\//g')
JAVA_PACKAGE="$PACKAGE_NAME"

if [ "$COMMAND" != "create" ]; then
    show_help
    exit 1
fi

case "$SUBCOMMAND" in
    config)
      if [ "$OPTION" == "--properties" ]; then
        create_file "$BASE_DIR/config" "${CLASS_NAME}Properties.java" "package $JAVA_PACKAGE.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = \"${NAME//-/.}\")
public class ${CLASS_NAME}Properties {
    // Ajoute tes propriétés ici
}"
      else
        create_file "$BASE_DIR/config" "${CLASS_NAME}Config.java" "package $JAVA_PACKAGE.config;

import org.springframework.context.annotation.Configuration;

@Configuration
public class ${CLASS_NAME}Config {
    // Configuration ici
}"
      fi
      ;;
    exception)
        create_file "$BASE_DIR/common" "${CLASS_NAME}Exception.java" "package $JAVA_PACKAGE.common;

public class ${CLASS_NAME}Exception extends RuntimeException {
    public ${CLASS_NAME}Exception(String message) {
        super(message);
    }
}"
        ;;
    constant)
        create_file "$BASE_DIR/common" "${CLASS_NAME}Constant.java" "package $JAVA_PACKAGE.common;

public final class ${CLASS_NAME}Constant {
    private ${CLASS_NAME}Constant() {}
}"
        ;;
    security)
        create_file "$BASE_DIR/security" "${CLASS_NAME}.java" "package $JAVA_PACKAGE.security;

public class ${CLASS_NAME} {
}"
        ;;
    pagination)
        create_file "$BASE_DIR/pagination" "Pagination.java" "package $JAVA_PACKAGE.pagination;

import org.springframework.data.domain.PageRequest;

public class Pagination {
    // Classe de pagination ici
}"
        ;;
    filter)
        create_file "$BASE_DIR/filter" "RequestFilter.java" "package $JAVA_PACKAGE.filter;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class RequestFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        chain.doFilter(request, response);
    }
}"
        ;;
    dto)
        create_file "$BASE_DIR/dto" "${CLASS_NAME}DTO.java" "package $JAVA_PACKAGE.dto;

public class ${CLASS_NAME}DTO {
    // Propriétés du DTO
}"
        ;;
    mapper)
        if [ "$OPTION" == "--init" ]; then
            create_file "$BASE_DIR/dto/mapper" "EntityMapper.java" "package $JAVA_PACKAGE.dto.mapper;

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
}"
        else
            create_file "$BASE_DIR/dto/mapper" "${CLASS_NAME}Mapper.java" "package $JAVA_PACKAGE.dto.mapper;

import org.mapstruct.Mapper;

@Mapper(componentModel = \"spring\")
public interface ${CLASS_NAME}Mapper extends EntityMapper<DTO, Entity> {
    // Propriétés du Mapper
}"
        fi
        ;;
    domain)
        if [ "$OPTION" == "--enum" ]; then
            create_file "$BASE_DIR/domain/enumeration" "${CLASS_NAME}Enum.java" "package $JAVA_PACKAGE.domain.enumeration;

public enum ${CLASS_NAME}Enum {
}"
        else
            create_file "$BASE_DIR/domain" "${CLASS_NAME}.java" "package $JAVA_PACKAGE.domain;

import jakarta.persistence.*;
import java.util.UUID;
@Entity
public class ${CLASS_NAME} {
    @Id
    @GeneratedValue
    @Column(name = \"id\")
    private UUID id;
}"
        fi
        ;;
    repository)
        create_file "$BASE_DIR/repository" "${CLASS_NAME}Repository.java" "package $JAVA_PACKAGE.repository;

import java.util.UUID;
import org.springframework.data.jpa.repository.*;
import org.springframework.stereotype.Repository;
import $JAVA_PACKAGE.domain.${CLASS_NAME};
@Repository
public interface ${CLASS_NAME}Repository extends JpaRepository<${CLASS_NAME}, UUID>, JpaSpecificationExecutor<${CLASS_NAME}> {
}"
        ;;
    service)
        # Toutes les options à partir du 4ᵉ argument
        OPTIONS=()
        if [ $# -ge 4 ]; then
            OPTIONS=("${@:4}")
        fi
        if [ ${#OPTIONS[@]} -eq 0 ]; then
            create_file "$BASE_DIR/service" "${CLASS_NAME}Service.java" "package $JAVA_PACKAGE.service;


public interface ${CLASS_NAME}Service {
}"
        else
            for opt in "${OPTIONS[@]}"; do
                case "$opt" in
                    --mapper)
                        create_file "$BASE_DIR/service/mapper" "${CLASS_NAME}Mapper.java" "package $JAVA_PACKAGE.service.mapper;

public class ${CLASS_NAME}Mapper {
}"
                        ;;
                    --criteria)
                        create_file "$BASE_DIR/service/criteria" "${CLASS_NAME}Criteria.java" "package $JAVA_PACKAGE.service.criteria;

public class ${CLASS_NAME}Criteria {
}"
                        ;;
                    --query)
                        create_file "$BASE_DIR/service/query" "${CLASS_NAME}QueryService.java" "package $JAVA_PACKAGE.service.query;

public class ${CLASS_NAME}QueryService {
}"
                        ;;
                    --implement)
                        create_file "$BASE_DIR/service/impl" "${CLASS_NAME}ServiceImpl.java" "package $JAVA_PACKAGE.service.impl;

import org.springframework.stereotype.Service;
import $JAVA_PACKAGE.service.${CLASS_NAME}Service;

@Service
public class ${CLASS_NAME}ServiceImpl implements ${CLASS_NAME}Service {
}"
                    ;;
                    --class)
                        create_file "$BASE_DIR/service" "${CLASS_NAME}Service.java" "package $JAVA_PACKAGE.service;

import org.springframework.stereotype.Service;

@Service
public class ${CLASS_NAME}Service {
}"
                    ;;
                    *)
                        echo "⚠ Option inconnue : $opt"
                        ;;
                esac
            done
        fi
        ;;
    rest)
        create_file "$BASE_DIR/web/rest" "${CLASS_NAME}Resource.java" "package $JAVA_PACKAGE.web.rest;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(\"/api\")
public class ${CLASS_NAME}Resource {
}"
       ;;
    changelog)
       if [ "$OPTION" == "--init" ]; then
                  # Créer le fichier master.xml
                  create_file "$RESOURCES_DIR/db" "master.xml" "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<databaseChangeLog
    xmlns=\"http://www.liquibase.org/xml/ns/dbchangelog\"
    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
    xsi:schemaLocation=\"http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-latest.xsd\">

    <!-- Changelog Liquibase initial
    <property name=\"now\" value=\"current_timestamp\" dbms=\"postgresql\"/>
    <property name=\"floatType\" value=\"float4\" dbms=\"postgresql\"/>
    <property name=\"clobType\" value=\"clob\" dbms=\"postgresql\"/>
    <property name=\"blobType\" value=\"blob\" dbms=\"postgresql\"/>
    <property name=\"uuidType\" value=\"uuid\" dbms=\"postgresql\"/>
    <property name=\"datetimeType\" value=\"datetime\" dbms=\"postgresql\"/>
    <property name=\"timeType\" value=\"time(6)\" dbms=\"postgresql\"/>

    <include file=\"changelog/mon-fichier.xml\" relativeToChangelogFile=\"false\"/>
    -->

</databaseChangeLog>"

      elif [ "$OPTION" == "--data" ]; then
          timestamp=$(date +"%Y%m%d%H%M%S")
          create_file "$RESOURCES_DIR/db/data" "${timestamp}_$NAME.data.csv" "# CSV ${timestamp}_$NAME.data.csv de données pour $NAME"
      elif [ "$OPTION" == "--sql" ]; then
          timestamp=$(date +"%Y%m%d%H%M%S")
          create_file "$RESOURCES_DIR/db/request-sql" "${timestamp}_$NAME.request.sql" "-- Requête SQL ${timestamp}_$NAME.request.sql pour $NAME"
      else
        timestamp=$(date +"%Y%m%d%H%M%S")
        create_file "$RESOURCES_DIR/db/changelog" "${timestamp}_$NAME.xml" "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<databaseChangeLog
    xmlns=\"http://www.liquibase.org/xml/ns/dbchangelog\"
    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
    xsi:schemaLocation=\"http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-latest.xsd\">

    <!-- Changelog Liquibase ${timestamp}_$NAME.xml -->
        <changeSet id=\"${timestamp}-1\" author=\"auteur\">
        </changeSet>
</databaseChangeLog>"
      fi
      ;;

    application)
        profile=${NAME:-"application"}
        case "$OPTION" in
            --properties)
                create_file "$RESOURCES_DIR/config" "application-$profile.properties" "# Configuration $profile"
                ;;
            *)
                create_file "$RESOURCES_DIR/config" "application-$profile.yml" "# Configuration $profile"
                ;;
        esac
        ;;
    *)
        echo "✘ Sous-commande invalide : $SUBCOMMAND"
        show_help
        exit 1
        ;;
esac