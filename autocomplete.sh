#!/bin/bash

#autocomplete.sh

# Dans autocomplete.sh - Ajouter au début
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

    # Si pas de projet Spring Boot, limiter les commandes
    if [[ $has_pom == false ]]; then
        case ${prev} in
            lm)
                COMPREPLY=($(compgen -W "update install uninstall version --help" -- "$cur"))
                return
                ;;
        esac
    fi
}

_lm_completion() {
    local cur prev words cword
    _init_completion || return

    # Vérifier le contexte du projet
    _setup_auto_completion

    case ${prev} in
        lm)
            COMPREPLY=($(compgen -W "create update install uninstall version --help" -- "$cur"))
            ;;
        create)
            COMPREPLY=($(compgen -W "config exception constant security pagination filter dto mapper domain repository service rest changelog application" -- "$cur"))
            ;;
        update|uninstall|version)
            # Pas d'arguments supplémentaires pour ces commandes
            COMPREPLY=()
            ;;
        install)
            COMPREPLY=($(compgen -W "latest" -- "$cur"))
            ;;
        config|exception|constant|security|dto|mapper|domain|repository|service|rest|changelog|application)
            COMPREPLY=($(compgen -W "--force --package=" -- "$cur"))
            ;;
        --package)
            COMPREPLY=($(compgen -W "statistics security common util" -- "$cur"))
            ;;
        *)
            case ${words[1]} in
                create)
                    case ${words[2]} in
                        config)
                            COMPREPLY=($(compgen -W "--properties" -- "$cur"))
                            ;;
                        dto)
                            COMPREPLY=($(compgen -W "--record" -- "$cur"))
                            ;;
                        mapper)
                            COMPREPLY=($(compgen -W "--init" -- "$cur"))
                            ;;
                        domain)
                            COMPREPLY=($(compgen -W "--enum --entity" -- "$cur"))
                            ;;
                        service)
                            COMPREPLY=($(compgen -W "--mapper --criteria --query --implement --class" -- "$cur"))
                            ;;
                        changelog)
                            COMPREPLY=($(compgen -W "--init --data --sql" -- "$cur"))
                            ;;
                        application)
                            COMPREPLY=($(compgen -W "--yml --properties" -- "$cur"))
                            ;;
                    esac
                    ;;
            esac
            ;;
    esac
}

complete -F _lm_completion lm 2>/dev/null || {
    echo "Auto-completion configured. Restart your terminal or run: source ~/.bashrc" >&2
}