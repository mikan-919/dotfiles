# mikan dotfiles

[chezmoi](https://chezmoi.io) で管理している dotfiles です。

## 初回セットアップ

```sh
# 1. リポジトリを clone
git clone https://github.com/mikan-919/dotfiles ~/dotfiles

# 2. chezmoi をインストール (Arch Linuxの場合)
sudo pacman -S chezmoi

# 3. chezmoi にソースディレクトリを認識させる
chezmoi init --source ~/dotfiles

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
git -C ~/dotfiles add .
git -C ~/dotfiles commit -m "何か変更"
git -C ~/dotfiles push
```

## 構成

| ファイル | 説明 |
|---|---|
| `dot_zshrc` | zsh 設定 (sheldon を呼ぶだけ) |
| `dot_zshenv` | 環境変数 (EDITOR=helix) |
| `dot_gitconfig.tmpl` | git 設定 (delta, gh 認証) |
| `dot_config/starship.toml` | プロンプト設定 |
| `dot_config/sheldon/plugins.toml` | zsh プラグイン管理 |
| `dot_config/chezmoi/chezmoi.toml.tmpl` | chezmoi 自身の設定 |
| `dot_config/zsh/sync/` | 即時読み込みする zsh 設定 |
| `dot_config/zsh/async/` | `zsh-defer` で遅延読み込みする zsh 設定 |
| `packageList.txt` | インストール済パッケージ一覧 |
| `run_onchange_installPackages.sh` | 不足パッケージを自動インストール |

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

chezmoi の source directory を `~/dotfiles` に設定してあるので、通常の git 操作で管理できる。`chezmoi apply` で各ファイルがホームディレクトリに展開される。

テンプレートファイル（`.tmpl`）は chezmoi が解釈してから配置するため、マシンごとに値が変わる設定にも対応している。
