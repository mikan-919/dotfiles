# Preserve NixOS package suggestions without loading the rest of /etc/zshrc.
if [[ -n ${NIX_PROFILES:-} ]] && (( $+commands[command-not-found] )); then
  command_not_found_handler() {
    command command-not-found "$@"
  }
fi
