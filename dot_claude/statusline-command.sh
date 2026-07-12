#!/usr/bin/env bash

data=$(cat)

tokens=$(jq -r '.context_window.total_input_tokens' <<<"$data")
cost=$(jq -r '.cost.total_cost_usd' <<<"$data")
five=$(jq -r '.rate_limits.five_hour.used_percentage' <<<"$data")
seven=$(jq -r '.rate_limits.seven_day.used_percentage' <<<"$data")

printf "🧠 %.0fk │ $%.2f │ 5h %d%% │ 7d %d%%\n" \
  "$(awk "BEGIN {print $tokens/1000}")" \
  "$cost" \
  "$five" \
  "$seven"
