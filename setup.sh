#!/bin/zsh


if [[ ! -d "$HOME/.config" ]]; then
    echo "[Create] $HOME/.config"
    mkdir -p "$HOME/.config"
fi