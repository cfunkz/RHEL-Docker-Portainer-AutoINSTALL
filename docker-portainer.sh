#!/bin/bash

# Exit on errors and print each command for debugging
set -euo pipefail

# Set DRY_RUN for testing
DRY_RUN=false

# Cleanup if error
cleanup() {
    echo "Error. Rollback..."

    # Simulate rollback if DRY_RUN is true
    if [ "$DRY_RUN" = false ]; then
        # Stop and remove the Portainer if exists
        if docker ps -a | grep -q "portainer"; then
            echo "Removing Portainer container..."
            docker rm -f portainer || echo "Failed to remove Portainer."
        fi

        # Remove the Portainer volume if exists
        if docker volume ls | grep -q "portainer_data"; then
            echo "Removing Portainer volume..."
            docker volume rm portainer_data || echo "Failed to remove Portainer volume."
        fi

        # Stop Docker
        if systemctl is-active --quiet docker; then
            echo "Stopping Docker service..."
            sudo systemctl stop docker || echo "Failed to stop Docker service."
        fi
        # Disable Docker
        if systemctl is-enabled --quiet docker; then
            echo "Disabling Docker service..."
            sudo systemctl disable docker || echo "Failed to disable Docker service."
        fi

        # Uninstall Docker if installed
        if command -v docker &>/dev/null; then
            echo "Uninstalling Docker..."
            sudo dnf remove -y docker-ce docker-ce-cli containerd.io || echo "Uninstalling Docker failed."
        fi
    else
        echo "[DRY RUN] Cleanup actions simulated."
    fi

    echo "Rollback complete."
}

# Run commands based on DRY_RUN
run_command() {
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] $*"
    else
        eval "$@"
    fi
}

# Trap errors and call the rollback
trap cleanup ERR

# Check if Docker is installed
if command -v docker &>/dev/null; then
    echo "Docker is already installed."
else
    # Install prerequisites if Docker is not installed
    echo "Installing Docker..."
    run_command "sudo dnf install -y dnf-utils device-mapper-persistent-data lvm2"
    run_command "sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo"
    run_command "sudo dnf install -y docker-ce docker-ce-cli containerd.io"
    run_command "sudo systemctl start docker"
    run_command "sudo systemctl enable docker"
fi

# Check if Portainer is already running
if docker ps -a | grep -q "portainer"; then
    echo "Portainer is already installed and running."
else
    # Install Portainer if it's not already installed
    echo "Installing Portainer..."
    run_command "sudo docker volume create portainer_data"
    run_command "sudo docker run -d \
        -p 9000:9000 \
        --name portainer \
        --restart always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce"
fi

# Get the servers IP
SERVER_IP=$(hostname -I | awk '{print $1}')
if [ -z "$SERVER_IP" ]; then
    SERVER_IP=$(curl -s http://checkip.amazonaws.com || echo "unknown")
fi

# Display success message
echo "Docker and Portainer installation completed successfully!"
echo "Portainer is accessible at http://$SERVER_IP:9000"
