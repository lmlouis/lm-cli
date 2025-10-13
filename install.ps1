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
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile
    }
    catch {
        Write-ColorOutput "Red" "Erreur lors du téléchargement"
        exit 1
    }

    # Extraire
    try {
        Expand-Archive -Path $tempFile -DestinationPath "$env:TEMP\" -Force
        $extractedDir = "$env:TEMP\lm-cli-${Version.Substring(1)}"
        Copy-Item -Path "$extractedDir\*" -Destination $InstallDir -Recurse -Force
    }
    catch {
        Write-ColorOutput "Red" "Erreur lors de l'extraction"
        exit 1
    }

    # Créer le script wrapper
    $wrapperContent = @"
@echo off
setlocal

set "SCRIPT_DIR=$InstallDir"
set "PWD=%CD%"

cd /d "%SCRIPT_DIR%"
bash java.sh %*
cd /d "%PWD%"
"@

    $wrapperContent | Out-File -FilePath "$BinDir\lm.bat" -Encoding ASCII

    # Nettoyer
    Remove-Item $tempFile -Force
    Remove-Item $extractedDir -Recurse -Force

    Write-ColorOutput "Green" "Installation terminée avec succès!"
    Write-ColorOutput "Yellow" "Ajoutez $BinDir à votre variable d'environnement PATH"
}

function Show-Help {
    Write-Host @"
Usage: install.ps1 [OPTIONS]

Options:
  -Version VERSION    Installer une version spécifique (ex: 1.0.8)
  -List               Lister les versions disponibles
  -Uninstall          Désinstaller
  -Help               Afficher cette aide

Exemples:
  .\install.ps1                    Installer la dernière version
  .\install.ps1 -Version 1.0.8    Installer une version spécifique
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
