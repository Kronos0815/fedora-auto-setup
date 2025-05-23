# Check if root
if [ "$(id -u)" -eq 0 ]; then
    echo "Please do not run this script as root. Run it as a normal user."
    exit 1
fi

# install necessary packages
sudo dnf install -y gtk-murrine-engine
sudo dnf install -y sassc
sudo dnf install -y gnome-themes-extra

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

# Change Background
echo "Changing background to Everforest..."

ls
cd ../..
ls

# Set up paths
SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
WALLPAPER_SOURCE_PATH="${SCRIPT_DIR}/wallpaper/everforest.jpg"
WALLPAPER_TARGET_DIR="${HOME}/.wallpaper"
WALLPAPER_TARGET_PATH="${WALLPAPER_TARGET_DIR}/everforest.jpg"

# Debug-Ausgaben
echo "DEBUG: SCRIPT_DIR: $SCRIPT_DIR"
echo "DEBUG: WALLPAPER_SOURCE_PATH: $WALLPAPER_SOURCE_PATH"
echo "DEBUG: WALLPAPER_TARGET_DIR: $WALLPAPER_TARGET_DIR"
echo "DEBUG: WALLPAPER_TARGET_PATH: $WALLPAPER_TARGET_PATH"


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
echo "DEBUG: Setze Wallpaper mit gsettings: $WALLPAPER_TARGET_PATH"
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