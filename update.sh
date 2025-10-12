#!/bin/bash

set -e

# Variables
INSTALL_DIR="$HOME/.lm-cli"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Fonctions de log
log_info() {
    echo "📦 $1"
}

log_success() {
    echo "✅ $1"
}

log_error() {
    echo "❌ $1"
}

# Récupérer la dernière version
get_latest_release() {
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

# Installation
install_release() {
    local version="$1"
    local repo_owner="lmlouis"
    local repo_name="lm-cli"

    log_info "Installation de la version $version..."

    # URL de téléchargement
    local download_url="https://github.com/$repo_owner/$repo_name/archive/refs/tags/$version.tar.gz"
    local temp_file="/tmp/lm-cli-$version.tar.gz"

    # Télécharger
    if command -v curl &> /dev/null; then
        curl -fsSL -o "$temp_file" "$download_url"
    elif command -v wget &> /dev/null; then
        wget -q -O "$temp_file" "$download_url"
    else
        log_error "Aucun outil de téléchargement disponible"
        exit 1
    fi

    # Extraire
    tar -xzf "$temp_file" -C "/tmp/"

    # Copier les fichiers
    local extracted_dir="/tmp/lm-cli-${version#v}"
    cp -r "$extracted_dir"/* "$INSTALL_DIR/"

    # Rendre exécutable
    chmod +x "$INSTALL_DIR/java.sh"
    chmod +x "$INSTALL_DIR/lm"
    chmod +x "$INSTALL_DIR/update.sh"

    # Mettre à jour la version
    echo "$version" > "$INSTALL_DIR/version.txt"

    # Nettoyer
    rm -f "$temp_file"
    rm -rf "$extracted_dir"

    log_success "Mise à jour terminée avec succès!"
    log_info "Nouvelle version: $version"
}

# Vérification des mises à jour
check_update() {
    local current_version=$(cat "$INSTALL_DIR/version.txt" 2>/dev/null || echo "unknown")
    local latest_version=$(get_latest_release)

    log_info "Version actuelle: $current_version"
    log_info "Dernière version: $latest_version"

    if [ "$current_version" = "$latest_version" ]; then
        log_success "Vous avez déjà la dernière version ($current_version)"
    else
        log_info "Nouvelle version disponible!"
        read -p "Voulez-vous mettre à jour? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_release "$latest_version"
        else
            log_info "Mise à jour annulée"
        fi
    fi
}

# Fonction principale
main() {
    local action="check"

    while [[ $# -gt 0 ]]; do
        case $1 in
            --force|-f)
                local latest_version=$(get_latest_release)
                install_release "$latest_version"
                exit 0
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --force, -f    Forcer la mise à jour sans confirmation"
                echo "  --help, -h     Afficher cette aide"
                echo ""
                echo "Exemples:"
                echo "  $0             Vérifier et proposer la mise à jour"
                echo "  $0 --force     Forcer la mise à jour vers la dernière version"
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

# Lancer le script
main "$@"