{ ... }:

{
  imports = [
    ./packages.nix
    ./wayland.nix
  ];

  wsl = {
    enable = true;
    defaultUser = "nixos";
  };

  system.stateVersion = "24.05";
}
