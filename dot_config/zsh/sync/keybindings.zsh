# emacs キーマップを土台に、よく使う編集操作を足す。
# ^R は atuin、^T / ^[c は fzf が後から奪う（plugins.toml の読み込み順を参照）。
bindkey -e

# ^W と ^[b/^[f の語区切りを bash 風にする。/ で止まるのでパスを削りやすい。
autoload -Uz select-word-style
select-word-style bash

# ↑↓ を「入力済みの文字列で始まる履歴」の検索にする。行頭にいるときは
# 素の履歴移動、複数行コマンドの中では行移動として振る舞う。
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
# 端末が normal / application どちらのモードでも届くよう両方の並びを拾う。
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search

# 編集中の行を $EDITOR で開く。長いワンライナーを直すときに使う。
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# ^Z を押すたびに、フォアグラウンドのジョブと空のプロンプトを往復する。
fancy-ctrl-z() {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER='fg'
    zle accept-line -w
  else
    zle push-input -w
    zle clear-screen -w
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# 打ち終えた行に後から sudo を付ける。
sudo-command-line() {
  [[ -z $BUFFER ]] && zle up-history
  if [[ $BUFFER == sudo\ * ]]; then
    BUFFER=${BUFFER#sudo }
    (( CURSOR -= 5 ))
  else
    BUFFER="sudo $BUFFER"
    (( CURSOR += 5 ))
  fi
}
zle -N sudo-command-line
bindkey '^[s' sudo-command-line

# ^U は行全体ではなくカーソルより前だけを消す（bash と同じ挙動）。
bindkey '^U' backward-kill-line
# Shift-Tab で補完候補を逆順にたどる。
bindkey '^[[Z' reverse-menu-complete
# 直前のコマンドの単語を引っ張ってくる（^[. の語単位版）。
bindkey '^[m' copy-prev-shell-word

# Home / End / Delete / Ctrl+←→ / Alt+←→。端末ごとの差を吸収するため並記する。
bindkey '^[[H'    beginning-of-line
bindkey '^[OH'    beginning-of-line
bindkey '^[[1~'   beginning-of-line
bindkey '^[[F'    end-of-line
bindkey '^[OF'    end-of-line
bindkey '^[[4~'   end-of-line
bindkey '^[[3~'   delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;3C' forward-word
bindkey '^[[1;3D' backward-word
