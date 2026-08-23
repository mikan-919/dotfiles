# Preserve NixOS package suggestions without loading the rest of /etc/zshrc.
# Probe with `whence -p` instead of $+commands[...]: the latter hashes every
# executable on PATH (~40ms with the Nix profiles in play).
if [[ -n ${NIX_PROFILES:-} ]] && whence -p command-not-found >/dev/null; then
  command_not_found_handler() {
    command command-not-found "$@"
  }
fi
