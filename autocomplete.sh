#!/bin/bash
# autocomplete.sh - Autocomplétion universelle pour lm-cli
# Compatible Bash ET Zsh

# Fonction de vérification du projet Spring Boot
_lm_has_pom() {
    local check_dir="$PWD"
    while [[ "$check_dir" != "" ]]; do
        if [[ -f "$check_dir/pom.xml" ]]; then
            return 0
        fi
        check_dir="${check_dir%/*}"
    done
    return 1
}

# ==========================================
# VERSION ZSH
# ==========================================
if [[ -n "$ZSH_VERSION" ]]; then

_lm_zsh() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    local has_pom=false
    _lm_has_pom && has_pom=true

    local global_opts=(
        '--force:Écraser les fichiers existants'
        '--package:Spécifier un package personnalisé'
        '--help:Afficher l aide'
    )

    local mgmt_cmds=(
        'update:Mettre à jour lm-cli'
        'install:Installer une version spécifique'
        'uninstall:Désinstaller lm-cli'
        'version:Afficher la version'
    )

    local create_cmds=(
        'config:Créer une configuration'
        'exception:Créer une exception'
        'constant:Créer une classe de constantes'
        'security:Créer une configuration de sécurité'
        'pagination:Créer le système de pagination'
        'filter:Créer le système de filtrage'
        'dto:Créer un Data Transfer Object'
        'mapper:Créer un mapper'
        'domain:Créer une entité'
        'repository:Créer un repository'
        'service:Créer un service'
        'rest:Créer un contrôleur REST'
        'changelog:Créer un changelog'
        'application:Créer application.yml'
    )

    _arguments -C \
        '1: :->level1' \
        '2: :->level2' \
        '3: :->level3' \
        '*: :->options'

    case $state in
        level1)
            if [ "$has_pom" = true ]; then
                _describe 'commandes' mgmt_cmds
                compadd create
                _describe 'options' global_opts
            else
                _describe 'commandes' mgmt_cmds
                _describe 'options' global_opts
            fi
            ;;

        level2)
            case ${words[2]} in
                create)
                    [ "$has_pom" = true ] && _describe 'sous-commandes' create_cmds
                    ;;
                install)
                    compadd latest v1.2.5 v1.2.4 v1.2.3
                    ;;
            esac
            ;;

        level3)
            case ${words[3]} in
                config)
                    compadd Database Security Email Cache Redis OAuth Swagger CORS
                    compadd -- --properties --force
                    ;;
                exception)
                    compadd NotFound BadRequest Unauthorized Forbidden Validation
                    compadd -- --force
                    ;;
                constant)
                    compadd Application Api Database Status ErrorCode
                    compadd -- --force
                    ;;
                security)
                    compadd JwtUtil SecurityConfig UserDetailsService AuthenticationFilter
                    compadd -- --force
                    ;;
                dto)
                    compadd User Product Order Customer Invoice Payment
                    compadd -- --record --force
                    ;;
                mapper)
                    compadd User Product Order EntityMapper
                    compadd -- --init --force
                    ;;
                domain)
                    compadd User Product Order Customer Invoice Status Role
                    compadd -- --enum --entity --force
                    ;;
                repository|rest)
                    compadd User Product Order Customer Invoice
                    compadd -- --force
                    ;;
                service)
                    compadd User Product Order Customer Invoice Email Notification
                    compadd -- --mapper --criteria --query --implement --class --force
                    ;;
                changelog)
                    compadd initial create_users create_products add_indexes
                    compadd -- --init --data --sql --force
                    ;;
                application)
                    compadd dev prod test staging local
                    compadd -- --yml --properties --force
                    ;;
                pagination|filter)
                    compadd -- --force
                    ;;
            esac
            ;;

        options)
            compadd -- --force --package --help
            ;;
    esac

    return 0
}

compdef _lm_zsh lm

echo "✅ Autocomplétion lm-cli chargée pour Zsh"

# ==========================================
# VERSION BASH
# ==========================================
elif [[ -n "$BASH_VERSION" ]]; then

