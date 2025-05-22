#!/usr/bin/env bash
# check if the script is run as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Please do not run this script as root. Run it as a normal user."
    exit 1
fi

# Function to display the menu

# Bessere Reihenfolge:
# 1. Update System
# 2. Gnome Tweaks und Extension Manager installieren
# 3. Gnome Extensions installieren
# 4. Gnome Extensions Configurationen laden
# 5. Gnome Extensions aktivieren
# 6. reboot
# 0. Exit

show_menu() {
    clear
    echo "====================================="
    echo "      Fedora Auto Setup Menu         "
    echo "====================================="
    echo "1. Update System"
    echo "2. Install GNOME Extensions"
    echo "3. Activate GNOME Extensions"
    echo "4. Load Extension Configurations"
    echo "5. Install GNOME Tweaks and Extension Manager"
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

    # Make sure the script is executable
    chmod +x ./gnome-extensions/install-gnome-extensions.sh
    chmod +x ./gnome-extensions/deploy-configs.sh

    echo "Activating GNOME extensions..."
    ./gnome-extensions/install-gnome-extensions.sh --activate
    echo "Extensions activated successfully!"
    read -p "Press Enter to continue..."
}

# Function to load extension configurations
load_configs() {

    # Make sure the script is executable
    chmod +x ./gnome-extensions/deploy-configs.sh
    echo "Loading extension configurations..."
    ./gnome-extensions/deploy-configs.sh ./gnome-extensions
    echo "Extension configurations loaded successfully!"
    read -p "Press Enter to continue..."
}

# Function to install GNOME Tweaks and Extension Manager (not implemented)
install_tweaks() {
    echo "Installing GNOME Tweaks and Extension Manager..."
    sudo dnf install -y gnome-tweaks
    echo "GNOME Tweaks installed successfully!"
    read -p "Press Enter to continue..."
}

# funtioniert nicht
install_extension_manager() {

    chmod +x ./scripts/install_extension_manager.sh
    echo "Installing GNOME Shell Extension Manager..."
    ./scripts/install_extension_manager.sh
    echo "GNOME Shell Extension Manager installed successfully!"
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
            install_tweaks
            install_extension_manager
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