{ inputs, pkgs, ... }:

let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

  fxAgent = pkgs.callPackage ./pkgs/fx.nix { };
in
{
  imports = [ inputs.omp.homeManagerModules.default ];

  # 設定ファイルと環境変数は chezmoi、パッケージと既定アプリは Home Manager で管理する。
  # zsh などの設定生成は有効にしない。環境変数は dot_config/zsh/sync/exports.zsh に置く。

  home.stateVersion = "24.05";

  programs.omp.enable = true;

  # ユーザー用の開発支援ツール。
  home.packages = with pkgs; [
    claude-code
    llmAgents.codex
    llmAgents.dsh
    fxAgent
    repomix
  ];

  # xdg-open が開くアプリをファイル形式ごとに指定する。
  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        browser = [ "zen.desktop" ];
        image = [ "org.gnome.Loupe.desktop" ];
        video = [ "mpv.desktop" ];
        pdf = [ "org.gnome.Papers.desktop" ];
        files = [ "org.gnome.Nautilus.desktop" ];
      in
      {
        "text/html" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/unknown" = browser;

        "image/png" = image;
        "image/jpeg" = image;
        "image/gif" = image;
        "image/webp" = image;
        "image/svg+xml" = image;

        "video/mp4" = video;
        "video/webm" = video;
        "video/x-matroska" = video;
        "audio/mpeg" = video;
        "audio/flac" = video;

        "application/pdf" = pdf;
        "inode/directory" = files;
      };
  };
}