_lm_bash() {
    local cur prev words cword
    _init_completion || return

    local has_pom=false
    _lm_has_pom && has_pom=true

    local cmd="${words[1]}"
    local subcmd="${words[2]}"
    local name="${words[3]}"

    # Commandes disponibles
    local mgmt_cmds="update install uninstall version --help --force --package"
    local create_cmds="config exception constant security pagination filter dto mapper domain repository service rest changelog application"

    # Niveau 1: Commande principale
    if [ $cword -eq 1 ]; then
        if [ "$has_pom" = true ]; then
            COMPREPLY=($(compgen -W "create $mgmt_cmds" -- "$cur"))
        else
            COMPREPLY=($(compgen -W "$mgmt_cmds" -- "$cur"))
        fi
        return 0
    fi

    # Niveau 2: Sous-commande
    if [ $cword -eq 2 ]; then
        case "$cmd" in
            create)
                if [ "$has_pom" = true ]; then
                    COMPREPLY=($(compgen -W "$create_cmds" -- "$cur"))
                fi
                ;;
            install)
                COMPREPLY=($(compgen -W "latest v1.2.5 v1.2.4 v1.2.3" -- "$cur"))
                ;;
        esac
        return 0
    fi

    # Niveau 3: Nom ou options
    if [ $cword -eq 3 ]; then
        case "$subcmd" in
            config)
                if [[ "$cur" == -* ]]; then
                    COMPREPLY=($(compgen -W "--properties --force" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "Database Security Email Cache Redis OAuth Swagger CORS" -- "$cur"))
                fi
                ;;
            exception)
                if [[ "$cur" == -* ]]; then
                    COMPREPLY=($(compgen -W "--force" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "NotFound BadRequest Unauthorized Forbidden Validation" -- "$cur"))
                fi
                ;;
            constant)
                if [[ "$cur" == -* ]]; then
                    COMPREPLY=($(compgen -W "--force" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "Application Api Database Status ErrorCode" -- "$cur"))
                fi
                ;;
            security)
                if [[ "$cur" == -* ]]; then
                    COMPREPLY=($(compgen -W "--force" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "JwtUtil SecurityConfig UserDetailsService AuthenticationFilter" -- "$cur"))
                fi
                ;;
            dto)
                if [[ "$cur" == -* ]]; then
                    COMPREPLY=($(compgen -W "--record --force" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "User Product Order Customer Invoice Payment" -- "$cur"))
                fi
                ;;
            mapper)
                if [[ "$cur" == -* ]]; then
                    COMPREPLY=($(compgen -W "--init --force" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "User Product Order EntityMapper" -- "$cur"))
                fi
                ;;
            domain)
                if [[ "$cur" == -* ]]; then
                    COMPREPLY=($(compgen -W "--enum --entity --force" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "User Product Order Customer Invoice Status Role" -- "$cur"))
                fi
                ;;
            repository|rest)
                if [[ "$cur" == -* ]]; then
                    COMPREPLY=($(compgen -W "--force" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "User Product Order Customer Invoice" -- "$cur"))
                fi
                ;;
            service)
                if [[ "$cur" == -* ]]; then
                    COMPREPLY=($(compgen -W "--mapper --criteria --query --implement --class --force" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "User Product Order Customer Invoice Email Notification" -- "$cur"))
                fi
                ;;
            changelog)
                if [[ "$cur" == -* ]]; then
                    COMPREPLY=($(compgen -W "--init --data --sql --force" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "initial create_users create_products add_indexes" -- "$cur"))
                fi
                ;;
            application)
                if [[ "$cur" == -* ]]; then
                    COMPREPLY=($(compgen -W "--yml --properties --force" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "dev prod test staging local" -- "$cur"))
                fi
                ;;
            pagination|filter)
                COMPREPLY=($(compgen -W "--force" -- "$cur"))
                ;;
        esac
        return 0
    fi

    # Niveau 4+: Options supplémentaires
    if [ $cword -gt 3 ]; then
        COMPREPLY=($(compgen -W "--force --package --help" -- "$cur"))
        return 0
    fi
}

complete -F _lm_bash lm

echo "✅ Autocomplétion lm-cli chargée pour Bash"

fi

# Message d'avertissement si pas de pom.xml
if [[ ! -f "$PWD/pom.xml" ]]; then
    echo "⚠️  Pas de pom.xml - la commande 'create' ne sera pas disponible"
fi