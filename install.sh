#!/bin/bash
########################
# Author: Rocklin K S
# Date: 07/09/2024
# This script autinstall my config
# Version: v1
############################
set -exo  pipefail

mkdir -p "$HOME/.config"
cp -rf config/networkmanager-dmenu config/openbox config/xfce4 "$HOME/.config"

copy_normal_polybar() {
    cp -rf config/polybar "$HOME/.config/"
    echo "Normal Polybar configuration copied to ~/.config"
}

copy_transparent_polybar() {
    mv -f config/polybar-transparent "$HOME/.config/polybar"
    echo "Transparent Polybar configuration copied to ~/.config/polybar"
}

echo "Select Polybar version:"
echo "1. Normal"
echo "2. Transparent"
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        copy_normal_polybar
        ;;
    2)
        copy_transparent_polybar
        ;;
    *)
        echo "Invalid choice. Please select 1 or 2."
        exit 1 
        ;;
esac

if [ -d "$HOME/.config/polybar/scripts/" ]; then
    chmod +x "$HOME/.config/polybar/scripts/"*
    echo "All scripts in ~/.config/polybar/scripts/ have been made executable."
else
    echo "Directory ~/.config/polybar/scripts/ does not exist, skipping chmod."
fi

SYSTEM_CONFIG="$HOME/.config/polybar/system.ini"
POLYBAR_CONFIG="$HOME/.config/polybar/config.ini"

ETHERNET=$(ip link | awk '/state UP/ && !/wl/ {print $2}' | tr -d :)
WIFI=$(ip link | awk '/state UP/ && /wl/ {print $2}' | tr -d :)


if [ -n "$WIFI" ]; then
    echo "Using Wi-Fi interface: $WIFI"
    sed -i "s/sys_network_interface = wlan0/sys_network_interface = $WIFI/" "$SYSTEM_CONFIG"
    

elif [ -n "$ETHERNET" ]; then
    echo "Using Ethernet interface: $ETHERNET"
    sed -i "s/sys_network_interface = wlan0/sys_network_interface = $ETHERNET/" "$SYSTEM_CONFIG"
    sed -i "s/network/ethernet/g" "$POLYBAR_CONFIG"

else
    echo "No active network interfaces found."
fi

sudo -v

sudo apt update && sudo apt upgrade -y
sudo apt -y install build-essential libssl-dev zlib1g-dev cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-render-util0-dev libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev i3-wm libjsoncpp-dev libfmt-dev ninja-build libmpdclient-dev libpulse-dev libiw-dev git sphinx libuv1-dev libxcursor-dev libcurl4-openssl-dev  libxi-dev libxtst-dev libxcb-composite0 libxcb-composite0-dev xcb-proto python3-xcbgen

wget https://github.com/polybar/polybar/releases/download/3.7.1/polybar-3.7.1.tar.gz
OUTPUT="polybar-3.7.1.tar.gz"
sudo tar -xzf $OUTPUT
cd polybar-3.7.1
sudo chmod +x build.sh
printf "y\nn\ny\ny\ny\ny\ny\ny\ny\n" | sudo ./build.sh

#### After building the polybar
sudo apt -y install vlc stacer zram-tools preload xarchiver thunar gnome-disk-utility tlp tlp-rdw thunar-volman thunar-archive-plugin udiskie udisks2 tumbler gvfs git xfce4-panel policykit-1-gnome xfdesktop4 blueman seahorse gir1.2-ayatanaappindicator3-0.1 xfce4-settings xfce4-power-manager imagemagick libayatana-appindicator3-1 bc openbox obconf playerctl xcompmgr parcellite htop neofetch gir1.2-nm-1.0 numlockx rofi lxappearance dirmngr ca-certificates software-properties-common zsh viewnior obs-studio apt-transport-https gir1.2-gtksource-4 libpeas-1.0-0 libpeas-common

############install firefox
sudo apt install dirmngr ca-certificates software-properties-common apt-transport-https wget -y
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | gpg --dearmor | sudo tee /usr/share/keyrings/packages.mozilla.org.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/packages.mozilla.org.gpg] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
sudo apt update && sudo apt install firefox -y

## install docklike-plugin
if ! dpkg -l | grep -q xfce4-docklike-plugin; then
    echo "xfce4-docklike-plugin not found. Installing from GitHub..."
    URL="https://github.com/jakbin/xfce4-docklike-plugin/releases/download/0.4.2/xfce4-docklike-plugin.deb"
    wget $URL -O xfce4-docklike-plugin.deb
    sudo dpkg -i xfce4-docklike-plugin.deb
    sudo rm xfce4-docklike-plugin.deb

    echo "Installation complete."
else
    echo "xfce4-docklike-plugin is already installed."
fi

