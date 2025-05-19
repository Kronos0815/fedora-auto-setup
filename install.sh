# check if the script is run as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Please do not run this script as root. Run it as a normal user."
    exit 1
fi

# Install Extensions
# install necessary packages : curl wget jq
sudo dnf install -y curl wget jq

# run extension installer
# This script will install the extensions listed in extensions-list.txt
./scripts/install-gnome-extensions.sh --enable --file extensions-list.txt

