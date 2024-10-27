# env
export PATH=$HOME/.local/bin:$PATH
export EDITOR=nvim
export SHELL=/bin/zsh
export BAT_THEME=base16
export MANPAGER='nvim +Man!'
# alias
alias vim='nvim'
alias cd=z
alias ls=lsd
alias ll="lsd -a"
alias la="lsd -l"
alias lla="lsd -al"
alias lt="lsd --tree"
alias llt="lsd --tree -l"
alias llta="lsd --tree -al"
# others
eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"
autoload -Uz compinit; compinit
