#!/usr/bin/env bash
#
# まっさらな NixOS-WSL にこの dotfiles 一式を入れる。
#
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/mikan-919/dotfiles/main/bootstrap.sh)"
#
# パイプ (`curl … | bash`) ではなくこの形にしているのは、標準入力を端末のまま
# 残すため。パイプにすると sudo がパスワードを読めず、そこで詰まる。
#
# 何度でも走らせてよい。2 回目以降は clone の代わりに pull して rebuild する。

set -euo pipefail

REPO="${REPO:-github.com/mikan-919/dotfiles}"
FLAKE_HOST="${FLAKE_HOST:-nixos}"

# flake がまだ有効になっていない機械で走る前提なので、nix を呼ぶたびにこれを
# 添える。switch が通れば nixos/nix.nix が nix.conf に書き込むので、以降は不要。
NIX_FLAGS=(--extra-experimental-features "nix-command flakes")

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m警告:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mエラー:\033[0m %s\n' "$*" >&2; exit 1; }

# 素の NixOS には git も chezmoi も入っていない。入っていなければ nixpkgs から
# その場限りで借りる。ストアに落ちるだけで、環境には何も足さない。
borrow() {
  local cmd=$1; shift
  if command -v "$cmd" >/dev/null 2>&1; then
    "$cmd" "$@"
  else
    log "$cmd が無いので nixpkgs から一時的に借ります"
    nix "${NIX_FLAGS[@]}" shell "nixpkgs#$cmd" --command "$cmd" "$@"
  fi
}

confirm() {
  [[ ${BOOTSTRAP_YES:-} == 1 ]] && return 0
  [[ -t 0 ]] || die "対話できない環境です。承知の上なら BOOTSTRAP_YES=1 を付けてください。"
  local reply
  read -r -p "$1 [y/N]: " reply
  [[ ${reply:-} == [yY] ]]
}

# ── 前提の確認 ──────────────────────────────────────────────────────────

[[ -e /etc/NIXOS ]] || die "NixOS ではないようです (/etc/NIXOS が見つかりません)。"
command -v nix >/dev/null || die "nix が見つかりません。"
command -v nixos-rebuild >/dev/null || die "nixos-rebuild が見つかりません。"

# この構成は NixOS-WSL 専用。hardware-configuration.nix を読まず、ディスクも
# ブートローダも wsl モジュールに任せているため、実機に当てると起動しなくなる。
if [[ ! -f /etc/wsl.conf && -z ${WSL_DISTRO_NAME:-} ]]; then
  warn "WSL 上に見えません。この構成は NixOS-WSL 専用で、実機向けの"
  warn "hardware-configuration.nix を持っていません。当てると起動しなくなります。"
  confirm "それでも続けますか?" || exit 1
fi

# 設定にはユーザー名 nixos を直書きしている箇所がある。
if [[ $(id -un) != nixos ]]; then
  warn "ユーザー名が nixos ではありません ($(id -un))。"
  warn "nixos/nix.nix の programs.nh.flake と nixos/packages.nix の"
  warn "users.users.nixos を、自分のユーザー名に合わせて書き換えてください。"
  confirm "このまま続けますか?" || exit 1
fi

# ── リポジトリ ──────────────────────────────────────────────────────────

# 置き場所は ghq に決めさせる。`ghq root` は git config の ghq.root と
# $GHQ_ROOT を見て、どちらも無ければ ~/ghq を返す。まっさらな機械では
# gitconfig もまだ無いので ~/ghq になり、これが他の設定の前提と一致する。
GHQ_ROOT="${GHQ_ROOT:-$(borrow ghq root | head -1)}"
REPO_DIR="$GHQ_ROOT/$REPO"

# `.chezmoi.toml.tmpl` の sourceDir と nixos/nix.nix の programs.nh.flake は
# ~/ghq/... を前提にしている。ghq root がそこから外れているなら、両方を直す
# 必要があるので黙って進めない。
if [[ $REPO_DIR != "$HOME/ghq/$REPO" ]]; then
  warn "ghq の置き場所が $REPO_DIR です。"
  warn ".chezmoi.toml.tmpl の sourceDir と nixos/nix.nix の programs.nh.flake は"
  warn "\$HOME/ghq/$REPO を前提にしているので、合わせて書き換えてください。"
  confirm "このまま続けますか?" || exit 1
fi

# -u は、まだ無ければ clone、あれば pull --ff-only。どちらの場合も同じ一行で済む。
log "$REPO_DIR を用意します"
borrow ghq get -u "$REPO"

# ── システム ────────────────────────────────────────────────────────────

# flake は git の管理下にあるファイルしか見ない。clone 直後は問題ないが、
# 手を入れた状態で走らせたときに黙って古い内容を使わないよう先に知らせる。
if [[ -n $(borrow git -C "$REPO_DIR" status --porcelain 2>/dev/null) ]]; then
  warn "リポジトリに未コミットの変更があります。"
  warn "flake は git 管理下のファイルしか見ないため、未追跡のファイルは無視されます。"
fi

log "システムを切り替えます (nixos-rebuild switch --flake $REPO_DIR#$FLAKE_HOST)"
log "sudo のパスワードを聞かれます。初回は数分かかります。"
sudo nixos-rebuild switch \
  --flake "$REPO_DIR#$FLAKE_HOST" \
  --option extra-experimental-features "nix-command flakes"

# ── dotfiles ────────────────────────────────────────────────────────────

# ここまで来れば chezmoi は /run/current-system/sw/bin にいる。
log "chezmoi でホームディレクトリに展開します"
borrow chezmoi init --apply --source "$REPO_DIR"

# ── zsh ─────────────────────────────────────────────────────────────────

# 初回の zsh 起動時にも走るが、先に済ませておくと最初のプロンプトが速い。
if command -v sheldon >/dev/null 2>&1; then
  log "zsh プラグインを取得します"
  sheldon lock
fi

log "完了しました。"

cat <<'EOF'

次の一手:

  exec zsh        新しい設定でシェルを開き直す
  nh os switch    以降の rebuild。世代の差分を nvd で見せてくれる

覚えておくこと:

  - origin は HTTPS。push するなら `gh auth login` を済ませるか、
    git remote set-url origin ssh://git@github.com/mikan-919/dotfiles.git
  - 設定を変えたら `git add` してから rebuild する。flake は git 管理下の
    ファイルしか見ないため、未追跡のファイルは無いものとして扱われる。
  - デスクトップ (Niri、日本語入力) は WSLg 側から niri を起動したときに動く。

EOF
