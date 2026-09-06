{ inputs, ... }:

{
  imports = [
    ./nix.nix
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

  # home-manager は NixOS モジュールとして動かす。nixos-rebuild 一回で
  # システムとユーザー領域の両方が切り替わる。
  home-manager = {
    # システム側で評価した pkgs をそのまま使う。ユーザー用に nixpkgs を
    # もう一度評価しないので、rebuild が余分に遅くならない。
    useGlobalPkgs = true;
    # NixOS の specialArgs は home-manager のユーザー設定には渡らないため、
    # flake input から Codex を取得するために明示的に渡す。
    extraSpecialArgs = { inherit inputs; };
    # パッケージを /etc/profiles/per-user/nixos に置く。ここは既に PATH に
    # 入っているので、シェル側の設定は要らない。
    useUserPackages = true;
    # chezmoi が置いたファイルと衝突したとき、失敗させず退避させる。
    # rebuild が途中で止まるより、後から差分を見て潰す方が扱いやすい。
    backupFileExtension = "hm-bak";
    users.nixos = import ./home.nix;
  };

  system.stateVersion = "24.05";
}
