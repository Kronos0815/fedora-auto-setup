# check if the script is run as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Please do not run this script as root. Run it as a normal user."
    exit 1
fi

# Install Extensions
# install necessary packages : curl wget jq
sudo dnf install -y curl wget jq

# run extension installer
##################################################################################
# My Setup:                                                                      #
# ./install-gnome-extensions.sh --enable 3628 3193 779 97 4158 3843 6580 19 1460 #
# ./install-gnome-extensions.sh --activate                                       #
##################################################################################   

# make sure the script is executable
chmod +x ./gnome-extensions/install-gnome-extensions.sh
chmod +x ./gnome-extensions/deploy-configs.sh

# run extension installer
./gnome-extensions/install-gnome-extensions.sh --enable 3628 3193 779 97 4158 3843 6580 19 1460

# activate extensions
#./gnome-extensions/install-gnome-extensions.sh --activate

# install extension configs
#./gnome-extensions/deploy-configs.sh ./configs