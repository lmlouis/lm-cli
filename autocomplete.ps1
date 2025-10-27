# autocomplete.ps1 - Autocomplétion PowerShell pour lm-cli
# Compatible PowerShell 5.1+ et PowerShell Core 7+

# Fonction pour vérifier la présence d'un pom.xml
function Test-SpringBootProject {
    $currentDir = Get-Location
    while ($currentDir -and $currentDir -ne [System.IO.Path]::GetPathRoot($currentDir)) {
        if (Test-Path (Join-Path $currentDir "pom.xml")) {
            return $true
        }
        $currentDir = Split-Path $currentDir -Parent
    }
    return $false
}

# Fonction d'autocomplétion principale
$scriptBlock = {
    param($wordToComplete, $commandAst, $cursorPosition)

    $hasPom = Test-SpringBootProject

    # Extraire les mots de la ligne de commande
    $line = $commandAst.ToString()
    $words = $line -split '\s+' | Where-Object { $_ -ne '' }
    $wordCount = $words.Count

    # Commandes principales
    $mainCommands = @()
    
    if ($hasPom) {
        $mainCommands += @{ Name = 'create'; Description = 'Créer des composants Spring Boot' }
    }
    
    $mainCommands += @(
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
    if ($wordCount -eq 1 -or ($wordCount -eq 2 -and $words[0] -eq 'lm' -and $wordToComplete)) {
        $results = @()

        # Ajouter les commandes principales
        foreach ($cmd in $mainCommands) {
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

    # Niveau 2: Sous-commande (lm create ...)
    if ($wordCount -eq 2 -and $words[0] -eq 'lm' -and $words[1] -eq 'create') {
        return $createCommands | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
            New-Completion $_.Name $_.Description
        }
    }

    # Niveau 3: Nom ou options (lm create config ...)
    if ($wordCount -ge 3 -and $words[0] -eq 'lm' -and $words[1] -eq 'create') {
        $subcommand = $words[2]

        $suggestions = @{
            Names = @()
            Options = @('--force')
        }

        switch ($subcommand) {
            'config' {
                $suggestions.Names = @('Database', 'Security', 'Email', 'Cache', 'Redis', 'OAuth', 'Swagger', 'CORS')
                $suggestions.Options += '--properties'
            }
            'exception' {
                $suggestions.Names = @('NotFound', 'BadRequest', 'Unauthorized', 'Forbidden', 'Validation')
            }
            'constant' {
                $suggestions.Names = @('Application', 'Api', 'Database', 'Status', 'ErrorCode')
            }
            'security' {
                $suggestions.Names = @('JwtUtil', 'SecurityConfig', 'UserDetailsService', 'AuthenticationFilter')
            }
            'dto' {
                $suggestions.Names = @('User', 'Product', 'Order', 'Customer', 'Invoice', 'Payment')
                $suggestions.Options += '--record'
            }
            'mapper' {
                $suggestions.Names = @('User', 'Product', 'Order', 'EntityMapper')
                $suggestions.Options += '--init'
            }
            'domain' {
                $suggestions.Names = @('User', 'Product', 'Order', 'Customer', 'Invoice', 'Status', 'Role')
                $suggestions.Options += '--enum', '--entity'
            }
            'repository' {
                $suggestions.Names = @('User', 'Product', 'Order', 'Customer', 'Invoice')
            }
            'service' {
                $suggestions.Names = @('User', 'Product', 'Order', 'Customer', 'Invoice', 'Email', 'Notification')
                $suggestions.Options += '--mapper', '--criteria', '--query', '--implement', '--class'
            }
            'rest' {
                $suggestions.Names = @('User', 'Product', 'Order', 'Customer', 'Invoice', 'Auth', 'Admin')
            }
            'changelog' {
                $suggestions.Names = @('initial', 'create_users', 'create_products', 'add_indexes')
                $suggestions.Options += '--init', '--data', '--sql'
            }
            'application' {
                $suggestions.Names = @('dev', 'prod', 'test', 'staging', 'local')
                $suggestions.Options += '--yml', '--properties'
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

    return $null
}

# Enregistrer l'autocomplétion pour la commande 'lm'
Register-ArgumentCompleter -CommandName lm -ScriptBlock $scriptBlock

Write-Host "✅ Autocomplétion lm-cli chargée pour PowerShell" -ForegroundColor Green
