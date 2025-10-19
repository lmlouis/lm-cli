#!/bin/bash
# install.sh - Script d'installation multi-OS pour lm-cli

set -e

# Variables
REPO_OWNER="lmlouis"
REPO_NAME="lm-cli"
INSTALL_DIR="$HOME/.lm-cli"
BIN_DIR="$HOME/.local/bin"
BACKUP_DIR="$HOME/.lm-cli-backup"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions
print_color() {
    local color=$1
    shift
    # shellcheck disable=SC2145
    echo -e "${color}$@${NC}"
}

get_latest_release() {
    local api_url="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest"

    if command -v curl &> /dev/null; then
        curl -s $api_url | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
    elif command -v wget &> /dev/null; then
        wget -q -O - $api_url | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
    else
        print_color $RED "❌ Ni curl ni wget n'est disponible"
        exit 1
    fi
}

create_wrapper_script() {
    print_color $YELLOW "📝 Création du script wrapper..."

    cat > "$BIN_DIR/lm" << 'EOF'
#!/bin/bash
# Wrapper pour lm-cli
# Ce script maintient le contexte du répertoire courant

SCRIPT_DIR="$HOME/.lm-cli"
CURRENT_DIR="$PWD"

if [ ! -f "$SCRIPT_DIR/java.sh" ]; then
    echo "❌ Le fichier java.sh est introuvable dans $SCRIPT_DIR"
    exit 1
fi

# S'assurer que le script est exécutable
chmod +x "$SCRIPT_DIR/java.sh" 2>/dev/null

# Exécuter java.sh depuis le répertoire courant (IMPORTANT!)
# Le script java.sh doit générer les fichiers dans $PWD, pas dans $SCRIPT_DIR
exec "$SCRIPT_DIR/java.sh" "$@"
EOF

    chmod +x "$BIN_DIR/lm"
    print_color $GREEN "✅ Wrapper créé: $BIN_DIR/lm"
}

install_lm_cli() {
    local version=$1

    print_color $BLUE "📦 Installation de lm-cli version $version..."

    # Créer les répertoires
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$BIN_DIR"

    # URL de téléchargement
    local download_url="https://github.com/$REPO_OWNER/$REPO_NAME/archive/refs/tags/$version.tar.gz"
    local temp_file="/tmp/lm-cli-$version.tar.gz"

    # Télécharger
    print_color $YELLOW "📥 Téléchargement depuis $download_url..."
    if command -v curl &> /dev/null; then
        curl -L -o "$temp_file" "$download_url"
    elif command -v wget &> /dev/null; then
        wget -O "$temp_file" "$download_url"
    else
        print_color $RED "❌ Ni curl ni wget n'est disponible"
        exit 1
    fi

    # Extraire
    print_color $YELLOW "📂 Extraction de l'archive..."
    tar -xzf "$temp_file" -C /tmp/

    # Trouver le répertoire extrait
    local extracted_dir=$(ls -d /tmp/lm-cli-* | head -1)

    if [ -z "$extracted_dir" ]; then
        print_color $RED "❌ Impossible de trouver le répertoire extrait"
        exit 1
    fi

    # Copier les fichiers
    print_color $YELLOW "📋 Copie des fichiers..."
    cp -r "$extracted_dir"/* "$INSTALL_DIR/"

    # Créer le wrapper
    create_wrapper_script

    # Nettoyer
    rm -f "$temp_file"
    rm -rf "$extracted_dir"

    print_color $GREEN "✅ Installation terminée avec succès!"
    print_color $YELLOW "ℹ️  Redémarrez votre terminal ou exécutez: source ~/.bashrc"
    print_color $YELLOW "ℹ️  Testez avec: lm --help"
}

configure_path() {
    print_color $YELLOW "🔧 Configuration du PATH..."

    # Détecter le shell
    local shell_config=""
    if [ -n "$BASH_VERSION" ]; then
        shell_config="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        shell_config="$HOME/.zshrc"
    else
        shell_config="$HOME/.profile"
    fi

    # Vérifier si le PATH est déjà configuré
    if ! grep -q "/.local/bin" "$shell_config" 2>/dev/null; then
        echo "" >> "$shell_config"
        echo "# lm-cli PATH" >> "$shell_config"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_config"
        print_color $GREEN "✅ PATH ajouté à $shell_config"
    else
        print_color $YELLOW "⚠️  PATH déjà configuré dans $shell_config"
    fi

    # Charger l'autocomplétion si disponible
    if [ -f "$INSTALL_DIR/autocomplete.sh" ]; then
        if ! grep -q "lm-cli autocomplete" "$shell_config" 2>/dev/null; then
            echo "" >> "$shell_config"
            echo "# lm-cli autocomplete" >> "$shell_config"
            echo "[ -f \"$HOME/.lm-cli/autocomplete.sh\" ] && source \"$HOME/.lm-cli/autocomplete.sh\"" >> "$shell_config"
            print_color $GREEN "✅ Autocomplétion configurée"
        fi
    fi
}

uninstall_lm_cli() {
    print_color $BLUE "🗑️  Désinstallation de lm-cli..."

    # Sauvegarder si demandé
    if [ "$1" == "--backup" ]; then
        if [ -d "$INSTALL_DIR" ]; then
            print_color $YELLOW "💾 Sauvegarde dans $BACKUP_DIR..."
            mkdir -p "$BACKUP_DIR"
            cp -r "$INSTALL_DIR" "$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S)"
        fi
    fi

    # Supprimer les fichiers
    rm -rf "$INSTALL_DIR"
    rm -f "$BIN_DIR/lm"

    # Nettoyer les configurations shell
    for config in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
        if [ -f "$config" ]; then
            sed -i.bak '/# lm-cli/d' "$config" 2>/dev/null || true
            sed -i.bak '/\.lm-cli/d' "$config" 2>/dev/null || true
        fi
    done

    print_color $GREEN "✅ Désinstallation terminée"
    print_color $YELLOW "ℹ️  Redémarrez votre terminal pour appliquer les changements"
}

show_help() {
    cat << EOF
Usage: install.sh [OPTIONS]

Options:
  -v, --version VERSION    Installer une version spécifique (ex: v1.1.3)
  -u, --uninstall         Désinstaller lm-cli
  --backup                Sauvegarder avant désinstallation
  -h, --help              Afficher cette aide

Exemples:
  ./install.sh                    Installer la dernière version
  ./install.sh -v v1.1.3          Installer une version spécifique
  ./install.sh -u                 Désinstaller
  ./install.sh -u --backup        Désinstaller avec sauvegarde

Installation automatique:
  curl -fsSL https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash
  wget -qO- https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.sh | bash

EOF
}

# Point d'entrée principal
main() {
    local version="latest"
    local action="install"
    local backup=false

    # Parser les arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--version)
                version="$2"
                shift 2
                ;;
            -u|--uninstall)
                action="uninstall"
                shift
                ;;
            --backup)
                backup=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_color $RED "Option inconnue: $1"
                show_help
                exit 1
                ;;
        esac
    done

    case $action in
        install)
            if [ "$version" == "latest" ]; then
                version=$(get_latest_release)
                print_color $BLUE "📌 Dernière version: $version"
            fi
            install_lm_cli "$version"
            configure_path
            ;;
        uninstall)
            if [ "$backup" == true ]; then
                uninstall_lm_cli "--backup"
            else
                uninstall_lm_cli
            fi
            ;;
    esac
}

main "$@"