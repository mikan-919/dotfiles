# zshの補完候補が画面から溢れ出る時、それでも表示するか確認
export LISTMAX=50
# バックグラウンドジョブの優先度(ionice)をbashと同じ挙動に
unsetopt bg_nice
# 補完候補を詰めて表示
setopt list_packed
# ピープオンを鳴らさない
setopt no_beep
# ファイル種別起動を補完候補の末尾に表示しない
unsetopt list_types
