gac() {
  local staged_diff message summary_input MAX_CHARS=12000

  staged_diff=$(git diff --cached)
  if [[ -z "$staged_diff" ]]; then
    echo "No staged changes." >&2
    return 1
  fi

  echo "Generating commit message..." >&2

  # diff が大きい場合は --stat + ファイルごとの先頭のみに切り替え
  if (( ${#staged_diff} > MAX_CHARS )); then
    echo "Diff too large (${#staged_diff} chars), falling back to stat + truncated per-file diff..." >&2

    local stat per_file_diffs file
    stat=$(git diff --cached --stat)

    per_file_diffs=""
    while IFS= read -r file; do
      local file_diff
      file_diff=$(git diff --cached -- "$file" | head -n 40)
      per_file_diffs+="### $file\n${file_diff}\n\n"
    done < <(git diff --cached --name-only)

    summary_input="## --stat\n${stat}\n\n## Per-file diff (truncated)\n${per_file_diffs}"
  else
    summary_input="$staged_diff"
  fi

  message=$(claude -p "以下のgit diffを解析して、Conventional Commits形式のコミットメッセージを1行で生成してください。説明や前置きは不要で、コミットメッセージのみを出力してください。

$summary_input")

  if [[ -z "$message" ]]; then
    echo "Failed to generate commit message." >&2
    return 1
  fi

  echo "Commit message: $message" >&2
  echo -n "Proceed? [Y/n]: " >&2
  read -r confirm
  [[ "$confirm" =~ ^[Nn]$ ]] && { echo "Aborted." >&2; return 1; }

  git commit -m "$message"
}

gaac() { git add -A && gac "$@"; }

alias reload="source ~/.zshrc"
claude-local() {
  ANTHROPIC_BASE_URL="http://192.168.0.18:1234" \
  ANTHROPIC_AUTH_TOKEN="lm-studio" \
  claude --model ornith-1.0-35b "$@"
}
