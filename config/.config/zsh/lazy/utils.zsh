code_cache() {
  local cache_file=$HOME/.cache/"$1"
  local generate_command="$3"

  eval "$generate_command" > "${cache_file}"
  builtin source $cache_file
}
code_cache mise.zsh "mise activate zsh"
code_cache zxoxide.zsh "zoxide init zsh"

autoload -Uz compinit; compinit
