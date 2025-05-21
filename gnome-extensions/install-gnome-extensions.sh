#!/bin/bash

#################################################################
#                                                               #
#             GNOME Shell Extension Installer v1.2.1            #
#                                                               #
#  A simple (scriptable) way to install GNOME Shell Extensions! #
#                                                               #
#       Author: Cyrus Frost                                     #
#       License: MIT                                            #
#                                                               #
#     https://github.com/ToasterUwU/install-gnome-extensions    #
#                                                               #
#################################################################

##################################################################################
# My Setup:                                                                      #
# ./install-gnome-extensions.sh --enable 3628 3193 779 97 4158 3843 6580 19 1460 #
# ./install-gnome-extensions.sh --activate                                       #
##################################################################################          

#vars
script_revision="v1.3.0"
args_count="$#"
dependencies=(wget curl jq tput sed egrep sed awk gnome-shell cut basename)
deps_install_apt="sudo apt install -y wget curl jq sed"
deps_install_dnf="sudo dnf install -y wget curl jq sed"
EXTENSIONS_TO_INSTALL=()
OVERWRITE_EXISTING=false
ENABLE_ALL=false
INSTALLED_EXT_COUNT=''
INSTALLED_EXTs=''
ACTIVATION_MODE=""

# message colors.
info_text_blue=$(tput setaf 7)
normal_text=$(tput sgr0)
error_text=$(tput setaf 1)
status_text_yellow=$(tput setaf 3)

# Trap SIGINT and SIGTERM.
function _term() {
    printf "\n\n${normal_text}"
    trap - INT TERM # clear the trap
    kill -- -$$
}

# Trap SIGINT and SIGTERM for cleanup.
trap _term INT TERM

# This function can check for binaries/commands to be available in Env PATH and report otherwise.
function CheckDependencies() {

    # echo -en "\n${info_text_blue}Checking dependencies...${normal_text}";
    dependencies=("$@")
    for name in "${dependencies[@]}"; do
        command -v "$name" >/dev/null 2>&1 || {
            echo -en "${error_text}\n[Error] Command not found: \"$name\"${normal_text}"
            deps=1
        }
    done
    [[ $deps -ne 1 ]] || {
        echo -en "${error_text}\n\nOne or more dependencies is unavailable. Please make sure the above commands are available and re-run this script.\n\n${status_text_yellow}For Ubuntu and other Debian based Distros, try: $deps_install_apt\n\nFor Fedora and Fedora based Distros, try: $deps_install_dnf\n\n${normal_text}"
        exit 1
    }
}

# Fail if dependencies unmet.
CheckDependencies "${dependencies[@]}"

function confirm_action() {
    while true; do
        printf "\n${normal_text}"
        read -p "$1" -n 1 yn
        case $yn in
        [Yy]*) return 0 ;;
        [Nn]*) return 1 ;;
        *) printf "\nPlease answer with 'y' or 'n'." ;;
        esac
    done
}

# check if current (active) desktop instance is GNOME.
function IsEnvGNOME() {

    if [ "$XDG_CURRENT_DESKTOP" = "" ]; then
        desktop=$(echo "$XDG_DATA_DIRS" | sed 's/.*\(xfce\|kde\|gnome\).*/\1/')
    else
        desktop=$XDG_CURRENT_DESKTOP
    fi

    desktop=${desktop,,}

    if [[ $desktop == *"gnome"* ]]; then
        return 0
    else
        return 1
    fi
}

function install_extension() {
    archive_file_name="$1"
    gnome-extensions install "$archive_file_name" -f >/dev/null 2>&1
}

function enable_extension() {
    ext_uuid="$1"
    gnome-extensions enable "$ext_uuid" >/dev/null 2>&1
}

function disable_extension() {
    ext_uuid="$1"
    gnome-extensions disable "$ext_uuid" >/dev/null 2>&1
}

function get_installed_extensions_list() {
    user_extensions_path="/home/$USER/.local/share/gnome-shell/extensions"
    array=($(ls -l $user_extensions_path --time-style=long-iso | egrep '^d' | awk '{print $8}'))
    ext_list=$(printf "'%s'," "${array[@]}")
    ext_list=${ext_list%,}
    INSTALLED_EXT_COUNT="${#array[@]}"
    INSTALLED_EXTs=$(printf '%s\n' "${array[@]}")
}

