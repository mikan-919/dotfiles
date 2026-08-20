# mikan dotfiles

[chezmoi](https://chezmoi.io) で管理している dotfiles です。

## 初回セットアップ

```sh
# 1. リポジトリを clone（ghqを使う場合）
ghq get git@github.com:mikan-919/dotfiles.git

# 2. chezmoi をインストール（Arch Linuxの場合）
sudo pacman -S chezmoi

# 3. chezmoi にソースディレクトリを認識させる
chezmoi init --source "$(ghq list --full-path | grep '/mikan-919/dotfiles$')"

# 4. 全ファイルを適用
chezmoi apply
```

## 日常の使い方

### 設定を変更したら

```sh
chezmoi apply   # 変更をホームディレクトリに反映
chezmoi diff    # 変更差分を確認
```

### 新しいファイルを追加する

```sh
chezmoi add ~/.zshrc           # 管理下に追加
chezmoi add ~/.config/helix    # ディレクトリごと追加も可
```

### 変更をコミットして push

```sh
git -C "$(ghq list --full-path | grep '/mikan-919/dotfiles$')" add .
git -C "$(ghq list --full-path | grep '/mikan-919/dotfiles$')" commit -m "何か変更"
git -C "$(ghq list --full-path | grep '/mikan-919/dotfiles$')" push
```

## 構成

| ファイル | 説明 |
|---|---|
| `dot_zshrc` | zsh 設定 (sheldon を呼ぶだけ) |
| `dot_zshenv` | 環境変数 (EDITOR=helix) |
| `dot_gitconfig.tmpl` | git 設定 (delta, gh 認証) |
| `dot_config/starship.toml` | プロンプト設定 |
| `dot_config/sheldon/plugins.toml` | zsh プラグイン管理 |
| `.chezmoi.toml.tmpl` | chezmoi自身の初期設定 |
| `dot_config/zsh/sync/` | 即時読み込みする zsh 設定 |
| `dot_config/zsh/async/` | `zsh-defer` で遅延読み込みする zsh 設定 |
| `packageList.arch.txt` | Arch Linux用パッケージ一覧 |
| `run_onchange_installPackages.sh.tmpl` | Archでのみ不足パッケージを自動インストール |
| `nixos/packages.nix` | NixOS用パッケージとシェル設定 |

## OS別のセットアップ

### Arch Linux

chezmoiの適用時に `packageList.arch.txt` を参照し、`paru` で不足パッケージを
インストールします。この処理はArch Linux以外では生成も実行もされません。

### NixOS

`/etc/nixos/configuration.nix` の `imports` にNixOSモジュールを追加します。

```nix
imports = [
  <nixos-wsl/modules>
  /home/nixos/ghq/github.com/mikan-919/dotfiles/nixos/packages.nix
];
```

その後、設定を反映してdotfilesを適用します。

```sh
sudo nixos-rebuild switch
chezmoi init --source "$(ghq list --full-path | grep '/mikan-919/dotfiles$')"
chezmoi diff
chezmoi apply
```

NixOSでは `paru` を使わず、パッケージはすべて `nixos/packages.nix` から管理します。

### 主なツール

- **zsh** - シェル (sheldon でプラグイン管理)
- **starship** - プロンプト
- **helix** - エディタ (EDITOR)
- **neovim** - git commit 用エディタ
- **git-delta** - git diff ビューア
- **fzf** - 履歴検索・補完
- **mise** - 開発ツールのバージョン管理
- **sheldon** - zsh プラグインマネージャ
- **zsh-defer** - プラグインの遅延読み込み

## 仕組み

chezmoiのsource directoryは `~/ghq/github.com/mikan-919/dotfiles` に設定される。
通常のgit操作で管理でき、`chezmoi apply` で各ファイルがホームディレクトリに展開される。

テンプレートファイル（`.tmpl`）は chezmoi が解釈してから配置するため、マシンごとに値が変わる設定にも対応している。
