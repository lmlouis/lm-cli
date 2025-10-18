#!/bin/bash

# autocomplete.sh - Autocomplétion pour lm-cli

_setup_auto_completion() {
    # Vérifier si on est dans un projet Spring Boot
    local current_dir="$PWD"
    local has_pom=false

    while [[ "$current_dir" != "" ]]; do
        if [[ -f "$current_dir/pom.xml" ]]; then
            has_pom=true
            break
        fi
        current_dir="${current_dir%/*}"
    done

    # Retourner le statut
    echo "$has_pom"
}

_lm_completion() {
    local cur prev words cword
    _init_completion || return

    # Vérifier le contexte du projet
    local has_pom=$(_setup_auto_completion)

    # Commandes disponibles sans projet Spring Boot
    local MANAGEMENT_COMMANDS="update install uninstall version --help -h"

    # Commandes nécessitant un projet Spring Boot
    local CREATE_SUBCOMMANDS="config exception constant security pagination filter dto mapper domain repository service rest changelog application"

    case ${prev} in
        lm)
            if [[ $has_pom == "true" ]]; then
                COMPREPLY=($(compgen -W "create $MANAGEMENT_COMMANDS" -- "$cur"))
            else
                COMPREPLY=($(compgen -W "$MANAGEMENT_COMMANDS" -- "$cur"))
            fi
            return
            ;;
        create)
            if [[ $has_pom == "true" ]]; then
                COMPREPLY=($(compgen -W "$CREATE_SUBCOMMANDS" -- "$cur"))
            else
                echo "⚠️  Pas de projet Spring Boot détecté (pom.xml)" >&2
                COMPREPLY=()
            fi
            return
            ;;
        update|uninstall|version)
            # Pas d'arguments supplémentaires
            COMPREPLY=()
            return
            ;;
        install)
            # Suggérer 'latest' ou permettre une version spécifique
            COMPREPLY=($(compgen -W "latest 1.1.3 1.1.2 1.1.1" -- "$cur"))
            return
            ;;
        --package=*|--package)
            # Suggestions de packages courants
            COMPREPLY=($(compgen -W "statistics security common util api core admin" -- "$cur"))
            return
            ;;
    esac

    # Gestion des options globales
    if [[ $cur == --* ]]; then
        case ${words[2]} in
            config|exception|constant|security|dto|mapper|domain|repository|service|rest|changelog|application|pagination|filter)
                COMPREPLY=($(compgen -W "--force --package=" -- "$cur"))
                return
                ;;
        esac
    fi

    # Gestion des sous-options spécifiques aux sous-commandes
    if [[ ${#words[@]} -ge 3 ]]; then
        case ${words[2]} in
            config)
                if [[ ${#words[@]} -eq 4 ]] && [[ "$cur" != -* ]]; then
                    # Nom du config
                    COMPREPLY=($(compgen -W "Database Security Email Cache Redis OAuth Swagger CORS" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "--properties --force" -- "$cur"))
                fi
                ;;
            exception)
                if [[ ${#words[@]} -eq 4 ]] && [[ "$cur" != -* ]]; then
                    COMPREPLY=($(compgen -W "NotFound BadRequest Unauthorized Forbidden Validation ResourceNotFound" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "--force" -- "$cur"))
                fi
                ;;
            constant)
                if [[ ${#words[@]} -eq 4 ]] && [[ "$cur" != -* ]]; then
                    COMPREPLY=($(compgen -W "Application Api Database Status ErrorCode" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "--force" -- "$cur"))
                fi
                ;;
            security)
                if [[ ${#words[@]} -eq 4 ]] && [[ "$cur" != -* ]]; then
                    COMPREPLY=($(compgen -W "JwtUtil SecurityConfig UserDetailsService AuthenticationFilter" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "--force" -- "$cur"))
                fi
                ;;
            pagination)
                # Pas de nom requis pour pagination
                COMPREPLY=($(compgen -W "--force" -- "$cur"))
                ;;
            filter)
                # Pas de nom requis pour filter
                COMPREPLY=($(compgen -W "--force" -- "$cur"))
                ;;
            dto)
                if [[ ${#words[@]} -eq 4 ]] && [[ "$cur" != -* ]]; then
                    COMPREPLY=($(compgen -W "User Product Order Customer Invoice Payment" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "--record --force" -- "$cur"))
                fi
                ;;
            mapper)
                if [[ ${#words[@]} -eq 4 ]] && [[ "$cur" != -* ]]; then
                    COMPREPLY=($(compgen -W "User Product Order EntityMapper" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "--init --force" -- "$cur"))
                fi
                ;;
            domain)
                if [[ ${#words[@]} -eq 4 ]] && [[ "$cur" != -* ]]; then
                    COMPREPLY=($(compgen -W "User Product Order Customer Invoice Status Role" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "--enum --entity --force" -- "$cur"))
                fi
                ;;
            repository)
                if [[ ${#words[@]} -eq 4 ]] && [[ "$cur" != -* ]]; then
                    COMPREPLY=($(compgen -W "User Product Order Customer Invoice" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "--force" -- "$cur"))
                fi
                ;;
            service)
                if [[ ${#words[@]} -eq 4 ]] && [[ "$cur" != -* ]]; then
                    COMPREPLY=($(compgen -W "User Product Order Customer Invoice Email Notification" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "--mapper --criteria --query --implement --class --force" -- "$cur"))
                fi
                ;;
            rest)
                if [[ ${#words[@]} -eq 4 ]] && [[ "$cur" != -* ]]; then
                    COMPREPLY=($(compgen -W "User Product Order Customer Invoice Auth Admin" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "--force" -- "$cur"))
                fi
                ;;
            changelog)
                if [[ ${#words[@]} -eq 4 ]] && [[ "$cur" != -* ]]; then
                    COMPREPLY=($(compgen -W "initial create_users create_products add_indexes" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "--init --data --sql --force" -- "$cur"))
                fi
                ;;
            application)
                if [[ ${#words[@]} -eq 4 ]] && [[ "$cur" != -* ]]; then
                    # Profils Spring Boot courants
                    COMPREPLY=($(compgen -W "dev prod test staging local" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "--yml --properties --force" -- "$cur"))
                fi
                ;;
        esac
    fi

    # Si rien n'a été trouvé, proposer les options globales
    if [[ ${#COMPREPLY[@]} -eq 0 ]] && [[ $cur == -* ]]; then
        COMPREPLY=($(compgen -W "--force --package= --help" -- "$cur"))
    fi
}

# Enregistrer la fonction d'autocomplétion
complete -F _lm_completion lm 2>/dev/null

# Message de confirmation (optionnel, à commenter en production)
# echo "✅ Autocomplétion lm-cli chargée avec succès" >&2