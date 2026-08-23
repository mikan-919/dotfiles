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
| `dot_zshenv` | 環境変数 (EDITOR=hx) |
| `dot_gitconfig.tmpl` | git 設定 (delta, gh 認証) |
| `dot_config/starship.toml` | プロンプト設定 |
| `dot_config/sheldon/plugins.toml` | zsh プラグイン管理 |
| `.chezmoi.toml.tmpl` | chezmoi自身の初期設定 |
| `dot_config/zsh/sync/` | 即時読み込みする zsh 設定 (options / completion / keybindings / history / exports / suggestions) |
| `dot_config/zsh/async/` | `zsh-defer` で遅延読み込みする zsh 設定 (alias / command-not-found) |
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
- **fzf** - ファイル検索・補完 (Ctrl-T / Alt-C、既定コマンドは fd)
- **atuin** - 履歴検索 (Ctrl-R)。終了コード・実行ディレクトリつきで記録
- **zoxide** - 学習型 cd (`z` / `zi`)
- **direnv** - ディレクトリ単位の環境変数。nix-direnv 経由で `use flake` が使える
- **fd** - find の置き換え。fzf の走査に使う
- **ripgrep** - grep の置き換え (`rg` は smart-case と隠しファイル込みで別名定義)
- **eza** - ls の置き換え (`ll` / `la` / `lt`)。補完候補とディレクトリのプレビューにも使う
- **bat** - cat の置き換え。`MANPAGER` と fzf/fzf-tab のファイルプレビューを兼ねる
- **lazygit** - git の TUI (`lg`)
- **tealdeer** - `tldr` によるコマンド例の逆引き
- **sheldon** - zsh プラグインマネージャ
- **zsh-defer** - プラグインの遅延読み込み
- **fzf-tab** - タブ補完を fzf に置き換える。候補のプレビュー付き
- **zsh-completions** - 標準に無い補完関数の追加分 (compinit より先に fpath へ入る)
- **mise** - 言語ランタイムのバージョン管理

## zsh の対話環境

設定は `dot_config/zsh/sync/` に役割ごとに分かれています。

| ファイル | 内容 |
|---|---|
| `options.zsh` | シェルの基本挙動 (auto_cd、auto_pushd、no_clobber など) |
| `completion.zsh` | 補完の見た目と挙動 (`zstyle`)、fzf-tab のプレビュー定義 |
| `keybindings.zsh` | emacs キーマップを土台にした編集キー |
| `history.zsh` | 履歴の件数と重複の扱い |
| `exports.zsh` | ロケール、PATH、ページャ、fzf の既定オプション |
| `suggestions.zsh` | zsh-autosuggestions の調整 |

### キーバインド

| キー | 動作 |
|---|---|
| `↑` / `↓` | 入力済みの文字列で始まる履歴を検索 (`up-line-or-beginning-search`) |
| `Ctrl-R` | atuin の履歴検索 |
| `Ctrl-T` / `Alt-C` | fzf のファイル / ディレクトリ検索 (プレビュー付き) |
| `Tab` | fzf-tab による補完。`<` `>` で候補グループを移動 |
| `Shift-Tab` | 補完候補を逆順にたどる |
| `Ctrl-X Ctrl-E` | 編集中の行を `$EDITOR` で開く |
| `Ctrl-Z` | 実行中のジョブと空プロンプトを往復する |
| `Alt-S` | 入力済みの行に `sudo` を付け外しする |
| `Ctrl-U` | カーソルより前を削除 (bash と同じ挙動) |
| `Alt-M` | 直前のコマンドの単語を挿入 |

### 補完

- 小文字入力で大文字にも一致し、`.` `_` `-` 区切りの部分一致まで段階的に緩める
- 候補は種類ごとに見出し付きでまとめ、`LS_COLORS` で色分けする
- fzf-tab のプレビューは、ディレクトリなら `eza`、ファイルなら `bat`、
  git のブランチやコミットなら `git log`、変更差分なら `delta` を出す
- 重い補完関数の結果は `~/.cache/zsh/zcompcache` に残す

### 移動

`auto_cd` と `auto_pushd` により、`..` や `-` はそのまま `cd` として働きます。
`d` で移動履歴の一覧、`1`〜`9` でその位置へ飛べます。`z` (zoxide) は使用頻度順です。

## 仕組み

chezmoiのsource directoryは `~/ghq/github.com/mikan-919/dotfiles` に設定される。
通常のgit操作で管理でき、`chezmoi apply` で各ファイルがホームディレクトリに展開される。

テンプレートファイル（`.tmpl`）は chezmoi が解釈してから配置するため、マシンごとに値が変わる設定にも対応している。

## zsh の起動時間

`~/.cache/zsh/` に生成物をキャッシュすることで、対話シェルの起動を約 32ms から
約 13ms に短縮しています。キャッシュは自動的に無効化されるため、通常は手動操作は不要です。

