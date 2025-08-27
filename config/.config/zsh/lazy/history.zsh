# 履歴ファイルの保存先
# メモリに保存される履歴の件数
# 履歴ファイルに保存される履歴の件数
export HISTFILE=${HOME}/.config/zsh/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
export HISTFILESIZE=100000
# 重複を記録しない
# 開始と終了を記録
# ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
# スペースで始まるコマンド行はヒストリリストから削除
# ヒストリを呼び出してから実行する間に一旦編集可能
# 余分な空白は詰めて記録
# 古いコマンドと同じものは無視
# historyコマンドは履歴に登録しない
# 保管時にヒストリを自動的に展開
# history共有
setopt hist_ignore_dups
setopt EXTENDED_HISTORY
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_verify
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_no_store
setopt hist_expand
setopt share_history
setopt inc_append_history
