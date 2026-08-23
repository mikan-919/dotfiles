# ロケールは LANG だけを立てる。LC_ALL は個別カテゴリの上書きを一切許さないため、
# 例えばソート順だけ C にしたい場面まで潰れてしまう。
export LANG=ja_JP.UTF-8

export RUSTC_WRAPPER=sccache

# PATH は存在するものだけを足す。壊れた要素は補完の走査を無駄に遅くする。
() {
  local dir
  for dir in $HOME/.bun/bin $HOME/.turso $HOME/.steel/bin; do
    [[ -d $dir ]] && path=( $dir $path )
  done
  # 重複した要素は落とす（再読み込みで PATH が伸び続けるのを防ぐ）。
  typeset -gU path PATH
}

# --- ページャ ---------------------------------------------------------------
export PAGER=less
# -R: 色をそのまま通す / -i: 小文字入力は大小無視 / -M: 位置を詳しく出す
export LESS='-R -i -M'
export LESSHISTFILE=${XDG_STATE_HOME:-$HOME/.local/state}/less/history
[[ -d ${LESSHISTFILE:h} ]] || mkdir -p ${LESSHISTFILE:h}

if whence -p bat >/dev/null; then
  export BAT_THEME=ansi          # 端末（noctalia）の配色をそのまま使う
  export BAT_STYLE=numbers,changes
  # man を bat で色付けする。col -bx で overstrike と TAB を落としてから渡す。
  export MANPAGER='sh -c "col -bx | bat --language=man --plain"'
  export MANROFFOPT='-c'
fi

# --- fzf --------------------------------------------------------------------
# fd は .gitignore を尊重して .git を飛ばすので、既定の find(1) より速く静か。
if whence -p fd >/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# 配色は starship / noctalia と同じ kanagawa 系の値。bg:-1 で端末の背景を透かす。
export FZF_DEFAULT_OPTS='
  --height=60% --layout=reverse --border=rounded --info=inline-right
  --prompt=" " --pointer="=>" --marker="+"
  --color=fg:#dcd7ba,bg:-1,hl:#7e9cd8
  --color=fg+:#dcd7ba,bg+:#2a2a37,hl+:#7fb4ca
  --color=info:#727169,prompt:#957fb8,pointer:#c34043
  --color=marker:#76946a,spinner:#c0a36e,header:#6a9589,border:#54546d
  --bind=ctrl-/:toggle-preview,ctrl-u:preview-page-up,ctrl-d:preview-page-down
  --bind=alt-a:select-all,alt-d:deselect-all
'
export FZF_CTRL_T_OPTS='--preview "bat --style=numbers --color=always --line-range=:300 -- {} 2>/dev/null || eza -1 --color=always -- {}" --preview-window=right:55%:wrap'
export FZF_ALT_C_OPTS='--preview "eza -1 --color=always --group-directories-first -- {}" --preview-window=right:55%:wrap'
