# autocomplete.ps1 - Autocomplétion PowerShell pour lm-cli
# Compatible PowerShell 5.1+ et PowerShell Core 7+

# Fonction pour vérifier la présence d'un pom.xml
function Test-SpringBootProject {
    $currentDir = Get-Location
    while ($currentDir) {
        if (Test-Path (Join-Path $currentDir "pom.xml")) {
            return $true
        }
        $currentDir = Split-Path $currentDir -Parent
    }
    return $false
}

# Fonction d'autocomplétion principale
$scriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $hasPom = Test-SpringBootProject

    # Extraire les mots de la ligne de commande
    $line = $commandAst.ToString()
    $words = $line -split '\s+' | Where-Object { $_ -ne '' }
    $wordCount = $words.Count

    # Commandes de gestion
    $mgmtCommands = @(
        @{ Name = 'update'; Description = 'Mettre à jour lm-cli' }
        @{ Name = 'install'; Description = 'Installer une version spécifique' }
        @{ Name = 'uninstall'; Description = 'Désinstaller lm-cli' }
        @{ Name = 'version'; Description = 'Afficher la version' }
    )

    # Options globales
    $globalOptions = @(
        @{ Name = '--force'; Description = 'Écraser les fichiers existants' }
        @{ Name = '--package'; Description = 'Spécifier un package personnalisé' }
        @{ Name = '--help'; Description = 'Afficher l''aide' }
    )

    # Sous-commandes create
    $createCommands = @(
        @{ Name = 'config'; Description = 'Créer une configuration' }
        @{ Name = 'exception'; Description = 'Créer une exception' }
        @{ Name = 'constant'; Description = 'Créer une classe de constantes' }
        @{ Name = 'security'; Description = 'Créer une configuration de sécurité' }
        @{ Name = 'pagination'; Description = 'Créer le système de pagination' }
        @{ Name = 'filter'; Description = 'Créer le système de filtrage' }
        @{ Name = 'dto'; Description = 'Créer un DTO' }
        @{ Name = 'mapper'; Description = 'Créer un mapper' }
        @{ Name = 'domain'; Description = 'Créer une entité' }
        @{ Name = 'repository'; Description = 'Créer un repository' }
        @{ Name = 'service'; Description = 'Créer un service' }
        @{ Name = 'rest'; Description = 'Créer un contrôleur REST' }
        @{ Name = 'changelog'; Description = 'Créer un changelog' }
        @{ Name = 'application'; Description = 'Créer application.yml' }
    )

    # Fonction helper pour créer les complétions
    function New-Completion {
        param($Name, $Description)
        [System.Management.Automation.CompletionResult]::new(
            $Name,
            $Name,
            'ParameterValue',
            $Description
        )
    }

    # Niveau 1: Commande principale (lm ...)
    if ($wordCount -eq 1 -or ($wordCount -eq 2 -and $wordToComplete)) {
        $results = @()

        # Ajouter create si pom.xml existe
        if ($hasPom) {
            $results += New-Completion 'create' 'Créer des composants Spring Boot'
        }

        # Ajouter les commandes de gestion
        foreach ($cmd in $mgmtCommands) {
            if ($cmd.Name -like "$wordToComplete*") {
                $results += New-Completion $cmd.Name $cmd.Description
            }
        }

        # Ajouter les options globales
        foreach ($opt in $globalOptions) {
            if ($opt.Name -like "$wordToComplete*") {
                $results += New-Completion $opt.Name $opt.Description
            }
        }

        return $results
    }

    $command = $words[1]

    # Niveau 2: Sous-commande (lm create ...)
    if ($wordCount -eq 2 -or ($wordCount -eq 3 -and $wordToComplete)) {
        if ($command -eq 'create' -and $hasPom) {
            return $createCommands | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                New-Completion $_.Name $_.Description
            }
        }
        elseif ($command -eq 'install') {
            $versions = @('latest', 'v1.2.5', 'v1.2.4', 'v1.2.3')
            return $versions | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                New-Completion $_ "Version $_"
            }
        }
    }

    # Niveau 3: Nom ou options (lm create config ...)
    if ($wordCount -ge 3) {
        $subcommand = $words[2]

        $suggestions = switch ($subcommand) {
            'config' {
                @{
                    Names = @('Database', 'Security', 'Email', 'Cache', 'Redis', 'OAuth', 'Swagger', 'CORS')
                    Options = @('--properties', '--force')
                }
            }
            'exception' {
                @{
                    Names = @('NotFound', 'BadRequest', 'Unauthorized', 'Forbidden', 'Validation')
                    Options = @('--force')
                }
            }
            'constant' {
                @{
                    Names = @('Application', 'Api', 'Database', 'Status', 'ErrorCode')
                    Options = @('--force')
                }
            }
            'security' {
                @{
                    Names = @('JwtUtil', 'SecurityConfig', 'UserDetailsService', 'AuthenticationFilter')
                    Options = @('--force')
                }
            }
            'dto' {
                @{
                    Names = @('User', 'Product', 'Order', 'Customer', 'Invoice', 'Payment')
                    Options = @('--record', '--force')
                }
            }
            'mapper' {
                @{
                    Names = @('User', 'Product', 'Order', 'EntityMapper')
                    Options = @('--init', '--force')
                }
            }
            'domain' {
                @{
                    Names = @('User', 'Product', 'Order', 'Customer', 'Invoice', 'Status', 'Role')
                    Options = @('--enum', '--entity', '--force')
                }
            }
            'repository' {
                @{
                    Names = @('User', 'Product', 'Order', 'Customer', 'Invoice')
                    Options = @('--force')
                }
            }
            'service' {
                @{
                    Names = @('User', 'Product', 'Order', 'Customer', 'Invoice', 'Email', 'Notification')
                    Options = @('--mapper', '--criteria', '--query', '--implement', '--class', '--force')
                }
            }
            'rest' {
                @{
                    Names = @('User', 'Product', 'Order', 'Customer', 'Invoice', 'Auth', 'Admin')
                    Options = @('--force')
                }
            }
            'changelog' {
                @{
                    Names = @('initial', 'create_users', 'create_products', 'add_indexes')
                    Options = @('--init', '--data', '--sql', '--force')
                }
            }
            'application' {
                @{
                    Names = @('dev', 'prod', 'test', 'staging', 'local')
                    Options = @('--yml', '--properties', '--force')
                }
            }
            'pagination' {
                @{
                    Names = @()
                    Options = @('--force')
                }
            }
            'filter' {
                @{
                    Names = @()
                    Options = @('--force')
                }
            }
            default {
                @{
                    Names = @()
                    Options = @('--force', '--package')
                }
            }
        }

        $results = @()

        # Ajouter les noms suggérés
        if ($wordToComplete -notlike '--*') {
            foreach ($name in $suggestions.Names) {
                if ($name -like "$wordToComplete*") {
                    $results += New-Completion $name "Nom suggéré: $name"
                }
            }
        }

        # Ajouter les options
        foreach ($option in $suggestions.Options) {
            if ($option -like "$wordToComplete*") {
                $results += New-Completion $option "Option: $option"
            }
        }

        return $results
    }
}

# Enregistrer l'autocomplétion pour la commande 'lm'
Register-ArgumentCompleter -CommandName lm -ScriptBlock $scriptBlock

Write-Host "✅ Autocomplétion lm-cli chargée pour PowerShell" -ForegroundColor Green

if (-not (Test-SpringBootProject)) {
    Write-Host "⚠️  Pas de pom.xml - la commande 'create' ne sera pas disponible" -ForegroundColor Yellow
}