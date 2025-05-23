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
    echo "2. Install GNOME Tweaks"
    echo "3. Install GNOME Shell Extension Manager"
    echo "4. Install GNOME Extensions"
    echo "5. Load Extension Configurations"
    echo "6. Activate GNOME Extensions"
    echo "7. Reboot System"
    echo "8. Install Theme"
    echo "9. Install ZSH with Oh My Zsh"
    echo "0. Exit"
    echo "====================================="
    echo -n "Please enter your choice [0-8]: "
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

# Function to install GNOME Tweaks
install_tweaks() {
    echo "Installing GNOME Tweaks..."
    sudo dnf install -y gnome-tweaks
    echo "GNOME Tweaks installed successfully!"
    read -p "Press Enter to continue..."
}

# Function to install GNOME Shell Extension Manager
install_extension_manager() {

    chmod +x ./scripts/install_extension_manager.sh
    echo "Installing GNOME Shell Extension Manager..."
    ./scripts/install_extension_manager.sh
    echo "GNOME Shell Extension Manager installed successfully!"
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

# Function to load extension configurations
load_configs() {
    # Make sure the script is executable
    chmod +x ./gnome-extensions/deploy-configs.sh
    echo "Loading extension configurations..."
    ./gnome-extensions/deploy-configs.sh ./gnome-extensions
    echo "Extension configurations loaded successfully!"
    read -p "Press Enter to continue..."
}

# Function to activate extensions
activate_extensions() {
    # Make sure the script is executable
    chmod +x ./gnome-extensions/install-gnome-extensions.sh
    echo "Activating GNOME extensions..."
    ./gnome-extensions/install-gnome-extensions.sh --activate
    echo "Extensions activated successfully!"
    read -p "Press Enter to continue..."
}

# Funtion to install the Theme
install_theme() {
    echo "Installing the theme..."
    # Make sure the script is executable
    chmod +x ./theme/install-theme.sh
    # Run the theme installer
    ./theme/install-theme.sh
    echo "Theme installed successfully!"
    read -p "Press Enter to continue..."
}


# Function to reboot the system
reboot_system() {
    echo "Rebooting system..."
    read -p "Are you sure you want to reboot? (y/n): " confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        sudo reboot
    else
        echo "Reboot cancelled."
        read -p "Press Enter to continue..."
    fi
}

# Function to install ZSH with Oh My Zsh
install_zsh() {
    chmod +x ./scripts/setup-terminal.sh
    ./scripts/setup-terminal.sh
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
            install_tweaks
            ;;
        3)
            install_extension_manager
            ;;
        4)
            install_extensions
            ;;
        5)
            load_configs
            ;;
        6)
            activate_extensions
            ;;
        7)
            reboot_system
            ;;
        8)
            install_theme
            ;;
        9)
            install_zsh
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