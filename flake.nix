{
  description = "NixOS-WSL configuration for mikan-919";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ユーザー領域のうち、dotfile ではない部分（パッケージ、user サービス、
    # XDG の取り決め）を受け持つ。設定ファイルそのものは chezmoi のままで、
    # 線引きは nixos/home.nix の先頭に書いてある。
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # command-not-found 用のビルド済みデータベース。自前で `nix-index` を回すと
    # 10 分以上かかるうえ、その間ずっと当たらない。
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, nixos-wsl, home-manager, nix-index-database, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        nixos-wsl.nixosModules.default
        home-manager.nixosModules.home-manager
        nix-index-database.nixosModules.nix-index
        ./nixos/configuration.nix
      ];
    };
  };
}
