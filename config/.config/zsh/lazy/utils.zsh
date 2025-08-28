eval "$(mise activate bash)"
eval "$(zoxide init zsh)"

autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.m+1) ]]; then
  compinit -i -d ~/.zcompdump
else
  compinit -i -C -d ~/.zcompdump
fi