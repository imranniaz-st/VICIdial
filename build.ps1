#################################################################################
# VICIdial Docker Build and Deploy Script (PowerShell for Windows)
# 
# This script helps build and deploy VICIdial using Docker on Windows
# Usage: .\build.ps1 [command]
# Commands: build, up, down, rebuild, logs, clean, help
#################################################################################

param(
    [Parameter(Position = 0)]
    [ValidateSet('build', 'rebuild', 'up', 'down', 'rm', 'logs', 'clean', 'status', 'help')]
    [string]$Command = 'help'
)

# Colors for output
$Colors = @{
    'Red' = [ConsoleColor]::Red
    'Green' = [ConsoleColor]::Green
    'Yellow' = [ConsoleColor]::Yellow
    'Blue' = [ConsoleColor]::Blue
    'Gray' = [ConsoleColor]::Gray
}

function Print-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor $Colors['Blue']
    Write-Host "║ $Message" -ForegroundColor $Colors['Blue']
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor $Colors['Blue']
    Write-Host ""
}

function Print-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor $Colors['Green']
}

function Print-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor $Colors['Red']
}

function Print-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor $Colors['Yellow']
}

function Check-Requirements {
    Print-Header "Checking Requirements"
    
    # Check Docker
    try {
        docker --version > $null 2>&1
        Print-Success "Docker is installed"
    }
    catch {
        Print-Error "Docker is not installed. Please install Docker Desktop for Windows."
        exit 1
    }
    
    # Check Docker Compose
    try {
        docker-compose --version > $null 2>&1
        Print-Success "Docker Compose is installed"
    }
    catch {
        Print-Error "Docker Compose is not installed."
        exit 1
    }
}

function Build-Image {
    Print-Header "Building VICIdial Docker Image"
    
    if (-not (Test-Path "Dockerfile")) {
        Print-Error "Dockerfile not found in current directory"
        exit 1
    }
    
    Print-Info "Building image: vicidial:latest"
    docker build -t vicidial:latest .
    Print-Success "Image built successfully!"
}

function Build-ImageNoCache {
    Print-Header "Building VICIdial Docker Image (No Cache)"
    
    if (-not (Test-Path "Dockerfile")) {
        Print-Error "Dockerfile not found in current directory"
        exit 1
    }
    
    Print-Info "Building image without cache: vicidial:latest"
    docker build --no-cache -t vicidial:latest .
    Print-Success "Image built successfully!"
}

function Start-Containers {
    Print-Header "Starting VICIdial Services"
    
    if (-not (Test-Path "docker-compose.yml")) {
        Print-Error "docker-compose.yml not found in current directory"
        exit 1
    }
    
    Print-Info "Starting containers using docker-compose..."
    docker-compose up -d
    
    Print-Success "Containers started successfully!"
    
    Write-Host ""
    Print-Info "Waiting for services to initialize (30 seconds)..."
    Start-Sleep -Seconds 30
    
    Print-Header "Service Status"
    docker-compose ps
    
    Write-Host ""
    Print-Header "Access Information"
    Write-Host "Web Interface:     http://localhost" -ForegroundColor $Colors['Green']
    Write-Host "Admin Username:    admin" -ForegroundColor $Colors['Green']
    Write-Host "Admin Password:    admin" -ForegroundColor $Colors['Green']
    Write-Host ""
    Write-Host "Database Host:     localhost" -ForegroundColor $Colors['Green']
    Write-Host "Database Port:     3306" -ForegroundColor $Colors['Green']
    Write-Host "Database User:     vicidial" -ForegroundColor $Colors['Green']
    Write-Host "Database Pass:     vicidial" -ForegroundColor $Colors['Green']
    Write-Host "Database Name:     vicidial" -ForegroundColor $Colors['Green']
}

