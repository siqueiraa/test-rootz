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

install_root="/opt/tableau/tableau_server"     

echo_info "Locating Tableau Server installation..."
script_path=$(find /opt/tableau/tableau_server/packages -name stop-administrative-services 2>/dev/null)
if [ -z "$script_path" ]; then
    echo_error "Tableau Server installation directory not found."
else
    echo_success "Stop script path: $script_path"
    echo_info "Stopping Tableau Server..."
    sudo $script_path

    echo_info "Checking if the Tableau Server has stopped..."
    pid=$(pgrep -f "tabadmincontroller")
    if [ -n "$pid" ]; then
        echo_error "Tableau Server TabAdminController is still running with PID: $pid"
        echo_info "Attempting to stop again..."
        sudo $script_path
    else
        echo_success "Tableau Server TabAdminController is not running."
    fi
fi

obliterate_script=$(find /opt/tableau/tableau_server/packages -name tableau-server-obliterate 2>/dev/null)
if [ ! -z "$obliterate_script" ]; then
    echo_info "Running the obliterate script to remove all Tableau Server components..."
    sudo $obliterate_script -y -y -y
    echo_success "Tableau Server has been obliterated."
else
    echo_error "Obliterate script not found. Manual cleanup may be required."
fi

echo_info "Uninstalling Tableau Server..."
package_name=$(dpkg -l | grep tableau-server | awk '{print $2}')
if [ ! -z "$package_name" ]; then
    echo_info "Detected Tableau Server package name: $package_name"
    sudo dpkg -r $package_name
    echo_success "Tableau Server package uninstalled."

    echo_info "Cleaning up residual files..."
    sudo rm -rf $install_root
    sudo rm -rf /var/opt/tableau/
    echo_success "Residual files cleaned up."
else
    echo_error "No Tableau Server package found to uninstall."
fi

echo_info "Removing leftover configuration files..."
for dir in /opt/tableau /var/opt/tableau /etc/tableau; do
    if [ -d "$dir" ]; then
        sudo rm -rf $dir
        echo_success "Removed directory: $dir"
    fi
done

echo_info "Checking for and removing the Tableau user and group..."
if getent passwd tableau > /dev/null; then
    tableau_pid=$(pgrep -u tableau)
    if [ ! -z "$tableau_pid" ]; then
        echo_info "Killing processes for user 'tableau': $tableau_pid"
        sudo kill -9 $tableau_pid
    fi
    sudo userdel -r tableau
    echo_success "Tableau user removed."
else
    echo_error "Tableau user does not exist."
fi

if getent group tableau > /dev/null; then
    sudo groupdel tableau
    echo_success "Tableau group removed."
else
    echo_error "Tableau group does not exist."
fi

echo_info "Cleaning up startup scripts..."
if [ -f "/etc/profile.d/tableau_server.sh" ]; then
    sudo rm /etc/profile.d/tableau_server.sh
    echo_success "Removed Tableau startup script."
else
    echo_error "No Tableau startup script found."
fi

echo_success "Cleanup complete. Please manually verify that all processes associated with Tableau are terminated."