######## Xed
read -p "Do you want to install Xed? (y/n): " choice
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    echo "Downloading Xed packages..."
    wget http://packages.linuxmint.com/pool/backport/x/xed/xed-common_3.6.6+faye_all.deb
    wget http://packages.linuxmint.com/pool/backport/x/xed/xed_3.6.6+faye_amd64.deb

    echo "Installing Xed packages..."
    sudo dpkg -i xed-common_3.6.6+faye_all.deb
    sudo dpkg -i xed_3.6.6+faye_amd64.deb
    # Fix any dependency issues
    sudo apt-get install -f

    echo "Cleaning up..."
    sudo rm xed-common_3.6.6+faye_all.deb
    sudo rm xed_3.6.6+faye_amd64.deb

    echo "Xed installation completed."
else
    echo "Installation aborted."
fi

URL="https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11723/wps-office_11.1.0.11723.XA_amd64.deb"
FILE="wps-office_11.1.0.11723.XA_amd64.deb"
L=LocalSend-1.15.4-linux-x86-64.deb
read -p "Do you want to download and install WPS Office & localsend ? (y/n): " choice

if [[ "$choice" == [Yy] ]]; then
    wget "$URL"
    wget https://github.com/localsend/localsend/releases/download/v1.15.4/LocalSend-1.15.4-linux-x86-64.deb
    
    # Install the downloaded package
    sudo apt install ./"$FILE" -y
    sudo apt install ./"$L" -y
    
    # Remove the downloaded file
    sudo rm "$FILE"
    sudo rm "$L"
    
    echo "WPS Office has been installed successfully."
else
    echo "Installation canceled."
fi

#############################################3 Wine

read -p "Do you want to install Wine? (y/n): " answer

if [[ "$answer" == "y" ]]; then
    sudo dpkg --add-architecture i386
    sudo mkdir -pm755 /etc/apt/keyrings
    sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
    sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
    sudo apt update
    sudo apt install wine-staging winetricks zenity -y
else
    echo "Wine will not be installed."
fi


home = $HOME
sudo mkdir -p zsh
sudo tar -xzvf zsh.tar.gz -C zsh
sudo cp -rf zsh/.bashrc "$home/.bashrc"
sudo cp -rf zsh/.zshrc "$home/.zshrc"

enable_service() {
    local service_name=$1
    sudo systemctl enable "$service_name"
}

enable_service bluetooth
enable_service tlp
enable_service preload
enable_service zramswap

sudo cp -rf udev/rules.d/90-backlight.rules /etc/udev/rules.d/
# Rules for the brightness
USERNAME=$(whoami)
sudo sed -i "s/\$USER/$USERNAME/g" /etc/udev/rules.d/90-backlight.rules

# Copy the networkmanager_dmenu file
sudo cp -Rf usr/bin/networkmanager_dmenu /usr/bin/
sudo chmod +x /usr/bin/networkmanager_dmenu
sudo cp -Rf zsh/* /usr/share
sudo mkdir -p Fonts
sudo tar -xzvf Fonts.tar.gz -C Fonts
sudo cp -Rf Fonts/ /usr/share/fonts/
sudo fc-cache -fv

#############################################
THEMES_DIR="themes"

if [ ! -d "$THEMES_DIR" ]; then
    echo "Themes directory does not exist."
    exit 1
fi

for file in "$THEMES_DIR"/*.tar.gz "$THEMES_DIR"/*.tar.xz; do
    # Check if the file exists (to avoid errors if no files match)
    if [ -e "$file" ]; then
        echo "Extracting $file..."

        case "$file" in
            *.tar.gz)
                # Extract .tar.gz files
                sudo tar -xzf "$file" -C "$THEMES_DIR"
                ;;
            *.tar.xz)
                # Extract .tar.xz files
                sudo tar -xf "$file" -C "$THEMES_DIR"
                ;;
        esac

        # Determine the extracted folder name
        extracted_folder="${file%.tar.*}"  # Remove the .tar.gz or .tar.xz extension
        if [ -d "$extracted_folder" ]; then
            echo "Moving $extracted_folder to /usr/share/themes/"
            sudo cp -rf "$extracted_folder" /usr/share/themes/
        else
            echo "No extracted folder found for $file."
        fi
    fi
done

echo "Extraction and copying completed."

#### XDM ###
wget https://github.com/subhra74/xdm/releases/download/8.0.29/xdman_gtk_8.0.29_amd64.deb
sudo dpkg -i xdman_gtk_8.0.29_amd64.deb
sudo rm xdman_gtk_8.0.29_amd64.deb

## Icons
SOURCE_DIR="./icons"

TARGET_DIR="/usr/share/icons"
for file in "$SOURCE_DIR"/*.tar.gz "$SOURCE_DIR"/*.tar.xz; do
    if [[ -e "$file" ]]; then
        if [[ "$file" == *.tar.gz ]]; then
            sudo tar -xzf "$file" -C /tmp/
        elif [[ "$file" == *.tar.xz ]]; then
            sudo tar -xf "$file" -C /tmp/
        fi
        sudo mv /tmp/* "$TARGET_DIR"/
        
        rm "$file"
    fi
done
echo "All operations completed successfully."
