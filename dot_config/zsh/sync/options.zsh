# 対話シェルの基本挙動。履歴は history.zsh、補完は completion.zsh に分けてある。

# --- ディレクトリ移動 -------------------------------------------------------
# ディレクトリ名だけで cd し、移動先はスタックに積む。`cd -<TAB>` で履歴から選べる。
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_silent          # pushd/popd のたびにスタックを表示しない

# --- 補完 -------------------------------------------------------------------
setopt complete_in_word      # 語の途中でも補完する（カーソルを末尾に動かさない）
setopt always_to_end         # 補完が確定したらカーソルを語末へ
setopt auto_param_slash      # ディレクトリ補完の末尾に / を付ける
setopt auto_param_keys       # 補完した括弧やクォートの後の入力を賢く扱う
setopt magic_equal_subst     # --opt=/path の = 以降もパスとして補完する
setopt list_packed           # 候補一覧を詰めて表示する
unsetopt menu_complete       # TAB 一発で勝手に確定させない（fzf-tab に渡す）
unsetopt list_beep

# --- グロブ -----------------------------------------------------------------
setopt extended_glob         # ^ ~ # (#i) などの拡張パターンを有効化
setopt numeric_glob_sort     # file2 < file10 の順で並べる
# extended_glob は ^ をパターン文字にするため、`git show HEAD^` が
# nomatch エラーになる。マッチしないパターンはそのまま渡す方が実用的。
unsetopt nomatch

# --- 入出力 -----------------------------------------------------------------
setopt interactive_comments  # 対話行でも # 以降をコメント扱いにする
setopt print_eight_bit       # 補完候補の日本語ファイル名を化けさせない
setopt no_clobber            # > での上書きを止める（意図的な上書きは >| ）
setopt rc_quotes             # '' 内の '' を単一のクォートとして扱う
unsetopt flow_control        # ^S/^Q を端末に奪わせず ZLE に回す
unsetopt beep

# --- ジョブ -----------------------------------------------------------------
setopt long_list_jobs        # jobs の既定表示を詳細形式に
setopt notify                # バックグラウンドジョブの終了を即座に知らせる
