#!/usr/bin/env bash
# check if the script is run as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Please do not run this script as root. Run it as a normal user."
    exit 1
fi

# Function to display the menu
show_menu() {
    clear
    echo "====================================="
    echo "      Fedora Auto Setup Menu         "
    echo "====================================="
    echo "1. Update System"
    echo "2. Install GNOME Extensions"
    echo "3. Activate GNOME Extensions"
    echo "4. Load Extension Configurations"
    echo "5. (Not implemented yet)"
    echo "0. Exit"
    echo "====================================="
    echo -n "Please enter your choice [0-5]: "
}

# Function to update the system
update_system() {
    echo "Updating system..."
    sudo dnf update -y
    sudo dnf upgrade -y
    sudo dnf autoremove -y
    echo "System updated successfully!"
    read -p "Press Enter to continue..."
}

# Function to install extensions
install_extensions() {
    echo "Installing GNOME extensions..."
    # Install necessary packages: curl wget jq
    sudo dnf install -y curl wget jq

    # Make sure the script is executable
    chmod +x ./gnome-extensions/install-gnome-extensions.sh
    chmod +x ./gnome-extensions/deploy-configs.sh

    # Run extension installer
    ./gnome-extensions/install-gnome-extensions.sh --enable 3628 3193 779 97 4158 3843 6580 19 1460
    echo "Extensions installed successfully!"
    read -p "Press Enter to continue..."
}

# Function to activate extensions
activate_extensions() {
    echo "Activating GNOME extensions..."
    ./gnome-extensions/install-gnome-extensions.sh --activate
    echo "Extensions activated successfully!"
    read -p "Press Enter to continue..."
}

# Function to load extension configurations
load_configs() {
    echo "Loading extension configurations..."
    ./gnome-extensions/deploy-configs.sh ./gnome-extensions
    echo "Extension configurations loaded successfully!"
    read -p "Press Enter to continue..."
}

# Main menu loop
while true; do
    show_menu
    read choice

    case $choice in
        1)
            update_system
            ;;
        2)
            install_extensions
            ;;
        3)
            activate_extensions
            ;;
        4)
            load_configs
            ;;
        
        5)
            echo "This option is not implemented yet."
            read -p "Press Enter to continue..."
            ;;
        0)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Press Enter to continue..."
            read
            ;;
    esac
done