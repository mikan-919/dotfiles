# compinit 自体は sheldon の plugins.toml 側（キャッシュ制御があるため）。
# ここは補完の見た目と挙動、そして fzf-tab の設定だけを持つ。

# 小文字入力で大文字にも一致し、次に . _ - 区切りの部分一致、最後に部分文字列一致。
# 上から順に試すので、素直に一致するときは余計な候補が混ざらない。
zstyle ':completion:*' matcher-list \
  'm:{[:lower:]}={[:upper:]}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

# 候補を種類ごとに見出し付きでまとめる。fzf-tab のグループ切り替えもこれが前提。
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:messages'     format '%d'
zstyle ':completion:*:warnings'     format 'no match: %d'

# zsh 標準のメニュー選択は切る。TAB の主導権は fzf-tab に渡す。
zstyle ':completion:*' menu no

# LS_COLORS は tools.zsh のキャッシュ経由で後から入るので、参照は遅延させる。
zstyle -e ':completion:*' list-colors 'reply=( "${(@s.:.)LS_COLORS}" )'

# 補完関数の結果をディスクにキャッシュする。apt/systemctl 系の重い補完に効く。
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache

zstyle ':completion:*' squeeze-slashes true   # foo//bar を foo/bar として扱う
zstyle ':completion:*' special-dirs true      # ../ を候補に出す
zstyle ':completion:*:functions' ignored-patterns '_*'   # 補完関数自体は隠す
# 同じ引数を二度渡させない（rm a.txt <TAB> に a.txt を出さない）。
zstyle ':completion:*:(rm|cp|mv|kill|diff):*' ignore-line other

# kill/killall の候補を自分のプロセス一覧から作る。
zstyle ':completion:*:*:kill:*' menu no
zstyle ':completion:*:*:kill:*:processes' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# --- fzf-tab ---------------------------------------------------------------
# fzf-tab は defer 読み込みだが、zstyle は補完実行時に読まれるのでここでよい。
zstyle ':fzf-tab:*' use-fzf-default-opts yes   # 配色は FZF_DEFAULT_OPTS に従う
zstyle ':fzf-tab:*' switch-group '<' '>'       # グループ間の移動
zstyle ':fzf-tab:*' prefix ''                  # 候補頭の · を出さない
zstyle ':fzf-tab:*' single-group color header  # 単一グループなら見出しだけ

# プレビュー。$realpath はパスを伴う補完でのみ立つので、両方を見て切り替える。
zstyle ':fzf-tab:complete:*:*' fzf-preview '
  if [[ -d $realpath ]]; then
    eza -1 --color=always --group-directories-first -- $realpath
  elif [[ -f $realpath ]]; then
    bat --style=numbers --color=always --line-range=:200 -- $realpath
  fi'
zstyle ':fzf-tab:complete:*:*' fzf-flags --preview-window='right:55%:wrap'

# zoxide の z はディレクトリしか返さないので、中身を一覧しておく。
zstyle ':fzf-tab:complete:(z|__zoxide_z):*' fzf-preview \
  'eza -1 --color=always --group-directories-first -- $realpath'

# git は補完対象がブランチ・コミット・ファイルと混ざるため、個別に当てる。
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
  'git diff --color=always -- $word | delta'
zstyle ':fzf-tab:complete:git-(checkout|switch|rebase|merge|log|show):*' fzf-preview \
  'git log --oneline --graph --color=always --decorate -20 $word'

# 環境変数と man は値・冒頭を見せる。
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
  fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:(man|batman):*' fzf-preview 'man -- $word 2>/dev/null | col -bx | head -100'
