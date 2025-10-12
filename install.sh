#!/bin/bash

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
REPO_OWNER="lmlouis"
REPO_NAME="lm-cli"
INSTALL_DIR="$HOME/.lm-cli"
BIN_DIR="$HOME/.local/bin"
BACKUP_DIR="$HOME/.lm-cli-backup"

# Fonctions d'affichage
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Détection de l'OS
detect_os() {
    case "$(uname -s)" in
        Darwin*)    OS="macOS" ;;
        Linux*)     OS="Linux" ;;
        CYGWIN*|MINGW*|MSYS*) OS="Windows" ;;
        *)          OS="UNKNOWN" ;;
    esac
    echo "$OS"
}

# Vérification des dépendances
check_dependencies() {
    local missing_deps=()

    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        missing_deps+=("curl ou wget")
    fi

    if ! command -v unzip &> /dev/null && ! command -v tar &> /dev/null; then
        missing_deps+=("unzip ou tar")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Dépendances manquantes: ${missing_deps[*]}"
        exit 1
    fi
}

# Téléchargement du fichier
download_file() {
    local url="$1"
    local output="$2"

    if command -v curl &> /dev/null; then
        curl -fsSL -o "$output" "$url"
    elif command -v wget &> /dev/null; then
        wget -q -O "$output" "$url"
    else
        log_error "Aucun outil de téléchargement disponible"
        exit 1
    fi
}

# Récupération de la dernière release
get_latest_release() {
    local api_url="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest"

    if command -v jq &> /dev/null; then
        download_file "$api_url" "/tmp/latest_release.json"
        jq -r '.tag_name' /tmp/latest_release.json
    else
        # Fallback sans jq
        if command -v curl &> /dev/null; then
            curl -fsSL "$api_url" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
        else
            wget -q -O - "$api_url" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
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

    # Utiliser install.sh avec la dernière version
    if [ -f "$SCRIPT_DIR/install.sh" ]; then
        echo "📦 Mise à jour via le script d'installation..."
        echo "ℹ️  Exécution de: $SCRIPT_DIR/install.sh"
        bash "$SCRIPT_DIR/install.sh"
    else
        echo "❌ Script d'installation non trouvé dans $SCRIPT_DIR"
        echo "ℹ️  Téléchargez la dernière version depuis:"
        echo "   https://github.com/lmlouis/lm-cli/releases"
        echo "   ou exécutez: curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash"
    fi
}

# Récupération de toutes les releases
get_all_releases() {
    local api_url="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases"

    if command -v jq &> /dev/null; then
        download_file "$api_url" "/tmp/all_releases.json"
        jq -r '.[].tag_name' /tmp/all_releases.json
    else
        log_warning "jq non installé, utilisation de la dernière release uniquement"
        get_latest_release
    fi
}

# Installation de la release
install_release() {
    local version="$1"
    local download_url=""
    local temp_file=""

    log_info "Installation de la version $version..."

    # Création des répertoires
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$BIN_DIR"

    # Sauvegarde de l'ancienne version
    if [ -d "$INSTALL_DIR" ] && [ "$(ls -A "$INSTALL_DIR" 2>/dev/null)" ]; then
        log_info "Sauvegarde de l'ancienne version..."
        mkdir -p "$BACKUP_DIR"
        cp -r "$INSTALL_DIR" "$BACKUP_DIR/$(date +%Y%m%d_%H%M%S)"
    fi

    # Nettoyage de l'installation précédente
    rm -rf "$INSTALL_DIR"/*

    # Détermination de l'URL de téléchargement et de l'extension
    if [ "$OS" = "Windows" ]; then
        download_url="https://github.com/$REPO_OWNER/$REPO_NAME/archive/refs/tags/$version.zip"
        temp_file="/tmp/lm-cli-$version.zip"
        download_file "$download_url" "$temp_file"

        if command -v unzip &> /dev/null; then
            unzip -q "$temp_file" -d "/tmp/"
            cp -r "/tmp/lm-cli-${version#v}"/* "$INSTALL_DIR/"
        else
            log_error "unzip non disponible"
            exit 1
        fi
    else
        download_url="https://github.com/$REPO_OWNER/$REPO_NAME/archive/refs/tags/$version.tar.gz"
        temp_file="/tmp/lm-cli-$version.tar.gz"
        download_file "$download_url" "$temp_file"

        if command -v tar &> /dev/null; then
            tar -xzf "$temp_file" -C "/tmp/"
            cp -r "/tmp/lm-cli-${version#v}"/* "$INSTALL_DIR/"
        else
            log_error "tar non disponible"
            exit 1
        fi
    fi

    # Rendre les scripts exécutables
    chmod +x "$INSTALL_DIR/java.sh"
    chmod +x "$INSTALL_DIR/lm"

    # Création du lien symbolique ou script wrapper
    create_binary_wrapper

    # Nettoyage
    rm -f "$temp_file"
    rm -rf "/tmp/lm-cli-${version#v}"
}

# Création du wrapper binaire
# Création du wrapper binaire
create_binary_wrapper() {
    local wrapper_path="$BIN_DIR/lm"

    # Supprimer l'ancien wrapper s'il existe
    rm -f "$wrapper_path"

    if [ "$OS" = "Windows" ]; then
        # Script batch pour Windows
        cat > "${wrapper_path}.bat" << EOF
@echo off
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=$INSTALL_DIR"
set "PWD=%CD%"

cd /d "%SCRIPT_DIR%"
bash java.sh %*
cd /d "%PWD%"
EOF
        log_info "Wrapper Windows créé: ${wrapper_path}.bat"
    else
        # Script shell pour Unix - VERSION CORRIGÉE
        cat > "$wrapper_path" << 'EOF'
#!/bin/bash

SCRIPT_DIR="$HOME/.lm-cli"

if [ ! -f "$SCRIPT_DIR/java.sh" ]; then
    echo "Le fichier java.sh est introuvable dans $SCRIPT_DIR"
    exit 1
fi

chmod +x "$SCRIPT_DIR/java.sh" 2>/dev/null

# Exécuter sans changer de répertoire
exec "$SCRIPT_DIR/java.sh" "$@"
EOF
        chmod +x "$wrapper_path"
        log_info "Wrapper Unix créé: $wrapper_path"
    fi
}

# Configuration du shell
setup_shell() {
    local shell_config=""

    case "$SHELL" in
        */bash)
            shell_config="$HOME/.bashrc"
            ;;
        */zsh)
            shell_config="$HOME/.zshrc"
            ;;
        */fish)
            shell_config="$HOME/.config/fish/config.fish"
            ;;
        *)
            shell_config="$HOME/.profile"
            ;;
    esac

    # Ajout du PATH si nécessaire
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        log_info "Ajout de $BIN_DIR au PATH dans $shell_config"

        if [ "$OS" = "Windows" ]; then
            # Pour Windows, on utilise setx (attention: cela modifie le PATH système)
            log_warning "Pour Windows, ajoutez manuellement $BIN_DIR à votre PATH"
        else
            echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$shell_config"
            log_success "PATH mis à jour dans $shell_config"
            log_info "Exécutez 'source $shell_config' ou redémarrez votre terminal"
        fi
    fi

    # Configuration de l'auto-complétion
    setup_autocomplete "$shell_config"
}

