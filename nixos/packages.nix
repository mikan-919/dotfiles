{ inputs, lib, pkgs, ... }:

let
  # nixpkgs の `vp` は別ソフトなので、Vite+ の CLI は専用 flake から取得する。
  vitePlus = inputs.nix-vite-plus.packages.${pkgs.system}.vp;

  # Grouped only for readability; every group is concatenated below.
  packages = with pkgs; {
    shell = [
      atuin
      sheldon
      starship
      zoxide
      zsh
    ];

    cli = [
      bat
      bottom
      coreutils # dircolors, seeding LS_COLORS for completion listings
      curl
      erdtree
      eza
      fastfetch
      fd
      fzf
      herdr
      hyperfine
      jq
      ripgrep
      tealdeer
      unzip
      util-linux # col(1), used by the bat-backed MANPAGER
      wget
    ];

    git = [
      delta
      gh
      ghq
      git
      lazygit
    ];

    editor = [
      helix
      neovim
    ];

    dev = [
      bun
      clang
      cmake
      lld
      mise
      mold
      ninja
      nodejs
      sccache
      uv
      vitePlus
    ];

    system = [
      chezmoi
      openssh
    ];
  };
in
{
  # Nix デーモンとツールまわりの設定は nixos/nix.nix にある。
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "claude-code" ];

  # Packages shared by the NixOS machines using these dotfiles.
  environment.systemPackages = lib.concatLists (lib.attrValues packages);

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
