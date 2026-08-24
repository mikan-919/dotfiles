{ pkgs, ... }:

{
  # ── chezmoi と home-manager の役割分担 ──────────────────────────────────
  #
  #   chezmoi      … 手で書いて頻繁に触る設定ファイルそのもの。zsh, sheldon,
  #                  starship, niri, ghostty, helix, git がこれにあたる。
  #   home-manager … ユーザー単位のパッケージ、user サービス、XDG の取り決め。
  #
  # したがって `programs.zsh` や `programs.starship` のような「~/.zshrc を
  # 生成する」系のモジュールはここでは有効にしない。chezmoi の生成物と衝突し、
  # ~/.cache/zsh のキャッシュを前提にした起動時間の作り込みも壊れる。
  # 同じ理由で home.sessionVariables も使わない: それを読ませるための shell
  # 統合を入れていないので、書いても効かない。環境変数は sync/exports.zsh へ。

  home.stateVersion = "24.05";

  # システム全体ではなく自分だけが使うもの。更新が速く、root には要らない。
  home.packages = with pkgs; [
    claude-code
    codex
    repomix
  ];

  # `xdg-open` が何で開くかの取り決め。Niri には既定のアプリを決める仕組みが
  # 無いので、ここで宣言しておかないとリンクや添付ファイルが開かない。
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
