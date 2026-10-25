{ inputs, ... }:

{
  imports = [
    ./nix.nix
    ./packages.nix
    ./wayland.nix
  ];

  wsl = {
    enable = true;
    useWindowsDriver = true;
    interop.register = true;
    wslConf.interop = {
      enabled = true;
      appendWindowsPath = true;
    };
    defaultUser = "nixos";
  };

  hardware.graphics.enable = true;

  # システムとユーザーの設定を nixos-rebuild で同時に反映する。
  home-manager = {
    # nixpkgs の再評価を避け、システムと同じパッケージ集合を使う。
    useGlobalPkgs = true;
    # 外部入力は Home Manager にも明示的に渡す。
    extraSpecialArgs = { inherit inputs; };
    # ユーザーのパッケージを PATH に含まれる /etc/profiles/per-user/nixos に置く。
    useUserPackages = true;
    # 既存ファイルと衝突した場合は退避する。
    backupFileExtension = "hm-bak";
    users.nixos = import ./home.nix;
  };

  system.stateVersion = "24.05";
}
