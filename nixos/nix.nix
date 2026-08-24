{ pkgs, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    # direnv が張った devShell を GC から守る。これが無いと掃除のたびに開発環境が
    # 消え、次にそのディレクトリへ入ったときに作り直しになる。
    keep-outputs = true;
    keep-derivations = true;

    # wheel のユーザーにも信頼を与える。root だけだと、flake 側が指定した
    # binary cache が黙って無視される。これらのリストは既定値を上書きせず
    # 追記されるので、root や cache.nixos.org を書き足す必要はない。
    trusted-users = [ "@wheel" ];

    substituters = [ "https://nix-community.cachix.org" ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    # 編集中のリポジトリはたいてい dirty なので、そのたびの警告は要らない。
    warn-dirty = false;
  };

  # ストア内の同一ファイルをハードリンクにまとめる。auto-optimise-store と違って
  # 書き込みのたびにハッシュを取らないので、日々のビルドは遅くならない。
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  # nixos-rebuild のラッパー。世代の差分を nvd で見せ、掃除も受け持つ。
  # 掃除は nh に一本化する: nix.gc.automatic と同時に有効にすると、nh 側の
  # assertion で rebuild そのものが止まる。
  programs.nh = {
    enable = true;
    flake = "/home/nixos/ghq/github.com/mikan-919/dotfiles";
    clean = {
      enable = true;
      dates = "weekly";
      # 直近 5 世代と、30 日以内に作った世代は残す。
      extraArgs = "--keep 5 --keep-since 30d";
    };
  };

  # 標準の command-not-found はチャンネル同梱の DB を読むため、flake 運用では
  # 動かない。実際、zsh 側にハンドラだけあって本体が無い状態だった。
  programs.command-not-found.enable = false;

  programs.nix-index = {
    enable = true;
    # /etc/zshrc は no_global_rcs で読み飛ばしているので、ここから挿しても
    # 届かない。ハンドラは下の /etc のファイルをユーザーの zsh 設定が読む。
    enableZshIntegration = false;
    enableBashIntegration = false;
  };

  # `, cowsay` で入れずに一度だけ実行する。DB は nix-index-database の配布物を
  # 使うので、自前で nix-index を 10 分回す必要はない。
  programs.nix-index-database.comma.enable = true;

  # ユーザーの zsh から読めるよう、安定したパスに置き直す。
  environment.etc."zsh/command-not-found.zsh".source =
    "${pkgs.nix-index}/etc/profile.d/command-not-found.sh";

  # NixOS 以外向けにビルドされた実行ファイルを動かすためのローダ。bun / npm / uv
  # が引いてくるプリビルドバイナリは、これが無いと ELF interpreter が見つからず
  # 起動しない。足りないライブラリが出たらここに足す。
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib # libstdc++
      zlib
      openssl
      curl
      icu
      libxml2
      libxcrypt-legacy
    ];
  };

  # 世代の差分表示。nh が内部で使うほか、単体でも打てる。
  environment.systemPackages = [ pkgs.nvd ];
}