function install_shell_extensions() {
    installed_ext_uuids=()

    for ext_id in "${EXTENSIONS_TO_INSTALL[@]}"; do

        request_url="https://extensions.gnome.org/extension-info/?pk=$ext_id&shell_version=$GNOME_SHELL_VERSION"
        http_response="$(curl -s -o /dev/null -I -w "%{http_code}" "$request_url")"

        if [ "$http_response" = 404 ]; then
            printf "\n${error_text}Error: No extension exists matching the ID: $ext_id and GNOME Shell version $GNOME_SHELL_VERSION (Skipping this).\n"
            continue
        fi

        printf "${normal_text}\n"
        ext_info="$(curl -s "$request_url")"
        extension_name="$(echo "$ext_info" | jq -r '.name')"
        direct_dload_url="$(echo "$ext_info" | jq -r '.download_url')"
        ext_uuid="$(echo "$ext_info" | jq -r '.uuid')"
        ext_version="$(echo "$ext_info" | jq -r '.version')"
        ext_homepage="$(echo "$ext_info" | jq -r '.link')"
        ext_description="$(echo "$ext_info" | jq -r '.description')"
        download_url="https://extensions.gnome.org"$direct_dload_url
        printf "${status_text_yellow}\nDownloading and installing extension \"$extension_name\"${normal_text}"
        printf "${info_text_blue}"
        printf "\nDescription: $ext_description"
        printf "\nExtension ID: $ext_id"
        printf "\nExtension Version: v$ext_version"
        printf "\nHomepage: https://extensions.gnome.org$ext_homepage"
        printf "\nUUID: \"$ext_uuid\""

        target_installation_dir="/home/$USER/.local/share/gnome-shell/extensions/$ext_uuid"

        if [ -d "$target_installation_dir" ] && [ "$OVERWRITE_EXISTING" = "false" ]; then
            confirm_action "${normal_text}This extension is already installed. Do you want to overwrite it? (y/n): " || continue
        fi

        printf "\n${info_text_blue}Please wait...\n"
        filename="$(basename "$download_url")"
        wget -q "$download_url"
        install_extension "$filename"
        rm "$filename"
        
        # Speichere die UUID für spätere Aktivierung
        installed_ext_uuids+=("$ext_uuid")

        printf "${info_text_blue}Done!\n${normal_text}"
    done
    
    # Speichere die installierten UUIDs in eine Datei für spätere Nutzung
    if [ ${#installed_ext_uuids[@]} -gt 0 ]; then
        printf "%s\n" "${installed_ext_uuids[@]}" > "/tmp/installed_extensions.txt"
    fi
    
    printf "\n"
}

# Funktion zum Aktivieren aller installierten Extensions
function enable_all_extensions() {
    printf "\n${info_text_blue}Activating all installed extensions...${normal_text}\n"
    
    # Entweder aus der temporären Datei laden oder alle vorhandenen Extensions verwenden
    if [ -f "/tmp/installed_extensions.txt" ]; then
        ext_list=()
        while IFS= read -r line; do
            ext_list+=("$line")
        done < "/tmp/installed_extensions.txt"
    else
        get_installed_extensions_list
        ext_list=($INSTALLED_EXTs)
    fi
    
    if [ ${#ext_list[@]} -eq 0 ]; then
        printf "${error_text}No extensions found to activate.${normal_text}\n"
        return
    fi
    
    printf "${status_text_yellow}Found ${#ext_list[@]} extensions to activate.${normal_text}\n"
    
    for ext_uuid in "${ext_list[@]}"; do
        printf "${info_text_blue}Activating: $ext_uuid${normal_text}\n"
        enable_extension "$ext_uuid"
    done
    
    printf "${status_text_yellow}All extensions have been activated.${normal_text}\n"
}

# Check if arg is number.
function IsNumber() {
    re='^[0-9]+$'
    if [[ "$1" =~ $re ]]; then
        return 0
    fi
    return 1
}

function print_usage() {
    print_banner

    printf "
Usage: ./install-gnome-extensions.sh [options] <extension_ids> | [links_file]

Options:
    -e, --enable        Enable extension after installing it.
    -l. --list          Lists the UUIDs of installed extensions.
    -f, --file          Specify a file containing extension links to install.
    -h, --help          Display this help message.
    -a, --activate      Only activate already installed extensions (no installation).

Example usages:
---------------

1) ./install-gnome-extensions.sh 6 8 19 --enable

    Installs and enables extensions with IDs 6, 8, and 19.

2) ./install-gnome-extensions.sh -e --file links.txt

    Installs and enables the extensions from the URLs specified in \"links.txt\" file.
    
3) ./install-gnome-extensions.sh --activate

    Activates all installed extensions without installing any new ones.

"
}

function print_banner() {
    printf "${normal_text}
===========================================================

    GNOME Shell Extensions Installer $script_revision

A simple (scriptable) way to install GNOME Shell extensions.

https://github.com/ToasterUwU/install-gnome-extensions

===========================================================\n"
}

function trim_file() {
    file="$1"
    sed -i '/^[[:blank:]]*$/ d' $file && awk '{$1=$1};1' $file >tmp && mv tmp $file
}

function install_exts_from_links_file() {

    file="$1"
    if [ ! -f "$file" ] || [ ! -s "$file" ]; then
        printf "\n${error_text}Error: Supplied argument (\"$1\") is either not a valid file or is empty.${normal_text}\n\nPlease gather all extension links in a text file (line-by-line) and try again.\n\nSample usage: ./install-gnome-extensions --file links.txt\n\n"
        exit 1
    fi

    trim_file $file

    printf "\nParsing file \"$file\" for extension links...\n"

    while IFS="" read -r p || [ -n "$p" ]; do
        url="$(echo "$p" | sed '/^[[:space:]]*$/d')"
        ext_id="$(echo "$url" | tr '\n' ' ' | sed -e 's/[^0-9]/ /g' -e 's/^ *//g' -e 's/ *$//g' | tr -s ' ' | awk '{print $1;}')"
        IsNumber "$ext_id" && EXTENSIONS_TO_INSTALL+=($ext_id) || printf "\n${error_text}Error: Invalid URL: $url (Skipping this).${normal_text}"
    done <$file
    printf "\n"
}

function begin_install() {
    exts_list="$(printf '%s, ' "${EXTENSIONS_TO_INSTALL[@]}")"
    exts_list=${exts_list%, }

    print_banner
    printf "\n${info_text_blue}[Info] Detected GNOME Shell version: $GNOME_SHELL_VERSION\n\nInstalling $extensions_count extensions ($exts_list)...\n${normal_text}"
    install_shell_extensions
    
    printf "\n${status_text_yellow}Extensions were installed but not activated.${normal_text}\n"
    printf "${info_text_blue}Please log out and log back in, then run this script with --activate to enable them.${normal_text}\n"
    printf "${info_text_blue}Command: ./install-gnome-extensions.sh --activate${normal_text}\n\n"
    
    if confirm_action "Would you like to log out now to complete the installation? (y/n): "; then
        printf "\n${info_text_blue}Logging out in 5 seconds...${normal_text}\n"
        sleep 5
        gnome-session-quit --logout --no-prompt
    else
        printf "\n${status_text_yellow}Remember to log out and back in before activating extensions.${normal_text}\n\n"
    fi
}

# Obtain GNOME Shell version.
GNOME_SHELL_VERSION="$(gnome-shell --version | cut --delimiter=' ' --fields=3 | cut --delimiter='.' --fields=1,2)"

# Initial mode selection
if [ "$args_count" -gt 0 ]; then
    # Prüfe zuerst auf Aktivierungsmodus
    for arg in "$@"; do
        if [ "$arg" = "-a" ] || [ "$arg" = "--activate" ]; then
            ACTIVATION_MODE="activate"
            break
        fi
    done
else
    # Wenn keine Argumente übergeben wurden, frage den Benutzer
    print_banner
    printf "\n${info_text_blue}What would you like to do?${normal_text}\n\n"
    printf "1) Install new extensions\n"
    printf "2) Activate already installed extensions\n\n"
    
    while true; do
        read -p "Enter your choice (1/2): " choice
        case $choice in
            1) ACTIVATION_MODE="install"; break ;;
            2) ACTIVATION_MODE="activate"; break ;;
            *) printf "${error_text}Invalid choice. Please enter 1 or 2.${normal_text}\n" ;;
        esac
    done
