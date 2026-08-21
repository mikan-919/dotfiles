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
| `dot_zshrc` | zsh 設定 (`sheldon source` の出力をキャッシュして読む) |
| `dot_zshenv` | 環境変数 (EDITOR=helix) |
| `dot_gitconfig.tmpl` | git 設定 (delta, gh 認証) |
| `dot_config/starship.toml` | プロンプト設定 |
| `dot_config/sheldon/plugins.toml` | zsh プラグイン管理 |
| `.chezmoi.toml.tmpl` | chezmoi自身の初期設定 |
| `dot_config/zsh/sync/` | 即時読み込みする zsh 設定 |
| `dot_config/zsh/async/` | `zsh-defer` で遅延読み込みする zsh 設定 |
| `packageList.arch.txt` | Arch Linux用パッケージ一覧 |
| `run_onchange_installPackages.sh.tmpl` | Archでのみ不足パッケージを自動インストール |
| `flake.nix` / `flake.lock` | NixOSと外部入力の宣言・バージョン固定 |
| `nixos/configuration.nix` | NixOS-WSLのホスト設定 |
| `nixos/packages.nix` | 共通CLIパッケージとシェル設定 |
| `nixos/wayland.nix` | Niri、Noctalia、GUIアプリ、Wayland基盤、デスクトップ用フォント |
| `dot_config/niri/config.kdl` | Niriの起動項目、外観、キーバインド |
| `dot_config/noctalia/config.toml` | デスクトップ全体の配色源とテーマ配布設定 |
| `dot_config/ghostty/config.ghostty` | Ghosttyのフォント、外観、Noctaliaテーマ連携 |
| `dot_config/helix/config.toml` | HelixのNoctaliaテーマ連携 |

## OS別のセットアップ

### Arch Linux

chezmoiの適用時に `packageList.arch.txt` を参照し、`paru` で不足パッケージを
インストールします。この処理はArch Linux以外では生成も実行もされません。

### NixOS

このリポジトリのflakeからNixOS設定を反映します。

NixOS-WSL、nixpkgs、Noctalia、Zen Browserのバージョンは `flake.lock` で固定されます。
NiriとNoctalia、Ghostty、Zen Browser、基本的なGUIアプリ、デスクトップ用フォントは
`nixos/wayland.nix` で管理します。

NoctaliaのKanagawaテーマを配色の単一ソースとし、GTK 3/4、Ghostty、Helix、
Qt、Starshipへ公式テンプレートで配色を反映します。GNOMEアプリのテーマ、アイコン、
カーソルはそれぞれadw-gtk3、Papirus、Bibataへ統一されます。

WSLg上ではディスプレイマネージャーを使わず、次のコマンドでデスクトップを起動します。

```sh
niri -- ghostty
```

```sh
cd "$(ghq list --full-path | grep '/mikan-919/dotfiles$')"
sudo nixos-rebuild switch --flake .#nixos
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
- **sheldon** - zsh プラグインマネージャ
- **zsh-defer** - プラグインの遅延読み込み

## 仕組み

chezmoiのsource directoryは `~/ghq/github.com/mikan-919/dotfiles` に設定される。
通常のgit操作で管理でき、`chezmoi apply` で各ファイルがホームディレクトリに展開される。

テンプレートファイル（`.tmpl`）は chezmoi が解釈してから配置するため、マシンごとに値が変わる設定にも対応している。

## zsh の起動時間

`~/.cache/zsh/` に生成物をキャッシュすることで、対話シェルの起動を約 32ms から
約 11ms に短縮しています。キャッシュは元ファイルの mtime で自動的に無効化される
ため、通常は手動操作は不要です。

| キャッシュ | 内容 | 再生成の条件 |
|---|---|---|
| `sheldon.zsh` | `sheldon source` の出力 | `plugins.toml` / `plugins.lock` の更新 |
| `starship.zsh` | `starship init zsh` の出力 (`PROMPT2` を解決済み) | starship 本体 / `starship.toml` の更新 |
| `~/.zcompdump.zwc` | 補完ダンプの zcompile 結果 | ダンプの再生成時 |

いずれも `zcompile` 済みなので、読み込みは `.zwc` 経由になります。おかしくなったら
`rm -rf ~/.cache/zsh ~/.zcompdump*` で作り直せます。

計測は次のコマンドで行えます。

```sh
zsh -f -c 'zmodload zsh/datetime
s=$EPOCHREALTIME; for i in {1..30}; do zsh -i -c exit; done
printf "%.2f ms/run\n" $(( ($EPOCHREALTIME-s)/30*1000 ))'
```

### 注意点

- `$commands[foo]` は PATH 上の全実行ファイルをハッシュするため、この環境では
  約 40ms かかります。存在確認は `whence -p` か `${${:-foo}:c}` を使ってください。
- グロブ修飾子は `[[ ]]` の中では展開されません。ファイルの新しさを見るときは
  配列代入 (`local -a stale=( $dump(N.mh+24) )`) を使ってください。
