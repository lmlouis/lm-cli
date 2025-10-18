# Script d'installation pour Windows
param(
    [string]$Version = "latest",
    [switch]$List,
    [switch]$Uninstall,
    [switch]$Backup,
    [switch]$Help
)

# Variables
$RepoOwner = "lmlouis"
$RepoName = "lm-cli"
$InstallDir = "$env:USERPROFILE\.lm-cli"
$BinDir = "$env:USERPROFILE\.local\bin"
$BackupDir = "$env:USERPROFILE\.lm-cli-backup"

# Fonctions
function Write-ColorOutput {
    param(
        [string]$Color,
        [string]$Message
    )

    $colorMap = @{
        "Red"    = "Red"
        "Green"  = "Green"
        "Yellow" = "Yellow"
        "Blue"   = "Cyan"
    }

    Write-Host $Message -ForegroundColor $colorMap[$Color]
}

function Get-LatestRelease {
    $apiUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest"
    try {
        $response = Invoke-RestMethod -Uri $apiUrl
        return $response.tag_name
    }
    catch {
        Write-ColorOutput "Red" "❌ Erreur lors de la récupération de la dernière version"
        exit 1
    }
}

function Test-GitBashInstalled {
    # Vérifier si Git Bash est installé
    $gitBashPaths = @(
        "$env:ProgramFiles\Git\bin\bash.exe",
        "${env:ProgramFiles(x86)}\Git\bin\bash.exe",
        "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
    )

    foreach ($path in $gitBashPaths) {
        if (Test-Path $path) {
            return $path
        }
    }

    return $null
}

function Install-GitBash {
    Write-ColorOutput "Yellow" "⚠️  Git Bash n'est pas installé"
    Write-ColorOutput "Yellow" "📥 Git Bash est requis pour exécuter lm-cli sous Windows"
    Write-ColorOutput "Blue" "Visitez: https://git-scm.com/download/win"

    $response = Read-Host "Voulez-vous ouvrir la page de téléchargement? (o/n)"
    if ($response -eq "o" -or $response -eq "O") {
        Start-Process "https://git-scm.com/download/win"
    }

    exit 1
}

function Create-WrapperScript {
    param([string]$BashPath)

    Write-ColorOutput "Yellow" "📝 Création du script wrapper..."

    # Créer le répertoire bin s'il n'existe pas
    New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

    # Script batch wrapper qui maintient le contexte du répertoire courant
    $wrapperContent = @"
@echo off
setlocal EnableDelayedExpansion

REM Wrapper pour lm-cli
REM Ce script maintient le contexte du répertoire courant

set "INSTALL_DIR=$InstallDir"
set "CURRENT_DIR=%CD%"
set "BASH_PATH=$BashPath"

REM Vérifier que java.sh existe
if not exist "!INSTALL_DIR!\java.sh" (
    echo ❌ Le fichier java.sh est introuvable dans !INSTALL_DIR!
    exit /b 1
)

REM Exécuter java.sh depuis le répertoire courant (IMPORTANT!)
REM Le script java.sh doit générer les fichiers dans le projet Spring Boot, pas dans INSTALL_DIR
cd /d "!CURRENT_DIR!"
"!BASH_PATH!" "!INSTALL_DIR!\java.sh" %*
set EXIT_CODE=!ERRORLEVEL!

exit /b !EXIT_CODE!
"@

    $wrapperContent | Out-File -FilePath "$BinDir\lm.bat" -Encoding ASCII -Force

    Write-ColorOutput "Green" "✅ Wrapper créé: $BinDir\lm.bat"
}

