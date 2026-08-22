export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8
export RUSTC_WRAPPER=sccache
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$PATH:$HOME/.turso"
export PATH="$HOME/.steel/bin:$PATH"

# fd honours .gitignore and skips .git, so it is both faster and quieter than
# the find(1) fallback fzf uses otherwise.
if whence -p fd >/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi
