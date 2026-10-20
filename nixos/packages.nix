{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  # nixpkgs の `vp` は別ソフトなので、Vite+ の CLI は専用 flake から取得する。
  vitePlus = inputs.nix-vite-plus.packages.${pkgs.stdenv.hostPlatform.system}.vp;
in
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "claude-code" ];

  environment.systemPackages = with pkgs; [
    # コマンド操作
    bat
    bottom
    coreutils # dircolors で補完候補の色を設定する
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
    util-linux # bat を使う MANPAGER 用の col
    wget

    # 開発
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
    glib
    glib.dev
    pkg-config

    # エディター
    helix
    neovim

    # Git
    delta
    gh
    ghq
    git
    lazygit

    # シェル
    atuin
    sheldon
    starship
    zoxide
    zsh

    # システム管理
    chezmoi
    openssh
  ];
  environment.variables.PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig";

  programs.zsh.enable = true;

  # direnv と nix-direnv でディレクトリごとの開発環境を読み込む。
  programs.direnv = {
    enable = true;
    # /etc/zshrc を読まないため、フックは sheldon の plugins.toml から設定する。
    enableZshIntegration = false;
  };

  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "ja_JP.UTF-8/UTF-8"
  ];

  users.users.nixos.shell = pkgs.zsh;
}