function Install-Release {
    param([string]$Version)

    Write-ColorOutput "Blue" "📦 Installation de lm-cli version $Version..."

    # Vérifier Git Bash
    $bashPath = Test-GitBashInstalled
    if (-not $bashPath) {
        Install-GitBash
        return
    }

    Write-ColorOutput "Green" "✅ Git Bash trouvé: $bashPath"

    # Créer les répertoires
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

    # URL de téléchargement
    $downloadUrl = "https://github.com/$RepoOwner/$RepoName/archive/refs/tags/$Version.zip"
    $tempFile = "$env:TEMP\lm-cli-$Version.zip"
    $tempExtract = "$env:TEMP\lm-cli-extract"

    # Télécharger
    try {
        Write-ColorOutput "Yellow" "📥 Téléchargement depuis $downloadUrl..."
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile -UseBasicParsing
    }
    catch {
        Write-ColorOutput "Red" "❌ Erreur lors du téléchargement: $($_.Exception.Message)"
        exit 1
    }

    # Extraire
    try {
        Write-ColorOutput "Yellow" "📂 Extraction de l'archive..."

        # Nettoyer le répertoire d'extraction s'il existe
        if (Test-Path $tempExtract) {
            Remove-Item $tempExtract -Recurse -Force
        }

        Expand-Archive -Path $tempFile -DestinationPath $tempExtract -Force

        # Trouver le répertoire extrait
        $extractedDir = Get-ChildItem -Path $tempExtract -Directory | Select-Object -First 1

        if (-not $extractedDir) {
            Write-ColorOutput "Red" "❌ Impossible de trouver le répertoire extrait"
            exit 1
        }

        Write-ColorOutput "Yellow" "📋 Copie des fichiers depuis $($extractedDir.FullName)..."

        # Copier tous les fichiers
        Get-ChildItem -Path $extractedDir.FullName -Recurse | ForEach-Object {
            $targetPath = $_.FullName.Replace($extractedDir.FullName, $InstallDir)
            if ($_.PSIsContainer) {
                New-Item -ItemType Directory -Force -Path $targetPath | Out-Null
            } else {
                Copy-Item -Path $_.FullName -Destination $targetPath -Force
            }
        }

        Write-ColorOutput "Green" "✅ Fichiers copiés avec succès"
    }
    catch {
        Write-ColorOutput "Red" "❌ Erreur lors de l'extraction: $($_.Exception.Message)"
        exit 1
    }

    # Créer le script wrapper
    Create-WrapperScript -BashPath $bashPath

    # Configuration automatique du PATH
    Write-ColorOutput "Yellow" "🔧 Configuration du PATH..."

    # Vérifier si le BinDir est déjà dans le PATH
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")

    if ($userPath -notlike "*$BinDir*") {
        # Ajouter au PATH utilisateur
        $newPath = "$BinDir;$userPath"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        Write-ColorOutput "Green" "✅ PATH utilisateur mis à jour"

        # Mettre à jour le PATH de la session courante
        $env:PATH = "$BinDir;$env:PATH"
    } else {
        Write-ColorOutput "Yellow" "⚠️  $BinDir est déjà dans le PATH"
    }

    # Nettoyer
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue

    Write-ColorOutput "Green" "✅ Installation terminée avec succès!"
    Write-ColorOutput "Yellow" "ℹ️  Ouvrez un NOUVEAU terminal (PowerShell ou CMD)"
    Write-ColorOutput "Yellow" "ℹ️  Testez avec: lm --help"
    Write-ColorOutput "Blue" ""
    Write-ColorOutput "Blue" "📖 Note importante:"
    Write-ColorOutput "Blue" "   - Utilisez 'lm' depuis n'importe quel répertoire de projet Spring Boot"
    Write-ColorOutput "Blue" "   - Les fichiers seront générés dans votre projet, pas dans $InstallDir"
}

function Uninstall-LmCli {
    Write-ColorOutput "Blue" "🗑️  Désinstallation de lm-cli..."

    # Sauvegarder si demandé
    if ($Backup) {
        if (Test-Path $InstallDir) {
            $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
            $backupPath = "$BackupDir\backup-$timestamp"

            Write-ColorOutput "Yellow" "💾 Sauvegarde dans $backupPath..."
            New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
            Copy-Item -Path $InstallDir -Destination $backupPath -Recurse -Force
            Write-ColorOutput "Green" "✅ Sauvegarde créée"
        }
    }

    # Supprimer les fichiers
    if (Test-Path $InstallDir) {
        Remove-Item $InstallDir -Recurse -Force
        Write-ColorOutput "Green" "✅ Répertoire d'installation supprimé"
    }

    if (Test-Path "$BinDir\lm.bat") {
        Remove-Item "$BinDir\lm.bat" -Force
        Write-ColorOutput "Green" "✅ Script lm.bat supprimé"
    }

    # Retirer du PATH
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($userPath -like "*$BinDir*") {
        $newPath = $userPath -replace [regex]::Escape("$BinDir;"), ""
        $newPath = $newPath -replace [regex]::Escape(";$BinDir"), ""
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        Write-ColorOutput "Green" "✅ PATH nettoyé"
    }

    Write-ColorOutput "Green" "✅ Désinstallation terminée"
    Write-ColorOutput "Yellow" "ℹ️  Redémarrez votre terminal pour appliquer les changements"
}

function Show-Help {
    Write-Host @"
Usage: install.ps1 [OPTIONS]

Options:
  -Version VERSION    Installer une version spécifique (ex: v1.1.3)
  -List               Lister les versions disponibles
  -Uninstall          Désinstaller lm-cli
  -Backup             Sauvegarder avant désinstallation
  -Help               Afficher cette aide

Exemples:
  .\install.ps1                      Installer la dernière version
  .\install.ps1 -Version v1.1.3      Installer une version spécifique
  .\install.ps1 -Uninstall           Désinstaller
  .\install.ps1 -Uninstall -Backup   Désinstaller avec sauvegarde

Installation automatique (PowerShell):
  irm https://raw.githubusercontent.com/lmlouis/lm-cli/main/install.ps1 | iex

Prérequis:
  - Git Bash doit être installé (https://git-scm.com/download/win)
  - Java et Maven doivent être installés pour utiliser lm-cli

"@
}

function Show-Versions {
    Write-ColorOutput "Blue" "📋 Récupération des versions disponibles..."

    try {
        $apiUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/releases"
        $releases = Invoke-RestMethod -Uri $apiUrl

        Write-ColorOutput "Green" "Versions disponibles:"
        foreach ($release in $releases) {
            $version = $release.tag_name
            $date = ([DateTime]$release.published_at).ToString("yyyy-MM-dd")
            Write-Host "  $version - $date" -ForegroundColor Cyan
        }
    }
    catch {
        Write-ColorOutput "Red" "❌ Erreur lors de la récupération des versions"
    }
}

# Point d'entrée principal
if ($Help) {
    Show-Help
    exit 0
}

if ($List) {
    Show-Versions
    exit 0
}

if ($Uninstall) {
    Uninstall-LmCli
    exit 0
}

if ($Version -eq "latest") {
    $Version = Get-LatestRelease
    Write-ColorOutput "Blue" "📌 Dernière version: $Version"
}

Install-Release -Version $Version