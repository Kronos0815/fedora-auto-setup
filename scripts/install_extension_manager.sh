#!/usr/bin/env bash

echo "Installing GNOME Shell Extension Manager..."

# Ensure Flatpak is installed
if ! command -v flatpak &> /dev/null; then
    echo "Flatpak is not installed. Installing Flatpak..."
    sudo dnf install -y flatpak
fi

# Add Flathub repository if not already added
if ! flatpak remote-list | grep -q flathub; then
    echo "Adding Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Install GNOME Shell Extension Manager
echo "Installing GNOME Shell Extension Manager from Flathub..."
flatpak install -y flathub com.mattjakeman.ExtensionManager

echo "GNOME Shell Extension Manager installed successfully!"