#!/bin/bash
# autocomplete.sh - Autocomplétion intelligente pour lm-cli
# Compatible Bash et Zsh

_lm_completion() {
    local cur prev words cword

    # Compatibilité Bash/Zsh
    if [ -n "$BASH_VERSION" ]; then
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
    elif [ -n "$ZSH_VERSION" ]; then
        # Mode Zsh - convertir les tableaux
        words=("${(@)words}")
        cur="${words[-1]}"
        prev="${words[-2]}"
        cword=${#words[@]}
    fi

    # Vérifier si on est dans un projet Spring Boot
    local has_pom=false
    local check_dir="$PWD"
    while [[ "$check_dir" != "" ]]; do
        if [[ -f "$check_dir/pom.xml" ]]; then
            has_pom=true
            break
        fi
        check_dir="${check_dir%/*}"
    done

    # Commandes disponibles sans projet
    local mgmt_cmds="update install uninstall version --help -h"

    # Sous-commandes create (nécessitent un projet Spring Boot)
    local create_cmds="config exception constant security pagination filter dto mapper domain repository service rest changelog application"

    # Position dans la commande
    local cmd="${words[1]}"
    local subcmd="${words[2]}"
    local name="${words[3]}"

    # Fonction helper pour la complétion
    _complete() {
        if [ -n "$BASH_VERSION" ]; then
            COMPREPLY=($(compgen -W "$1" -- "$cur"))
        elif [ -n "$ZSH_VERSION" ]; then
            compadd -Q -- ${=1}
        fi
    }

    # Niveau 1: Commande principale (lm ...)
    if [ $cword -eq 1 ]; then
        if [ "$has_pom" = true ]; then
            _complete "create $mgmt_cmds"
        else
            _complete "$mgmt_cmds"
        fi
        return 0
    fi

    # Niveau 2: Sous-commande (lm create ...)
    if [ "$cmd" = "create" ] && [ $cword -eq 2 ]; then
        if [ "$has_pom" = true ]; then
            _complete "$create_cmds"
        fi
        return 0
    fi

    # Niveau 3: Nom ou options (lm create config ...)
    if [ "$cmd" = "create" ] && [ $cword -eq 3 ]; then
        case "$subcmd" in
            pagination|filter)
                # Pas de nom requis, proposer options
                _complete "--force"
                ;;
            config)
                if [[ "$cur" == -* ]]; then
                    _complete "--properties --force"
                else
                    _complete "Database Security Email Cache Redis OAuth Swagger CORS"
                fi
                ;;
            exception)
                if [[ "$cur" == -* ]]; then
                    _complete "--force"
                else
                    _complete "NotFound BadRequest Unauthorized Forbidden Validation ResourceNotFound"
                fi
                ;;
            constant)
                if [[ "$cur" == -* ]]; then
                    _complete "--force"
                else
                    _complete "Application Api Database Status ErrorCode"
                fi
                ;;
            security)
                if [[ "$cur" == -* ]]; then
                    _complete "--force"
                else
                    _complete "JwtUtil SecurityConfig UserDetailsService AuthenticationFilter"
                fi
                ;;
            dto)
                if [[ "$cur" == -* ]]; then
                    _complete "--record --force"
                else
                    _complete "User Product Order Customer Invoice Payment"
                fi
                ;;
            mapper)
                if [[ "$cur" == -* ]]; then
                    _complete "--init --force"
                else
                    _complete "User Product Order EntityMapper"
                fi
                ;;
            domain)
                if [[ "$cur" == -* ]]; then
                    _complete "--enum --entity --force"
                else
                    _complete "User Product Order Customer Invoice Status Role"
                fi
                ;;
            repository)
                if [[ "$cur" == -* ]]; then
                    _complete "--force"
                else
                    _complete "User Product Order Customer Invoice"
                fi
                ;;
            service)
                if [[ "$cur" == -* ]]; then
                    _complete "--mapper --criteria --query --implement --class --force"
                else
                    _complete "User Product Order Customer Invoice Email Notification"
                fi
                ;;
            rest)
                if [[ "$cur" == -* ]]; then
                    _complete "--force"
                else
                    _complete "User Product Order Customer Invoice Auth Admin"
                fi
                ;;
            changelog)
                if [[ "$cur" == -* ]]; then
                    _complete "--init --data --sql --force"
                else
                    _complete "initial create_users create_products add_indexes"
                fi
                ;;
            application)
                if [[ "$cur" == -* ]]; then
                    _complete "--yml --properties --force"
                else
                    _complete "dev prod test staging local"
                fi
                ;;
        esac
        return 0
    fi

    # Niveau 4+: Options supplémentaires après le nom
    if [ "$cmd" = "create" ] && [ $cword -gt 3 ]; then
        case "$subcmd" in
            config)
                _complete "--properties --force"
                ;;
            dto)
                _complete "--record --force"
                ;;
            mapper)
                _complete "--init --force"
                ;;
            domain)
                _complete "--enum --entity --force"
                ;;
            service)
                _complete "--mapper --criteria --query --implement --class --force"
                ;;
            changelog)
                _complete "--init --data --sql --force"
                ;;
            application)
                _complete "--yml --properties --force"
                ;;
            *)
                _complete "--force"
                ;;
        esac
        return 0
    fi

    # Options pour les autres commandes
    case "$cmd" in
        install)
            if [ $cword -eq 2 ]; then
                _complete "latest v1.1.3 v1.1.2 v1.1.1"
            fi
            ;;
        update|uninstall|version)
            # Pas d'options
            ;;
    esac
}

# Enregistrement selon le shell
if [ -n "$BASH_VERSION" ]; then
    complete -F _lm_completion lm
elif [ -n "$ZSH_VERSION" ]; then
    # Zsh nécessite une fonction wrapper
    compdef _lm_completion lm
fi

# Message de confirmation si chargé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]] || [[ "${(%):-%x}" == "${0}" ]]; then
    echo "✅ Autocomplétion lm-cli chargée"
    echo "ℹ️  Testez: lm <TAB>"
fi