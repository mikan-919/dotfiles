{ ... }:

{
  imports = [
    ./packages.nix
    ./wayland.nix
  ];

  wsl = {
    enable = true;
    interop.register = true;
    wslConf.interop = {
      enabled = true;
      appendWindowsPath = true;
    };
    defaultUser = "nixos";
  };

  system.stateVersion = "24.05";
}
