#/usr/sh

# Pacman Initialize
sudo pacman-key --init
sudo pacman-key --populate archlinux
yes | sudo pacman -Scc
sudo pacman -Syyu

# Install Popular Packages
sudo pacman -S --needed \
    base base-devel \
    neovim zsh bash \
    wget curl git \
    rustup \
