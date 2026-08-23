# zsh-autosuggestions の設定
# history で見つからなければ補完候補から提案する。
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

# 既定では行を出すたびに ZLE ウィジェットをバインドし直す。初回だけに切り替えて
# その分を削る。代わりに、後から widget を包むプラグインより後で読む必要がある
# ため、plugins.toml では zsh-syntax-highlighting の後ろに置いてある。
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# 長い行を貼り付けたときに提案の検索でもたつくのを防ぐ。
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=40
