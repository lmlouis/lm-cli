#!/bin/bash

_lm_completion() {
    local cur prev words cword
    _init_completion || return

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