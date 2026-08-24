# 未導入のコマンドを打ったとき、それが入っている nixpkgs のパッケージを教える。
# 実体は nix-index が配る command-not-found スクリプトで、nixos/nix.nix が
# 安定したパスに置き直している（/etc/zshrc は no_global_rcs で読まないため）。
#
# 存在確認はファイルの有無で行う。`whence -p` は見つからないコマンドを探すと
# PATH 上のディレクトリを全部歩くので、ここでは使わない。
[[ -r /etc/zsh/command-not-found.zsh ]] && source /etc/zsh/command-not-found.zsh
