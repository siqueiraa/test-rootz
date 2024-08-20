#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions for printing colored text
echo_info() {
    echo -e "${YELLOW}$1${NC}"
}

echo_success() {
    echo -e "${GREEN}$1${NC}"
}

echo_error() {
    echo -e "${RED}$1${NC}"
}

export TABLEAU_VERSION="2024.2.1"

echo_info "Updating packages and system..."
sudo apt-get update && sudo apt-get -y upgrade && sudo apt -y autoremove

echo_info "Installing gdebi-core to install .deb packages..."
sudo apt-get -y install gdebi-core

# Check if the tableau-server.deb file exists
if [ ! -f "tableau-server.deb" ]; then
    echo_error "tableau-server.deb file not found. Starting download..."
    wget https://downloads.tableau.com/esdalt/${TABLEAU_VERSION}/tableau-server-${TABLEAU_VERSION//./-}_amd64.deb -O tableau-server.deb
else
    echo_success "tableau-server.deb file found."
fi

echo_info "Installing Tableau Server..."
sudo gdebi -n tableau-server.deb

# Locate the Tableau Server initialization script
script_path=$(find /opt/tableau/tableau_server/packages -name initialize-tsm 2>/dev/null)
if [ -z "$script_path" ]; then
    echo_error "Initialization script not found."
else
    echo_success "Script path: $script_path"
    echo_info "Executing the initialization script..."
    sudo $script_path --accepteula #-f -a $USERNAME
fi

# Check if the Tableau Server is running (checking the process)
pid=$(pgrep -f "tabadmincontroller")
if [ -n "$pid" ]; then
    echo_success "Tableau Server TabAdminController is running with PID: $pid"
else
    echo_error "Tableau Server TabAdminController is not running."
fi

# Check if the server is responding on the specified port (8850)
if curl -s http://localhost:8850 > /dev/null
then
    echo_success "Tableau Server is responding at http://localhost:8850."
else
    echo_error "Tableau Server is not responding at http://localhost:8850."
fi

