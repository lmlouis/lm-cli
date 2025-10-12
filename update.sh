#!/bin/bash

set -e

# Variables
INSTALL_DIR="$HOME/.lm-cli"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Charger les fonctions communes
source "$SCRIPT_DIR/install.sh"

check_update() {
    local current_version=$(cat "$INSTALL_DIR/version.txt" 2>/dev/null || echo "unknown")
    local latest_version=$(get_latest_release)

    if [ "$current_version" = "$latest_version" ]; then
        log_success "Vous avez déjà la dernière version ($current_version)"
    else
        log_info "Nouvelle version disponible: $latest_version (vous avez: $current_version)"
        read -p "Voulez-vous mettre à jour? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_release "$latest_version"
        fi
    fi
}

main() {
    local action="check"

    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                local latest_version=$(get_latest_release)
                install_release "$latest_version"
                exit 0
                ;;
            -h|--help)
                echo "Usage: $0 [--force]"
                exit 0
                ;;
            *)
                echo "Option inconnue: $1"
                exit 1
                ;;
        esac
        shift
    done

    check_update
}

main "$@"