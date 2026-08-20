{ pkgs, ... }:

{
  # Enable the modern Nix CLI used by `nix run`, `nix shell`, and flakes.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Packages shared by the NixOS machines using these dotfiles.
  # Project-specific language versions are managed by mise.
  environment.systemPackages = with pkgs; [
    bat
    bottom
    chezmoi
    clang
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
    hyperfine
    jq
    lld
    mise
    mold
    neovim
    ninja
    openssh
    repomix
    sccache
    sheldon
    starship
    unzip
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
