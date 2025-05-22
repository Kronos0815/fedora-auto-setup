# Check if root
if [ "$(id -u)" -eq 0 ]; then
    echo "Please do not run this script as root. Run it as a normal user."
    exit 1
fi

# install necessary packages
sudo dnf install -y gtk-murrine-engine
sudo dnf install -y sassc
sudo dnf install -y gnome-themes-extra

# if the direcotory does not exist, clone the repository
if [ ! -d "theme/Everforest-GTK-Theme" ]; then
    git clone https://github.com/Fausto-Korpsvart/Everforest-GTK-Theme.git


# update git repository in theme/Everforest-GTK-Theme
cd theme/Everforest-GTK-Theme
git pull
cd ../..

# install theme
chmod +x /theme/Everforest-GTK-Theme/themes/install.sh
./theme/Everforest-GTK-Theme/themes/install.sh