#!/bin/bash

#################################################################################
# VICIdial Docker Build and Deploy Script
# 
# This script helps build and deploy VICIdial using Docker
# Usage: ./build.sh [command]
# Commands: build, up, down, rebuild, logs, clean, help
#################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
IMAGE_NAME="vicidial:latest"
CONTAINER_NAME="vicidial-server"

# Functions
print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} $1"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

check_requirements() {
    print_header "Checking Requirements"
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker."
        exit 1
    fi
    print_success "Docker is installed"
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose."
        exit 1
    fi
    print_success "Docker Compose is installed"
    
    echo ""
}

build_image() {
    print_header "Building VICIdial Docker Image"
    
    if [ ! -f "Dockerfile" ]; then
        print_error "Dockerfile not found in $SCRIPT_DIR"
        exit 1
    fi
    
    print_info "Building image: $IMAGE_NAME"
    docker build -t $IMAGE_NAME .
    print_success "Image built successfully!"
    echo ""
}

build_no_cache() {
    print_header "Building VICIdial Docker Image (No Cache)"
    
    if [ ! -f "Dockerfile" ]; then
        print_error "Dockerfile not found in $SCRIPT_DIR"
        exit 1
    fi
    
    print_info "Building image without cache: $IMAGE_NAME"
    docker build --no-cache -t $IMAGE_NAME .
    print_success "Image built successfully!"
    echo ""
}

start_containers() {
    print_header "Starting VICIdial Services"
    
    if [ ! -f "docker-compose.yml" ]; then
        print_error "docker-compose.yml not found in $SCRIPT_DIR"
        exit 1
    fi
    
    print_info "Starting containers using docker-compose..."
    docker-compose up -d
    
    print_success "Containers started successfully!"
    
    echo ""
    print_info "Waiting for services to initialize (30 seconds)..."
    sleep 30
    
    print_header "Service Status"
    docker-compose ps
    
    echo ""
    print_header "Access Information"
    echo -e "Web Interface:     ${GREEN}http://localhost${NC}"
    echo -e "Admin Username:    ${GREEN}admin${NC}"
    echo -e "Admin Password:    ${GREEN}admin${NC}"
    echo -e ""
    echo -e "Database Host:     ${GREEN}localhost${NC}"
    echo -e "Database Port:     ${GREEN}3306${NC}"
    echo -e "Database User:     ${GREEN}vicidial${NC}"
    echo -e "Database Pass:     ${GREEN}vicidial${NC}"
    echo -e "Database Name:     ${GREEN}vicidial${NC}"
    echo ""
}

stop_containers() {
    print_header "Stopping VICIdial Services"
    
    if [ ! -f "docker-compose.yml" ]; then
        print_error "docker-compose.yml not found in $SCRIPT_DIR"
        exit 1
    fi
    
    print_info "Stopping containers..."
    docker-compose stop
    print_success "Containers stopped successfully!"
    echo ""
}

remove_containers() {
    print_header "Removing VICIdial Containers"
    
    if [ ! -f "docker-compose.yml" ]; then
        print_error "docker-compose.yml not found in $SCRIPT_DIR"
        exit 1
    fi
    
    print_info "Removing containers..."
    docker-compose down
    print_success "Containers removed successfully!"
    echo ""
}

view_logs() {
    print_header "VICIdial Service Logs"
    
    if [ ! -f "docker-compose.yml" ]; then
        print_error "docker-compose.yml not found in $SCRIPT_DIR"
        exit 1
    fi
    
    print_info "Displaying logs... (Press Ctrl+C to exit)"
    docker-compose logs -f
}

clean_all() {
    print_header "Cleaning Up"
    
    read -p "$(echo -e ${YELLOW})This will remove all containers, images, and volumes. Continue? (yes/no): $(echo -e ${NC})" -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Stopping containers..."
        docker-compose down -v 2>/dev/null || true
        
        print_info "Removing image..."
        docker rmi $IMAGE_NAME 2>/dev/null || true
        
        print_success "Cleanup completed!"
    else
        print_info "Cleanup cancelled"
    fi
    echo ""
}

show_help() {
    cat << EOF
${BLUE}VICIdial Docker Build and Deploy Script${NC}

${GREEN}Usage:${NC}
    ./build.sh [command]

${GREEN}Commands:${NC}
    build       Build the Docker image
    rebuild     Build the Docker image (no cache)
    up          Start all services (docker-compose up -d)
    down        Stop all services (docker-compose stop)
    rm          Remove all containers
    logs        View service logs
    clean       Remove all containers, images, and volumes
    status      Show container status
    help        Show this help message

${GREEN}Examples:${NC}
    ./build.sh build       # Build the image
    ./build.sh up          # Start services
    ./build.sh logs        # View logs
    ./build.sh down        # Stop services

${YELLOW}Important Notes:${NC}
    - Make sure Docker and Docker Compose are installed
    - Run with 'sudo' if your user doesn't have Docker permissions
    - Use 'sudo usermod -aG docker \$USER' to add permissions
    - The script must be run from the VICIdial directory

${BLUE}Default Credentials:${NC}
    Web:       http://localhost
    User:      admin
    Password:  admin

For more information, see README.md

EOF
}

show_status() {
    print_header "VICIdial Services Status"
    
    if [ ! -f "docker-compose.yml" ]; then
        print_error "docker-compose.yml not found in $SCRIPT_DIR"
        exit 1
    fi
    
    docker-compose ps
    echo ""
}

# Main script logic
main() {
    check_requirements
    
    case "${1:-help}" in
        build)
            build_image
            ;;
        rebuild)
            build_no_cache
            ;;
        up)
            start_containers
            ;;
        down)
            stop_containers
            ;;
        rm)
            remove_containers
            ;;
        logs)
            view_logs
            ;;
        clean)
            clean_all
            ;;
        status)
            show_status
            ;;
        help)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
