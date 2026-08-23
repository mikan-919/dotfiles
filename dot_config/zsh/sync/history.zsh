# 履歴の実体は ~/.zsh_history。↑ での前方一致検索がメモリ上の HISTSIZE 件を、
# 全期間の検索は atuin（^R）が担当する。

HISTFILE=~/.zsh_history
# 起動時に読み込むのはこの件数まで。全文検索は atuin に任せるので、
# 起動コストと ↑ でたどれる範囲の釣り合いでこの値にしてある。
HISTSIZE=10000
SAVEHIST=100000

setopt share_history           # 履歴を他のシェルと共有する（inc_append_history を含む）
setopt extended_history        # 実行時刻と所要時間を記録
setopt hist_ignore_all_dups    # 重複するコマンド行は古い方を削除
setopt hist_ignore_space       # スペースで始まるコマンド行はヒストリに追加しない
setopt hist_reduce_blanks      # 余分な空白は詰めて記録
setopt hist_save_no_dups       # ファイルに書き出す際にも重複を落とす
setopt hist_expire_dups_first  # 溢れたときは重複から先に捨てる
setopt hist_find_no_dups       # 検索でも同じ行を二度出さない
setopt hist_verify             # !! などの展開結果を実行前に一度見せる