# Configuration de l'auto-complétion
setup_autocomplete() {
    local shell_config="$1"

    if [ "$OS" = "Windows" ]; then
        log_warning "L'auto-complétion n'est pas supportée sur Windows"
        return
    fi

    # Vérifier si l'auto-complétion est déjà configurée
    if ! grep -q "lm-cli autocomplete" "$shell_config" 2>/dev/null; then
        cat >> "$shell_config" << 'EOF'

# Auto-complétion pour lm-cli
if [ -f "$HOME/.lm-cli/autocomplete.sh" ]; then
    source "$HOME/.lm-cli/autocomplete.sh"
fi
EOF
        log_success "Auto-complétion configurée"
    fi
}

# Vérification de l'installation
verify_installation() {
    if command -v lm &> /dev/null || [ -f "$BIN_DIR/lm" ]; then
        log_success "Installation terminée avec succès!"
        log_info "Utilisez 'lm --help' pour voir les commandes disponibles"
    else
        log_error "Problème lors de l'installation"
        exit 1
    fi
}

# Affichage de l'aide
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
  -v, --version VERSION    Installer une version spécifique (ex: 1.0.8)
  -l, --list               Lister toutes les versions disponibles
  -u, --uninstall          Désinstaller lm-cli
  -h, --help               Afficher cette aide

Exemples:
  $0                      Installer la dernière version
  $0 -v 1.0.8            Installer la version 1.0.8
  $0 -l                   Lister toutes les versions disponibles
  $0 -u                   Désinstaller

Repository: https://github.com/$REPO_OWNER/$REPO_NAME
EOF
}

# Désinstallation
uninstall() {
    log_info "Désinstallation de lm-cli..."

    # Supprimer les fichiers d'installation
    rm -rf "$INSTALL_DIR"
    rm -f "$BIN_DIR/lm"
    rm -f "$BIN_DIR/lm.bat"

    # Nettoyer les configurations shell (optionnel)
    log_warning "N'oubliez pas de retirer $BIN_DIR de votre PATH si nécessaire"

    log_success "Désinstallation terminée"
}

# Liste des versions disponibles
list_versions() {
    log_info "Récupération des versions disponibles..."
    get_all_releases
}

# Fonction principale
main() {
    local version="latest"
    local action="install"

    # Parsing des arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--version)
                version="$2"
                shift 2
                ;;
            -l|--list)
                action="list"
                shift
                ;;
            -u|--uninstall)
                action="uninstall"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Option inconnue: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Détection de l'OS
    OS=$(detect_os)
    log_info "Système détecté: $OS"

    case "$action" in
        install)
            check_dependencies

            if [ "$version" = "latest" ]; then
                version=$(get_latest_release)
                log_info "Dernière version: $version"
            fi

            install_release "$version"
            setup_shell
            verify_installation
            ;;
        list)
            list_versions
            ;;
        uninstall)
            uninstall
            ;;
    esac
}

# Point d'entrée
main "$@"