fi

# Wenn wir im Aktivierungsmodus sind, aktiviere alle Extensions und beende
if [ "$ACTIVATION_MODE" = "activate" ]; then
    print_banner
    printf "\n${info_text_blue}Activating extensions...${normal_text}\n"
    enable_all_extensions
    printf "\n${normal_text}Complete!\n\n"
    exit 0
fi

# Ansonsten normale Befehlszeilenparameter verarbeiten
while test $# -gt 0; do
    case "$1" in
    -e | --enable)
        ENABLE_ALL=true
        ;;
    -u | --update)
        UPDATE=true
        ;;
    -o | --overwrite)
        OVERWRITE_EXISTING=true
        ;;
    -h | --help)
        print_usage
        exit 0
        ;;
    -l | --list)
        get_installed_extensions_list
        printf "\n============================\nInstalled extensions (UUIDs)\n============================\n\n$INSTALLED_EXTs\n\n$INSTALLED_EXT_COUNT extensions are installed.\n\nDone!\n\n"
        exit 0
        ;;
    -f | --file)
        install_exts_from_links_file "$2"
        ;;
    -a | --activate)
        # Wurde bereits behandelt
        ;;
    esac
    IsNumber "$1" && EXTENSIONS_TO_INSTALL+=($1)
    shift
done

extensions_count="${#EXTENSIONS_TO_INSTALL[@]}"

if [ "$ACTIVATION_MODE" = "install" ] && [ "$extensions_count" -eq 0 ]; then
    printf "\n${error_text}Error: Could not find any valid extension IDs or URLs for installation.\n${normal_text}\n"
    exit 1
elif [ "$extensions_count" -gt 0 ]; then
    begin_install
fi