function Stop-Containers {
    Print-Header "Stopping VICIdial Services"
    
    if (-not (Test-Path "docker-compose.yml")) {
        Print-Error "docker-compose.yml not found in current directory"
        exit 1
    }
    
    Print-Info "Stopping containers..."
    docker-compose stop
    Print-Success "Containers stopped successfully!"
}

function Remove-Containers {
    Print-Header "Removing VICIdial Containers"
    
    if (-not (Test-Path "docker-compose.yml")) {
        Print-Error "docker-compose.yml not found in current directory"
        exit 1
    }
    
    Print-Info "Removing containers..."
    docker-compose down
    Print-Success "Containers removed successfully!"
}

function View-Logs {
    Print-Header "VICIdial Service Logs"
    
    if (-not (Test-Path "docker-compose.yml")) {
        Print-Error "docker-compose.yml not found in current directory"
        exit 1
    }
    
    Print-Info "Displaying logs... (Press Ctrl+C to exit)"
    docker-compose logs -f
}

function Clean-All {
    Print-Header "Cleaning Up"
    
    $response = Read-Host "This will remove all containers, images, and volumes. Continue? (yes/no)"
    
    if ($response -eq 'yes' -or $response -eq 'y') {
        Print-Info "Stopping containers..."
        docker-compose down -v 2> $null
        
        Print-Info "Removing image..."
        docker rmi vicidial:latest 2> $null
        
        Print-Success "Cleanup completed!"
    }
    else {
        Print-Info "Cleanup cancelled"
    }
}

function Show-Status {
    Print-Header "VICIdial Services Status"
    
    if (-not (Test-Path "docker-compose.yml")) {
        Print-Error "docker-compose.yml not found in current directory"
        exit 1
    }
    
    docker-compose ps
}

function Show-Help {
    Write-Host ""
    Write-Host "VICIdial Docker Build and Deploy Script (PowerShell)" -ForegroundColor $Colors['Blue']
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor $Colors['Green']
    Write-Host "    .\build.ps1 [command]"
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor $Colors['Green']
    Write-Host "    build       Build the Docker image"
    Write-Host "    rebuild     Build the Docker image (no cache)"
    Write-Host "    up          Start all services (docker-compose up -d)"
    Write-Host "    down        Stop all services (docker-compose stop)"
    Write-Host "    rm          Remove all containers"
    Write-Host "    logs        View service logs"
    Write-Host "    clean       Remove all containers, images, and volumes"
    Write-Host "    status      Show container status"
    Write-Host "    help        Show this help message"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor $Colors['Green']
    Write-Host "    .\build.ps1 build       # Build the image"
    Write-Host "    .\build.ps1 up          # Start services"
    Write-Host "    .\build.ps1 logs        # View logs"
    Write-Host "    .\build.ps1 down        # Stop services"
    Write-Host ""
    Write-Host "Important Notes:" -ForegroundColor $Colors['Yellow']
    Write-Host "    - Make sure Docker Desktop is installed and running"
    Write-Host "    - Run PowerShell as Administrator if you encounter permission issues"
    Write-Host "    - The script must be run from the VICIdial directory"
    Write-Host ""
    Write-Host "Default Credentials:" -ForegroundColor $Colors['Blue']
    Write-Host "    Web:       http://localhost"
    Write-Host "    User:      admin"
    Write-Host "    Password:  admin"
    Write-Host ""
    Write-Host "For more information, see README.md"
    Write-Host ""
}

# Main script logic
Check-Requirements

switch ($Command) {
    'build' {
        Build-Image
    }
    'rebuild' {
        Build-ImageNoCache
    }
    'up' {
        Start-Containers
    }
    'down' {
        Stop-Containers
    }
    'rm' {
        Remove-Containers
    }
    'logs' {
        View-Logs
    }
    'clean' {
        Clean-All
    }
    'status' {
        Show-Status
    }
    'help' {
        Show-Help
    }
    default {
        Print-Error "Unknown command: $Command"
        Show-Help
        exit 1
    }
}