| キャッシュ | 内容 | 再生成の条件 |
|---|---|---|
| `sheldon.zsh` | `sheldon source` の出力 | `plugins.toml` / `plugins.lock` の更新 |
| `starship.zsh` | `starship init zsh` の出力 (`PROMPT2` を解決済み) | 下記の共通判定 + `starship.toml` |
| `tools.zsh` | `zoxide init` / `direnv hook` / `dircolors -b` の出力 | 下記の共通判定 |
| `atuin.zsh` | `atuin init zsh --disable-up-arrow` の出力 | 下記の共通判定 |
| `~/.zcompdump.zwc` | 補完ダンプの zcompile 結果 | 24 時間経過 + 下記の共通判定 |

いずれも `zcompile` 済みなので、読み込みは `.zwc` 経由になります。おかしくなったら
`rm -f ~/.cache/zsh/*.zsh ~/.cache/zsh/*.zwc ~/.zcompdump*` で作り直せます。

### キャッシュの無効化判定

`plugins.toml` の `[plugins.cache]` が定義する `zsh-cache-stale` が判定します。
NixOS では**バイナリの mtime を見ても意味がありません**——Nix はストア内の全ファイルに
mtime 1 (1970-01-01) を打つため、`$binary -nt $cache` が永久に偽になります。
`nixos-rebuild` が実際に張り替えるのは `/run/current-system` シンボリックリンクなので、
これ自身の mtime (リンクを辿らずに読む) を鍵にしています。NixOS 以外では
バイナリ自身の mtime にフォールバックします。

加えて、生成元である `plugins.toml` の変更を拾うため、`sheldon.zsh` より古い
派生キャッシュも再生成対象にしています。

補完ダンプだけは判定の鍵が `~/.zcompdump` ではなく `~/.zcompdump.zwc` です。
`compinit` は内容が変わらないとダンプを書き直さないため、その mtime は入力より
古いまま止まり得ます。放っておくと毎回フルの `compinit` が走り、この環境では
起動が 60ms ほど伸びました。`.zwc` はフル実行のたびに `zcompile` が必ず書き直すので、
そちらを鍵にしています。

計測は次のコマンドで行えます。負荷の影響を受けやすいので `hyperfine` を推奨します。

```sh
hyperfine --warmup 10 --runs 50 'zsh -i -c exit' 'zsh -f -i -c exit'
```

### 何を同期で読み、何を遅延させるか

最初のプロンプトを描くのに必要なものだけ同期です。判断は実測に基づきます。

| 対象 | 扱い | 理由 |
|---|---|---|
| compinit / starship / fzf キーバインド | 同期 | 最初のプロンプトと Ctrl-R/Ctrl-T に必要 |
| zoxide / direnv | 同期 | 合わせて 1ms 未満 |
| atuin | **遅延** | `atuin uuid` のサブプロセスだけで約 14ms かかる。セッション ID は最初のコマンド記録まで不要 |
| fzf 補完 / fzf-tab | 遅延 | タブを押すまで不要 |
| autosuggestions / syntax-highlighting | 遅延 | 入力を始めるまで不要。widget を包む syntax-highlighting を先に読む |
| エイリアス / command-not-found | 遅延 | コマンドを打つまで不要 |
| mise | **遅延** | 初回の環境スキャンが重い。存在確認ごと遅延させる (下記) |

### 注意点

- `$commands[foo]` は PATH 上の全実行ファイルをハッシュするため、この環境では
  約 40ms かかります。存在確認は `whence -p` か `${${:-foo}:c}` を使ってください。
- ただし `whence -p` も、**存在しない**コマンドを探すと PATH のディレクトリを
  すべて歩きます。この環境では未インストールの `mise` 1 回で約 32ms かかりました。
  同期パスに置いてよいのは、見つかる見込みが高いコマンドの確認だけです。
- グロブ修飾子は `[[ ]]` の中では展開されません。ファイルの新しさを見るときは
  配列代入 (`local -a stale=( $dump(N.mh+24) )`) を使ってください。
- ループで同じファイルを繰り返し `source` して計測すると、2 回目以降は関数定義済みの
  状態を測ることになり実態より速く出ます。初期化コストは毎回新しいシェルを起動して
  測ってください (atuin の実測値は 0.6ms と 15ms で食い違いました)。

### extended_glob を入れていない理由

`#` がパターン文字になり、NixOS で日常的に打つ `nix run nixpkgs#hello` や
`nixos-rebuild switch --flake .#nixos` が壊れます。後者は `.#nixos` が
「`.` の 0 回以上 + `nixos`」として `nixos/` にマッチし、フレーク参照が `nixos`
だけになって `cannot find flake 'flake:nixos'` になります。
必要な場面では関数の中で `setopt localoptions extended_glob` を立ててください。
