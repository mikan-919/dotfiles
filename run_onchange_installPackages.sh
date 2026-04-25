#!/bin/bash

# packageList.txt hash: {{ include "packageList.txt" | sha256sum }}
# This script runs whenever packageList.txt changes.

echo "Checking for missing packages..."

# Read the list and install missing packages
# Using --needed to skip already installed ones
MISSING_PACKAGES=$(comm -23 <(sort ~/dotfiles/packageList.txt) <(pacman -Qq | sort))

if [ -n "$MISSING_PACKAGES" ]; then
    echo "Installing: $MISSING_PACKAGES"
    # Note: Requires sudo or to be run as root
    sudo pacman -S --needed --noconfirm $MISSING_PACKAGES
else
    echo "All packages are already installed."
fi
