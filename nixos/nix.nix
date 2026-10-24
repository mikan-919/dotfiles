{ pkgs, ... }:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # direnv の開発環境がストアの掃除で消えるのを防ぐ。
    keep-outputs = true;
    keep-derivations = true;

    # wheel グループによる外部バイナリキャッシュの利用を許可する。
    trusted-users = [ "@wheel" ];

    substituters = [
      "https://nix-community.cachix.org"
      # llm-agents.nix のビルド済みパッケージを取得し、ローカルでのコンパイルを避ける。
      "https://cache.numtide.com"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];

    # 未コミットの変更に対する警告を抑制する。
    warn-dirty = false;
  };

  # ストアの重複ファイルを週次でハードリンクにまとめる。
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  # nh で構成の反映と世代の掃除を行う。nix.gc.automatic は併用しない。
  programs.nh = {
    enable = true;
    flake = "/home/nixos/ghq/github.com/mikan-919/dotfiles";
    clean = {
      enable = true;
      dates = "weekly";
      # 直近 5 世代と、30 日以内に作った世代は残す。
      extraArgs = "--keep 5 --keep-since 30d";
    };
  };

  # チャンネル用の検索を無効にし、flake 用の nix-index を使う。
  programs.command-not-found.enable = false;

  programs.nix-index = {
    enable = true;
    # zsh は /etc/zshrc を読まないため、下の検索スクリプトを設定側から読み込む。
    enableZshIntegration = false;
    enableBashIntegration = false;
  };

  # `, cowsay` のように、未導入のコマンドを一度だけ実行する。
  programs.nix-index-database.comma.enable = true;

  # zsh 設定から読み込む検索スクリプトを /etc に配置する。
  environment.etc."zsh/command-not-found.zsh".source =
    "${pkgs.nix-index}/etc/profile.d/command-not-found.sh";

  # bun、npm、uv などが取得する Linux バイナリ向けのローダーと共有ライブラリ。
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib # libstdc++
      zlib
      openssl
      curl
      icu
      libxml2
      libxcrypt-legacy
    ];
  };

  # nh と単独実行で使う世代の差分表示。
  environment.systemPackages = [ pkgs.nvd ];
}
