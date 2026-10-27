{ inputs, pkgs, ... }:

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
    # Windows 側の Zed は wsl.exe --exec でシェルを通さずに cp などを呼び、WSL 側へ拡張機能を送る。
    # NixOS には /bin/cp などが無いので、呼ばれるコマンドを /bin に置く。
    extraBin = with pkgs; [
      { src = "${coreutils}/bin/cp"; }
      { src = "${coreutils}/bin/mv"; }
      { src = "${coreutils}/bin/rm"; }
      { src = "${coreutils}/bin/mkdir"; }
      { src = "${coreutils}/bin/ls"; }
      { src = "${coreutils}/bin/cat"; }
      { src = "${coreutils}/bin/chmod"; }
      { src = "${coreutils}/bin/uname"; }
      { src = "${coreutils}/bin/dirname"; }
      { src = "${gnutar}/bin/tar"; }
      { src = "${gzip}/bin/gzip"; }
    ];
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
