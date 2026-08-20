{ inputs, pkgs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  # Niri runs nested inside WSLg's Weston compositor. No display manager or
  # full desktop session is needed for this setup.
  environment.systemPackages = [
    pkgs.niri
    inputs.noctalia.packages.${system}.default
    inputs.zen-browser.packages.${system}.default

    # Desktop applications for a future native Linux/Niri installation.
    pkgs.ghostty
    pkgs.nautilus
    pkgs.loupe
    pkgs.papers
    pkgs.mpv
    pkgs.file-roller
    pkgs.xdg-utils
    pkgs.xwayland-satellite
  ];

  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
    ];

    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono CJK JP" ];
      sansSerif = [ "Noto Sans CJK JP" "Noto Sans" ];
      serif = [ "Noto Serif CJK JP" "Noto Serif" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
