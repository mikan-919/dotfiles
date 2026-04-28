# zsh_historyに保存し、メモリに1000件、ファイルに10万件まで

HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=100000

setopt share_history           # 履歴を他のシェルと共有する
setopt hist_ignore_all_dups    # 重複するコマンド行は古い方を削除
setopt hist_ignore_dups        # 直前と同じコマンドラインはヒストリに追加しない
setopt hist_ignore_space       # スペースで始まるコマンド行はヒストリに追加しない
setopt hist_reduce_blanks      # 余分な空白は詰めて記録
setopt inc_append_history      # コマンド実行直後に書き出す
setopt extended_history        # 実行時刻を記録
