{ inputs, pkgs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  # WSLg 内で Niri を起動する。ログイン画面やデスクトップセッションは構成しない。
  environment.systemPackages = [
    pkgs.niri
    inputs.noctalia.packages.${system}.default
    inputs.zen-browser.packages.${system}.default

    # デスクトップアプリ。
    pkgs.ghostty
    pkgs.nautilus
    pkgs.loupe
    pkgs.papers
    pkgs.mpv
    pkgs.file-roller
    pkgs.xdg-utils
    pkgs.xwayland-satellite

    # Wayland の基盤と操作用のツール。
    pkgs.adwaita-icon-theme
    pkgs.adw-gtk3
    pkgs.bibata-cursors
    pkgs.cliphist
    pkgs.fuzzel
    pkgs.gsettings-desktop-schemas
    pkgs.libnotify
    pkgs.playerctl
    pkgs.papirus-icon-theme
    pkgs.qt6Packages.qt6ct
    pkgs.wl-clipboard
    pkgs.wtype
  ];

  # Wayland アプリのファイル選択、リンクの起動、画面共有を提供する。
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
  };

  programs.dconf.enable = true;

  # 日本語入力は Wayland の text-input を使う。XWayland 用の設定はモジュールが行う。
  # Niri をセッションとして起動しないため、fcitx5 の起動は dot_config/niri/config.kdl で行う。
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = [ pkgs.fcitx5-mozc ];
      waylandFrontend = true;
    };
  };

  # GNOME アプリの外観の初期値。明暗の切り替えは Noctalia の GTK テンプレートが行う。
  systemd.user.services.desktop-theme = {
    description = "Apply consistent desktop appearance defaults";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      export XDG_DATA_DIRS=/run/current-system/sw/share
      export GSETTINGS_SCHEMA_DIR=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface cursor-size 24
    '';
  };

  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
    ];

    fontconfig.defaultFonts = {
      monospace = [
        "JetBrainsMono Nerd Font"
        "Noto Sans Mono CJK JP"
      ];
      sansSerif = [
        "Noto Sans CJK JP"
        "Noto Sans"
      ];
      serif = [
        "Noto Serif CJK JP"
        "Noto Serif"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
