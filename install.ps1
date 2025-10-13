#intall.ps1
# Script d'installation pour Windows
param(
    [string]$Version = "latest",
    [switch]$List,
    [switch]$Uninstall,
    [switch]$Help
)

# Variables
$RepoOwner = "lmlouis"
$RepoName = "lm-cli"
$InstallDir = "$env:USERPROFILE\.lm-cli"
$BinDir = "$env:USERPROFILE\AppData\Local\Programs\lm-cli"
$BackupDir = "$env:USERPROFILE\.lm-cli-backup"

# Fonctions
function Write-ColorOutput($Color, $Message) {
    Write-Host $Message -ForegroundColor $Color
}

function Get-LatestRelease {
    $apiUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest"
    try {
        $response = Invoke-RestMethod -Uri $apiUrl
        return $response.tag_name
    }
    catch {
        Write-ColorOutput "Red" "Erreur lors de la récupération de la dernière version"
        exit 1
    }
}

function Install-Release {
    param([string]$Version)

    Write-ColorOutput "Blue" "Installation de la version $Version..."

    # Créer les répertoires
    New-Item -ItemType Directory -Force -Path $InstallDir
    New-Item -ItemType Directory -Force -Path $BinDir

    # URL de téléchargement
    $downloadUrl = "https://github.com/$RepoOwner/$RepoName/archive/refs/tags/$Version.zip"
    $tempFile = "$env:TEMP\lm-cli-$Version.zip"

    # Télécharger
    try {
        Write-ColorOutput "Yellow" "Téléchargement depuis $downloadUrl..."
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile
    }
    catch {
        Write-ColorOutput "Red" "Erreur lors du téléchargement"
        exit 1
    }

    # Extraire
    try {
        Write-ColorOutput "Yellow" "Extraction de l'archive..."
        Expand-Archive -Path $tempFile -DestinationPath "$env:TEMP\" -Force

        # Trouver le répertoire extrait
        $extractedDir = Get-ChildItem -Path "$env:TEMP" -Directory | Where-Object { $_.Name -like "lm-cli-*" } | Select-Object -First 1

        if (-not $extractedDir) {
            Write-ColorOutput "Red" "Impossible de trouver le répertoire extrait"
            exit 1
        }

        Write-ColorOutput "Yellow" "Copie des fichiers depuis $($extractedDir.FullName)..."
        Copy-Item -Path "$($extractedDir.FullName)\*" -Destination $InstallDir -Recurse -Force
    }
    catch {
        Write-ColorOutput "Red" "Erreur lors de l'extraction: $($_.Exception.Message)"
        exit 1
    }

    # Créer le script wrapper
    $wrapperContent = @"
@echo off
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=$InstallDir"
set "CURRENT_DIR=%CD%"

cd /d "!SCRIPT_DIR!"
bash java.sh %*
set EXIT_CODE=!ERRORLEVEL!
cd /d "!CURRENT_DIR!"

exit /b !EXIT_CODE!
"@

    $wrapperContent | Out-File -FilePath "$BinDir\lm.bat" -Encoding ASCII

    # Configuration automatique du PATH
    Write-ColorOutput "Yellow" "Configuration du PATH..."

    # Méthode 1: PATH utilisateur (recommandé)
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($userPath -notlike "*$BinDir*") {
        [Environment]::SetEnvironmentVariable("PATH", "$userPath;$BinDir", "User")
        Write-ColorOutput "Green" "✓ PATH utilisateur mis à jour"
    }

    # Méthode 2: PATH session courante
    $env:PATH += ";$BinDir"

    # Nettoyer
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    if ($extractedDir) {
        Remove-Item $extractedDir.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-ColorOutput "Green" "Installation terminée avec succès!"
    Write-ColorOutput "Yellow" "Le chemin $BinDir a été ajouté à votre PATH"
    Write-ColorOutput "Yellow" "Ouvrez un NOUVEAU terminal et exécutez: lm --help"
}

function Show-Help {
    Write-Host @"
Usage: install.ps1 [OPTIONS]

Options:
  -Version VERSION    Installer une version spécifique (ex: v1.0.8)
  -List               Lister les versions disponibles
  -Uninstall          Désinstaller
  -Help               Afficher cette aide

Exemples:
  .\install.ps1                    Installer la dernière version
  .\install.ps1 -Version v1.0.8    Installer une version spécifique
"@
}

# Point d'entrée principal
if ($Help) {
    Show-Help
    exit 0
}

if ($Uninstall) {
    Write-ColorOutput "Blue" "Désinstallation..."
    Remove-Item $InstallDir -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $BinDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-ColorOutput "Green" "Désinstallation terminée"
    exit 0
}

if ($List) {
    Write-ColorOutput "Blue" "Récupération des versions..."
    # Implémentez la liste des versions si nécessaire
    exit 0
}

if ($Version -eq "latest") {
    $Version = Get-LatestRelease
}

Install-Release -Version $Version