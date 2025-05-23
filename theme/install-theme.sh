# Check if root
if [ "$(id -u)" -eq 0 ]; then
    echo "Please do not run this script as root. Run it as a normal user."
    exit 1
fi

# install necessary packages
sudo dnf install -y gtk-murrine-engine
sudo dnf install -y sassc
sudo dnf install -y gnome-themes-extra

clear

# user menu to deside the installation options : Install Theme, Setup Wallpaper, Install Icons, Install Fonts

echo "====================================="
echo "      Fedora Auto Setup Menu         "
echo "====================================="
echo "1. Install Theme"
echo "2. Setup Wallpaper"
echo "3. Install Icons"
echo "4. Install Fonts"
echo "5. Install All"
echo "0. Exit"
echo "====================================="
echo -n "Please enter your choice [0-5]: "
read choice



# Function to install the Everforest GTK Theme
install_everforest_theme() {

    # if the directory does not exist, clone the repository : https://github.com/Fausto-Korpsvart/Everforest-GTK-Theme.git
    THEME_DIR="$(dirname "$(readlink -f "$0")")/Everforest-GTK-Theme"
    if [ ! -d "$THEME_DIR" ]; then
        echo "Cloning Everforest GTK Theme repository..."
        git clone https://github.com/Fausto-Korpsvart/Everforest-GTK-Theme.git "$THEME_DIR"
        echo "Repository cloned successfully."
    else
        echo "Everforest GTK Theme directory already exists. Checking for updates..."
        cd "$THEME_DIR"
        git pull
        echo "Repository updated."
    fi

    # Navigate to the themes directory and run install.sh
    echo "Making the install script executable and running it..."
    cd "$THEME_DIR/themes"
    chmod +x install.sh
    ./install.sh -l --tweaks macos
    echo "Theme installation completed."
}

# Function to set up the wallpaper
set_wallpaper() {
    ls
    cd ../..
    ls
    # Change Background
    echo "Changing background to Everforest..."

    # Set up paths
    SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
    WALLPAPER_SOURCE_PATH="${SCRIPT_DIR}/wallpaper/everforest.jpg"
    WALLPAPER_TARGET_DIR="${HOME}/.wallpaper"
    WALLPAPER_TARGET_PATH="${WALLPAPER_TARGET_DIR}/everforest.jpg"

    # Überprüfen, ob die Quelldatei existiert
    if [ ! -f "$WALLPAPER_SOURCE_PATH" ]; then
        echo "Fehler: Wallpaper nicht gefunden unter: $WALLPAPER_SOURCE_PATH"
        exit 1
    else
        echo "DEBUG: Wallpaper gefunden unter: $WALLPAPER_SOURCE_PATH"
    fi

    # Erstelle das Zielverzeichnis, falls es nicht existiert
    if [ ! -d "$WALLPAPER_TARGET_DIR" ]; then
        echo "DEBUG: Zielverzeichnis existiert nicht. Erstelle: $WALLPAPER_TARGET_DIR"
        mkdir -p "$WALLPAPER_TARGET_DIR"
        if [ $? -ne 0 ]; then
            echo "Fehler: Zielverzeichnis konnte nicht erstellt werden: $WALLPAPER_TARGET_DIR"
            exit 1
        else
            echo "DEBUG: Zielverzeichnis erfolgreich erstellt: $WALLPAPER_TARGET_DIR"
        fi
    else
        echo "DEBUG: Zielverzeichnis existiert bereits: $WALLPAPER_TARGET_DIR"
    fi

    # Kopiere das Wallpaper in das Zielverzeichnis
    echo "DEBUG: Kopiere Wallpaper von $WALLPAPER_SOURCE_PATH nach $WALLPAPER_TARGET_PATH"
    cp "$WALLPAPER_SOURCE_PATH" "$WALLPAPER_TARGET_PATH"
    if [ $? -ne 0 ]; then
        echo "Fehler: Wallpaper konnte nicht kopiert werden."
        exit 1
    else
        echo "DEBUG: Wallpaper erfolgreich kopiert nach: $WALLPAPER_TARGET_PATH"
    fi

    # Setze das Wallpaper
    gsettings set org.gnome.desktop.background picture-uri "file://${WALLPAPER_TARGET_PATH}"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://${WALLPAPER_TARGET_PATH}"
    gsettings set org.gnome.desktop.background picture-options 'zoom'
    gsettings set org.gnome.desktop.background color-shading-type 'solid'

    if [ $? -eq 0 ]; then
        echo "DEBUG: Wallpaper erfolgreich gesetzt."
    else
        echo "Fehler: Wallpaper konnte nicht gesetzt werden."
        exit 1
    fi

    echo "Background changed successfully."
}

# Function to install icons
# TODO

# Function to install fonts
# TODO


# Check the user's choice
case $choice in
    1)
        echo "Installing Theme..."
        install_everforest_theme
        ;;
    2)
        echo "Setting up Wallpaper..."
        set_wallpaper
        ;;
    3)
        echo "Installing Icons..."
        echo "Icons installation is not implemented yet."
        ;;
    4)
        echo "Installing Fonts..."
        echo "Fonts installation is not implemented yet."
        ;;
    5)
        echo "Installing All..."
        install_everforest_theme
        set_wallpaper
        ;;
    0)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice. Exiting..."
        exit 1
        ;;
esac