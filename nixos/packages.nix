{ lib, pkgs, ... }:

{
  # Enable the modern Nix CLI used by `nix run`, `nix shell`, and flakes.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "claude-code" ];

  # Packages shared by the NixOS machines using these dotfiles.
  environment.systemPackages = with pkgs; [
    atuin
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
    eza
    fastfetch
    fd
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
    zoxide
    zsh
  ];

  programs.zsh.enable = true;

  # Pulls in direnv itself plus nix-direnv, whose `use flake` keeps the
  # evaluated devShell out of the GC roots' way and off the critical path.
  programs.direnv = {
    enable = true;
    # The module would hook direnv from /etc/zshrc, which the user config skips
    # via `setopt no_global_rcs`. The hook is installed from plugins.toml instead.
    enableZshIntegration = false;
  };

  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "ja_JP.UTF-8/UTF-8"
  ];

  users.users.nixos.shell = pkgs.zsh;
}
