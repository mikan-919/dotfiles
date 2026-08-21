{ lib, pkgs, ... }:

{
  # Enable the modern Nix CLI used by `nix run`, `nix shell`, and flakes.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "claude-code" ];

  # Packages shared by the NixOS machines using these dotfiles.
  environment.systemPackages = with pkgs; [
    bat
    bottom
    bun
    chezmoi
    clang
    claude-code
    cmake
    codex
    curl
    delta
    erdtree
    fastfetch
    fzf
    gh
    ghq
    git
    helix
    herdr
    hyperfine
    jq
    lld
    mold
    neovim
    ninja
    openssh
    repomix
    sccache
    sheldon
    starship
    unzip
    uv
    wget
    zsh
  ];

  programs.zsh.enable = true;

  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "ja_JP.UTF-8/UTF-8"
  ];

  users.users.nixos.shell = pkgs.zsh;
}
