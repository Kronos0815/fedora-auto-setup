# Check if root
if [ "$(id -u)" -eq 0 ]; then
    echo "Please do not run this script as root. Run it as a normal user."
    exit 1
fi

# install necessary packages

sudo dnf install -y gtk-murrine-engine
sudo dnf install -y sassc
sudo dnf install -y gnome-themes-extra

# curl the theme
