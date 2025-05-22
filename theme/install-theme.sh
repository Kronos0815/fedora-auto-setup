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
WALLPAPER_PATH="$(dirname "$(readlink -f "$0")")/wallpaper/everforest.png"
cd "$(dirname "$(readlink -f "$0")")"
gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER_PATH"
echo "Background changed successfully."